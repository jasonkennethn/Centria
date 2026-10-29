import uuid
from django.db import models
from django.conf import settings
from core.models import TenantModel


class ApprovalRequest(TenantModel):
    """Operational approval workflow item (release gates, scope changes, budget, documents)."""
    CATEGORY_CHOICES = [
        ('release', 'Release Gate'),
        ('scope', 'Scope Change'),
        ('budget', 'Budget Approval'),
        ('document', 'Document Sign-off'),
        ('general', 'General Approval'),
    ]

    STATUS_CHOICES = [
        ('pending', 'Pending Review'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
        ('cancelled', 'Cancelled'),
    ]

    title = models.CharField(max_length=255)
    description = models.TextField()
    category = models.CharField(max_length=32, choices=CATEGORY_CHOICES, default='general')
    status = models.CharField(max_length=32, choices=STATUS_CHOICES, default='pending')
    
    requester = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='submitted_approvals')
    assigned_approver = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True, related_name='assigned_approvals')
    
    target_resource_type = models.CharField(max_length=64, blank=True)
    target_resource_id = models.CharField(max_length=255, blank=True)
    
    decision_note = models.TextField(blank=True)
    decided_at = models.DateTimeField(null=True, blank=True)
    decided_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True, related_name='decided_approvals')

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"[{self.category}] {self.title} ({self.status})"
