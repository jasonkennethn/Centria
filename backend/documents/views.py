import os
from rest_framework import viewsets, permissions, views, status
from rest_framework.response import Response
from rest_framework.decorators import action
from documents.models import Document, DocumentChunk
from documents.serializers import DocumentSerializer, DocumentChunkSerializer
from documents.services import index_document_content, search_knowledge_base
from media_pipeline.services import process_and_upload_media
from audit.models import log_activity


class DocumentViewSet(viewsets.ModelViewSet):
    serializer_class = DocumentSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        if not self.request.company:
            return Document.objects.none()
        return Document.objects.filter(company=self.request.company).select_related('uploaded_by')

    def create(self, request, *args, **kwargs):
        company = request.company
        if not company:
            return Response({'error': 'No active company workspace'}, status=status.HTTP_400_BAD_REQUEST)

        uploaded_file = request.FILES.get('file')
        title = request.data.get('title') or (uploaded_file.name if uploaded_file else 'Untitled Document')
        description = request.data.get('description', '')

        if not uploaded_file:
            return Response({'error': 'File is required'}, status=status.HTTP_400_BAD_REQUEST)

        MAX_DOCUMENT_SIZE = 25 * 1024 * 1024  # 25 MB
        if uploaded_file.size > MAX_DOCUMENT_SIZE:
            return Response({'error': 'File size exceeds maximum allowable limit of 25 MB.'}, status=status.HTTP_400_BAD_REQUEST)
        if uploaded_file.size == 0:
            return Response({'error': 'Uploaded file is empty.'}, status=status.HTTP_400_BAD_REQUEST)

        ALLOWED_EXTENSIONS = {'pdf', 'docx', 'doc', 'txt', 'md', 'markdown'}
        ext = os.path.splitext(uploaded_file.name)[1].lower().lstrip('.')
        if ext not in ALLOWED_EXTENSIONS:
            return Response({'error': f"File type '.{ext}' is not supported. Allowed formats: PDF, DOCX, TXT, MD."}, status=status.HTTP_400_BAD_REQUEST)

        file_type = 'pdf' if ext == 'pdf' else ('docx' if ext in ('docx', 'doc') else ('markdown' if ext in ('md', 'markdown') else 'txt'))

        # Read file bytes for indexing
        raw_bytes = uploaded_file.read()
        uploaded_file.seek(0)

        # Upload file to storage
        media_asset = process_and_upload_media(uploaded_file, company=company, user=request.user, folder='documents')

        document = Document.objects.create(
            company=company,
            title=title,
            description=description,
            file_url=media_asset.url,
            file_type=file_type,
            file_size_bytes=len(raw_bytes),
            uploaded_by=request.user,
        )

        # Index document content for RAG
        chunks_count = index_document_content(document, raw_bytes)

        log_activity(
            company=company,
            user=request.user,
            action='CREATE',
            resource_type='document',
            resource_id=document.id,
            description=f"Uploaded and indexed document '{document.title}' ({chunks_count} chunks)."
        )

        return Response(DocumentSerializer(document).data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=['get'])
    def chunks(self, request, pk=None):
        document = self.get_object()
        chunks = DocumentChunk.objects.filter(document=document)
        return Response(DocumentChunkSerializer(chunks, many=True).data)

    @action(detail=False, methods=['get'])
    def search(self, request):
        query = request.query_params.get('q', '').strip()
        if not query:
            return Response({'error': 'Query parameter q is required'}, status=status.HTTP_400_BAD_REQUEST)
        citations = search_knowledge_base(request.company, query, top_k=5)
        return Response({'query': query, 'results': citations})
