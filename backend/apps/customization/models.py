import uuid
from django.db import models
from apps.companies.models import Company

class CustomField(models.Model):
    """Dynamic custom field added to any core entity without code changes."""

    TARGET_ENTITIES = (
        ('EMPLOYEE', 'Employee Record'),
        ('TASK', 'Task Item'),
        ('INVOICE', 'Invoice'),
        ('DOCUMENT', 'Document'),
        ('PROJECT', 'Project'),
    )

    FIELD_TYPES = (
        ('TEXT', 'Short Text'),
        ('NUMBER', 'Number'),
        ('DATE', 'Date Picker'),
        ('DROPDOWN', 'Dropdown Select'),
        ('BOOLEAN', 'Toggle / Checkbox'),
    )

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    company = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='custom_fields')
    target_entity = models.CharField(max_length=30, choices=TARGET_ENTITIES)
    field_name = models.CharField(max_length=100)
    field_label = models.CharField(max_length=150)
    field_type = models.CharField(max_length=30, choices=FIELD_TYPES, default='TEXT')
    options_json = models.JSONField(default=list, blank=True)
    is_required = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.target_entity} - {self.field_label} ({self.field_type})"


class CustomFieldValue(models.Model):
    """Value for a specific custom field on an entity instance."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    custom_field = models.ForeignKey(CustomField, on_delete=models.CASCADE, related_name='values')
    entity_id = models.CharField(max_length=255)
    value_text = models.TextField(blank=True)
    value_number = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
    value_date = models.DateField(null=True, blank=True)
    value_boolean = models.BooleanField(null=True, blank=True)
    value_json = models.JSONField(default=dict, blank=True)

    class Meta:
        unique_together = ('custom_field', 'entity_id')
