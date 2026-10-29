import uuid
from django.db import models
from django.conf import settings
from core.models import Company


class AuditLog(models.Model):
    """Immutable audit trail for compliance, security, and activity tracking."""
    ACTION_CHOICES = [
        ('CREATE', 'Created'),
        ('UPDATE', 'Updated'),
        ('DELETE', 'Deleted'),
        ('LOGIN', 'Logged In'),
        ('LOGOUT', 'Logged Out'),
        ('APPROVE', 'Approved'),
        ('REJECT', 'Rejected'),
        ('AI_QUERY', 'AI Query Executed'),
        ('EXPORT', 'Data Exported'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    company = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='audit_logs', null=True, blank=True)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True, related_name='audit_entries')
    action = models.CharField(max_length=32, choices=ACTION_CHOICES)
    resource_type = models.CharField(max_length=64, db_index=True)
    resource_id = models.CharField(max_length=255, blank=True)
    description = models.TextField(blank=True)
    changes = models.JSONField(default=dict, blank=True)
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    timestamp = models.DateTimeField(auto_now_add=True, db_index=True)

    class Meta:
        ordering = ['-timestamp']
        indexes = [
            models.Index(fields=['company', '-timestamp']),
            models.Index(fields=['resource_type', 'resource_id']),
        ]

    def __str__(self):
        user_str = self.user.email if self.user else 'System'
        return f"[{self.timestamp.strftime('%Y-%m-%d %H:%M')}] {user_str} - {self.action} {self.resource_type}"


def log_activity(company, user, action, resource_type, resource_id="", description="", changes=None, ip_address=None):
    """Helper function to record an audit log entry safely."""
    try:
        return AuditLog.objects.create(
            company=company,
            user=user if user and user.is_authenticated else None,
            action=action,
            resource_type=resource_type,
            resource_id=str(resource_id),
            description=description,
            changes=changes or {},
            ip_address=ip_address,
        )
    except Exception as e:
        # Avoid crashing primary operations if audit fails
        import logging
        logging.getLogger('centria.audit').error(f"Audit log failed: {e}")
        return None
