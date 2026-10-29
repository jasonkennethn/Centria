import uuid
from django.db import models
from django.conf import settings
from core.models import TenantModel


class MediaAsset(TenantModel):
    """Tracks images and files processed by the Centria media pipeline."""
    uploader = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True)
    original_filename = models.CharField(max_length=255)
    file_type = models.CharField(max_length=64, default='image/avif')
    size_bytes = models.BigIntegerField(default=0)
    s3_key = models.CharField(max_length=512, unique=True)
    url = models.URLField(max_length=1000)
    width = models.PositiveIntegerField(null=True, blank=True)
    height = models.PositiveIntegerField(null=True, blank=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.original_filename} ({self.file_type})"
