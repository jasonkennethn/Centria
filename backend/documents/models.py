import uuid
from django.db import models
from django.conf import settings
from pgvector.django import VectorField
from core.models import TenantModel


class Document(TenantModel):
    """Knowledge base document (PDF, DOCX, Markdown, Text)."""
    FILE_TYPE_CHOICES = [
        ('pdf', 'PDF Document'),
        ('docx', 'Word Document'),
        ('markdown', 'Markdown File'),
        ('txt', 'Text File'),
    ]

    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    file_url = models.URLField(max_length=1000)
    file_type = models.CharField(max_length=16, choices=FILE_TYPE_CHOICES, default='pdf')
    file_size_bytes = models.BigIntegerField(default=0)
    uploaded_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True)
    is_indexed = models.BooleanField(default=False)
    indexed_at = models.DateTimeField(null=True, blank=True)
    chunk_count = models.PositiveIntegerField(default=0)
    tags = models.JSONField(default=list, blank=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.title} ({self.file_type})"


class DocumentChunk(models.Model):
    """Text chunk of an indexed document with 768-dim Gemini vector embedding."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    document = models.ForeignKey(Document, on_delete=models.CASCADE, related_name='chunks')
    company = models.ForeignKey('core.Company', on_delete=models.CASCADE, db_index=True)
    chunk_index = models.PositiveIntegerField()
    content = models.TextField()
    token_count = models.PositiveIntegerField(default=0)
    # Gemini gemini-embedding-001 produces 3072 dimensions
    embedding = VectorField(dimensions=3072, null=True, blank=True)
    metadata = models.JSONField(default=dict, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['document', 'chunk_index']
        indexes = [
            models.Index(fields=['company', 'document']),
        ]

    def __str__(self):
        return f"{self.document.title} [Chunk {self.chunk_index}]"
