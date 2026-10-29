import io
import logging
from django.conf import settings
from django.utils import timezone
from pgvector.django import CosineDistance
import google.generativeai as genai
from documents.models import Document, DocumentChunk

logger = logging.getLogger('centria.rag')


def get_gemini_client():
    api_key = getattr(settings, 'GEMINI_API_KEY', '')
    if api_key:
        genai.configure(api_key=api_key)
    return genai


def extract_text(file_bytes, file_type):
    """Extracts raw text from PDF, DOCX, TXT, or Markdown."""
    text = ""
    file_type = (file_type or '').lower()

    try:
        if file_type == 'pdf':
            import PyPDF2
            reader = PyPDF2.PdfReader(io.BytesIO(file_bytes))
            for page_idx, page in enumerate(reader.pages):
                page_text = page.extract_text() or ""
                text += f"\n--- Page {page_idx + 1} ---\n" + page_text
        elif file_type in ('docx', 'doc'):
            import docx
            doc = docx.Document(io.BytesIO(file_bytes))
            for para in doc.paragraphs:
                if para.text.strip():
                    text += para.text + "\n"
        else:
            text = file_bytes.decode('utf-8', errors='replace')
    except Exception as e:
        logger.error(f"Text extraction failed for {file_type}: {e}")
        text = file_bytes.decode('utf-8', errors='replace')

    return text.strip()


def chunk_text(text, max_chars=1200, overlap_chars=150):
    """Splits document text into overlapping character chunks."""
    if not text:
        return []

    chunks = []
    start = 0
    text_len = len(text)

    while start < text_len:
        end = min(start + max_chars, text_len)
        chunk = text[start:end].strip()
        if chunk:
            chunks.append(chunk)
        if end >= text_len:
            break
        start += (max_chars - overlap_chars)

    return chunks


def generate_embedding(text):
    """Generates 3072-dim Gemini embedding vector."""
    get_gemini_client()
    model = getattr(settings, 'GEMINI_EMBEDDING_MODEL', 'models/gemini-embedding-001')
    try:
        res = genai.embed_content(
            model=model,
            content=text[:2048]
        )
        return res.get('embedding', [])
    except Exception as e:
        logger.error(f"Embedding generation error: {e}")
        return None


def index_document_content(document, raw_bytes):
    """Extracts, chunks, embeds, and indexes a Document in the knowledge base."""
    text = extract_text(raw_bytes, document.file_type)
    if not text:
        return 0

    chunks = chunk_text(text)
    # Remove previous chunks if re-indexing
    DocumentChunk.objects.filter(document=document).delete()

    created_chunks = []
    for idx, chunk_content in enumerate(chunks):
        embedding_vec = generate_embedding(chunk_content)
        created_chunks.append(DocumentChunk(
            document=document,
            company=document.company,
            chunk_index=idx + 1,
            content=chunk_content,
            token_count=len(chunk_content.split()),
            embedding=embedding_vec,
            metadata={'chunk_index': idx + 1, 'title': document.title}
        ))

    DocumentChunk.objects.bulk_create(created_chunks)
    document.is_indexed = True
    document.indexed_at = timezone.now()
    document.chunk_count = len(created_chunks)
    document.save(update_fields=['is_indexed', 'indexed_at', 'chunk_count'])
    return len(created_chunks)


def search_knowledge_base(company, query_text, top_k=4):
    """
    Finds top-K most relevant chunks across all company documents using cosine similarity.
    Returns list of dicts with document info, snippet, score, and citation label.
    """
    if not query_text or not company:
        return []

    query_embedding = generate_embedding(query_text)
    if not query_embedding:
        return []

    results = (
        DocumentChunk.objects
        .filter(company=company, embedding__isnull=False)
        .annotate(distance=CosineDistance('embedding', query_embedding))
        .select_related('document')
        .order_by('distance')[:top_k]
    )

    citations = []
    for r in results:
        # Cosine similarity = 1 - cosine distance
        similarity = max(0.0, 1.0 - (r.distance or 0.0))
        citations.append({
            'document_id': str(r.document.id),
            'document_title': r.document.title,
            'file_url': r.document.file_url,
            'chunk_id': str(r.id),
            'chunk_index': r.chunk_index,
            'similarity_score': round(similarity, 3),
            'excerpt': r.content[:300] + ('...' if len(r.content) > 300 else ''),
        })
    return citations
