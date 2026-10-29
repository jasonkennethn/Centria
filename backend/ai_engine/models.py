import uuid
from django.db import models
from django.conf import settings
from core.models import TenantModel


class AIConversation(TenantModel):
    """Chat session with Centria Assistant across different operational contexts."""
    CONTEXT_CHOICES = [
        ('general', 'General Assistant'),
        ('project', 'Project Operations'),
        ('task', 'Task & Issue Helper'),
        ('document', 'Document Intelligence'),
        ('reporting', 'Operations Reporting'),
    ]

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='ai_conversations')
    title = models.CharField(max_length=255, default='New conversation')
    context_type = models.CharField(max_length=32, choices=CONTEXT_CHOICES, default='general')
    context_id = models.CharField(max_length=255, blank=True)
    is_archived = models.BooleanField(default=False)

    class Meta:
        ordering = ['-updated_at']

    def __str__(self):
        return f"{self.title} ({self.context_type})"


class AIMessage(models.Model):
    """Individual message turn in an AI conversation with RAG citations."""
    SENDER_CHOICES = [
        ('user', 'User'),
        ('assistant', 'Assistant'),
        ('system', 'System'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    conversation = models.ForeignKey(AIConversation, on_delete=models.CASCADE, related_name='messages')
    sender = models.CharField(max_length=16, choices=SENDER_CHOICES)
    content = models.TextField()
    citations = models.JSONField(default=list, blank=True)
    tokens_used = models.PositiveIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['created_at']

    def __str__(self):
        return f"[{self.sender}] {self.content[:40]}..."


class AIUsageQuota(TenantModel):
    """Tracks monthly AI usage quotas per company and user."""
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, null=True, blank=True)
    month_year = models.CharField(max_length=7)  # YYYY-MM
    queries_count = models.PositiveIntegerField(default=0)
    tokens_total = models.PositiveIntegerField(default=0)
    limit_queries = models.PositiveIntegerField(default=500)

    class Meta:
        unique_together = ('company', 'user', 'month_year')

    def is_quota_exceeded(self):
        return self.queries_count >= self.limit_queries
