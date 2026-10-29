from rest_framework import serializers
from integrations.models import GitHubIntegration, GitHubLinkedPR


class GitHubLinkedPRSerializer(serializers.ModelSerializer):
    class Meta:
        model = GitHubLinkedPR
        fields = ['id', 'integration', 'pr_number', 'title', 'state', 'html_url', 'author_username', 'linked_task', 'updated_at']


class GitHubIntegrationSerializer(serializers.ModelSerializer):
    pull_requests = GitHubLinkedPRSerializer(many=True, read_only=True)
    repo_full_name = serializers.CharField(read_only=True)

    class Meta:
        model = GitHubIntegration
        fields = [
            'id', 'company', 'connected_by', 'repo_owner', 'repo_name',
            'repo_full_name', 'personal_access_token', 'is_active',
            'last_synced_at', 'pull_requests', 'created_at'
        ]
        read_only_fields = ['id', 'company', 'connected_by', 'last_synced_at', 'created_at']
        extra_kwargs = {
            'personal_access_token': {'write_only': True}
        }
