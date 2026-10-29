import uuid
from django.db import models
from django.conf import settings
from core.models import TenantModel


class Project(TenantModel):
    """Business and software project container."""
    STATUS_CHOICES = [
        ('planning', 'Planning'),
        ('active', 'Active'),
        ('paused', 'Paused'),
        ('completed', 'Completed'),
    ]

    name = models.CharField(max_length=255)
    key = models.CharField(max_length=10, db_index=True)
    description = models.TextField(blank=True)
    status = models.CharField(max_length=32, choices=STATUS_CHOICES, default='active')
    lead = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True, related_name='led_projects')
    start_date = models.DateField(null=True, blank=True)
    target_date = models.DateField(null=True, blank=True)
    is_archived = models.BooleanField(default=False)

    class Meta:
        unique_together = ('company', 'key')
        ordering = ['-created_at']

    def __str__(self):
        return f"[{self.key}] {self.name}"


class Task(TenantModel):
    """Task, bug, issue, or feature item with kanban status and assignments."""
    TYPE_CHOICES = [
        ('task', 'Task'),
        ('bug', 'Bug'),
        ('feature', 'Feature'),
        ('improvement', 'Improvement'),
    ]

    STATUS_CHOICES = [
        ('backlog', 'Backlog'),
        ('todo', 'To Do'),
        ('in_progress', 'In Progress'),
        ('in_review', 'In Review'),
        ('done', 'Done'),
    ]

    PRIORITY_CHOICES = [
        ('low', 'Low'),
        ('medium', 'Medium'),
        ('high', 'High'),
        ('urgent', 'Urgent'),
    ]

    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name='tasks')
    task_number = models.PositiveIntegerField()
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    task_type = models.CharField(max_length=32, choices=TYPE_CHOICES, default='task')
    status = models.CharField(max_length=32, choices=STATUS_CHOICES, default='todo')
    priority = models.CharField(max_length=32, choices=PRIORITY_CHOICES, default='medium')
    assignee = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True, related_name='assigned_tasks')
    creator = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True, related_name='created_tasks')
    due_date = models.DateField(null=True, blank=True)
    custom_fields = models.JSONField(default=dict, blank=True)

    class Meta:
        unique_together = ('project', 'task_number')
        ordering = ['-created_at']

    @property
    def key(self):
        return f"{self.project.key}-{self.task_number}"

    def save(self, *args, **kwargs):
        if not self.task_number:
            last = Task.objects.filter(project=self.project).order_by('-task_number').first()
            self.task_number = (last.task_number + 1) if last else 1
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.key}: {self.title}"


class TaskComment(models.Model):
    """Collaborative comments on tasks."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    task = models.ForeignKey(Task, on_delete=models.CASCADE, related_name='comments')
    author = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True)
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['created_at']

    def __str__(self):
        return f"Comment by {self.author} on {self.task}"


class Customer(TenantModel):
    """CRM customer record for client workspaces and B2B services."""
    STATUS_CHOICES = [
        ('lead', 'Lead'),
        ('active', 'Active Customer'),
        ('churned', 'Churned'),
    ]

    name = models.CharField(max_length=255)
    email = models.EmailField(blank=True)
    phone = models.CharField(max_length=64, blank=True)
    company_name = models.CharField(max_length=255, blank=True)
    status = models.CharField(max_length=32, choices=STATUS_CHOICES, default='active')
    notes = models.TextField(blank=True)

    class Meta:
        ordering = ['name']

    def __str__(self):
        return f"{self.name} ({self.company_name or 'Individual'})"
