import uuid
from django.db import models
from django.conf import settings
from apps.companies.models import Company

class Policy(models.Model):
    """Corporate policies, NDAs, and compliance guidelines."""

    STATUS_CHOICES = (
        ('DRAFT', 'Draft'),
        ('PUBLISHED', 'Published & Active'),
        ('ARCHIVED', 'Archived'),
    )

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    company = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='policies')
    title = models.CharField(max_length=255)
    category = models.CharField(max_length=100, default='General')
    content = models.TextField()
    version = models.CharField(max_length=20, default='1.0')
    effective_date = models.DateField(null=True, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='PUBLISHED')
    approved_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.title} (v{self.version})"


class ComplianceItem(models.Model):
    """Regulatory compliance items, tax filing deadlines, and licenses."""

    STATUS_CHOICES = (
        ('COMPLIANT', 'Compliant'),
        ('PENDING_REVIEW', 'Pending Review'),
        ('UPCOMING', 'Upcoming Deadline'),
        ('NON_COMPLIANT', 'Non Compliant / Overdue'),
    )

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    company = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='compliance_items')
    title = models.CharField(max_length=255)
    regulatory_body = models.CharField(max_length=150, blank=True)
    deadline = models.DateField(null=True, blank=True)
    status = models.CharField(max_length=30, choices=STATUS_CHOICES, default='UPCOMING')
    assigned_to = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True)
    evidence_notes = models.TextField(blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['deadline']


class AuditLog(models.Model):
    """Immutable audit trail for every critical company action."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    company = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='audit_logs')
    actor_email = models.EmailField()
    action = models.CharField(max_length=100)
    module = models.CharField(max_length=50)
    target_id = models.CharField(max_length=255, blank=True)
    details_json = models.JSONField(default=dict, blank=True)
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    timestamp = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-timestamp']

    def __str__(self):
        return f"[{self.timestamp.strftime('%Y-%m-%d %H:%M')}] {self.actor_email} -> {self.action} ({self.module})"


class BoardDecision(models.Model):
    """Formal board and executive resolution records."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    company = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='board_decisions')
    title = models.CharField(max_length=255)
    meeting_date = models.DateField()
    attendees_json = models.JSONField(default=list, blank=True)
    resolution_text = models.TextField()
    is_passed = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
