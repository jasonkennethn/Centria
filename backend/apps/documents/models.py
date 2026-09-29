import uuid
from django.db import models
from django.conf import settings
from apps.companies.models import Company

class Document(models.Model):
    """Document stored in Neon S3 with versioning and access controls."""

    CATEGORY_CHOICES = (
        ('CONTRACT', 'Contract & Agreement'),
        ('POLICY', 'Corporate Policy'),
        ('TAX', 'Tax & Statutory Document'),
        ('INVOICE', 'Client / Vendor Invoice'),
        ('RECEIPT', 'Expense Receipt'),
        ('SOP', 'Standard Operating Procedure (SOP)'),
        ('OTHER', 'General Document'),
    )

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    company = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='documents')
    title = models.CharField(max_length=255)
    category = models.CharField(max_length=30, choices=CATEGORY_CHOICES, default='OTHER')
    file_url = models.URLField(max_length=1000)
    s3_key = models.CharField(max_length=500, blank=True)
    file_size = models.BigIntegerField(default=0)
    mime_type = models.CharField(max_length=100, blank=True)
    uploaded_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True)
    version = models.IntegerField(default=1)
    expiry_date = models.DateField(null=True, blank=True)
    is_confidential = models.BooleanField(default=False)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.title} ({self.category})"


class DocumentVersion(models.Model):
    """Historical versions of a document."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    document = models.ForeignKey(Document, on_delete=models.CASCADE, related_name='versions')
    version_number = models.IntegerField()
    file_url = models.URLField(max_length=1000)
    change_summary = models.TextField(blank=True)
    uploaded_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)


class DocumentAnalysis(models.Model):
    """Gemini Multimodal AI analysis and text extraction."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    document = models.OneToOneField(Document, on_delete=models.CASCADE, related_name='ai_analysis')
    ai_summary = models.TextField()
    key_dates_json = models.JSONField(default=list, blank=True)
    action_items_json = models.JSONField(default=list, blank=True)
    extracted_entities_json = models.JSONField(default=dict, blank=True)
    confidence_score = models.IntegerField(default=90)
    analyzed_at = models.DateTimeField(auto_now_add=True)
