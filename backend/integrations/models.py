import uuid
from django.db import models
from django.conf import settings
from core.models import TenantModel


class GitHubIntegration(TenantModel):
    """Personal Access Token integration with GitHub repositories."""
    connected_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    repo_owner = models.CharField(max_length=100)
    repo_name = models.CharField(max_length=100)
    personal_access_token = models.CharField(max_length=255)
    is_active = models.BooleanField(default=True)
    last_synced_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        unique_together = ('company', 'repo_owner', 'repo_name')
        ordering = ['repo_owner', 'repo_name']

    @property
    def repo_full_name(self):
        return f"{self.repo_owner}/{self.repo_name}"

    def __str__(self):
        return f"GitHub: {self.repo_full_name}"


class GitHubLinkedPR(models.Model):
    """Linked pull request from GitHub repository to a Centria Task."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    integration = models.ForeignKey(GitHubIntegration, on_delete=models.CASCADE, related_name='pull_requests')
    pr_number = models.PositiveIntegerField()
    title = models.CharField(max_length=255)
    state = models.CharField(max_length=32, default='open')  # open, closed, merged
    html_url = models.URLField(max_length=500)
    author_username = models.CharField(max_length=100, blank=True)
    linked_task = models.ForeignKey('projects.Task', on_delete=models.SET_NULL, null=True, blank=True, related_name='github_prs')
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ('integration', 'pr_number')
        ordering = ['-pr_number']

    def __str__(self):
        return f"#{self.pr_number} {self.title} ({self.state})"
