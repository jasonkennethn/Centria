import uuid
from django.db import models
from apps.companies.models import Company

class AnalyticsSnapshot(models.Model):
    """Historical snapshot of organizational velocity and financial health."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    company = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='analytics_snapshots')
    date = models.DateField(auto_now_add=True)
    cash_balance = models.DecimalField(max_digits=14, decimal_places=2, default=0.0)
    monthly_revenue = models.DecimalField(max_digits=12, decimal_places=2, default=0.0)
    monthly_burn = models.DecimalField(max_digits=12, decimal_places=2, default=0.0)
    runway_months = models.DecimalField(max_digits=5, decimal_places=1, default=12.0)
    active_projects_count = models.IntegerField(default=0)
    pending_approvals_count = models.IntegerField(default=0)
    headcount = models.IntegerField(default=0)
    delay_risk_score = models.IntegerField(default=15)
    ai_narrative = models.TextField(blank=True)

    class Meta:
        ordering = ['-date']
