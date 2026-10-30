import re
import requests
from django.utils import timezone
from rest_framework import viewsets, permissions, status, views
from rest_framework.response import Response
from rest_framework.decorators import action
from integrations.models import GitHubIntegration, GitHubLinkedPR
from integrations.serializers import GitHubIntegrationSerializer, GitHubLinkedPRSerializer
from projects.models import Task
from audit.models import log_activity


class GitHubIntegrationViewSet(viewsets.ModelViewSet):
    serializer_class = GitHubIntegrationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        if not self.request.company:
            return GitHubIntegration.objects.none()
        return GitHubIntegration.objects.filter(company=self.request.company)

    def perform_create(self, serializer):
        integ = serializer.save(company=self.request.company, connected_by=self.request.user)
        log_activity(
            company=self.request.company,
            user=self.request.user,
            action='CREATE',
            resource_type='integration',
            resource_id=integ.id,
            description=f"Connected GitHub repo {integ.repo_full_name}"
        )

    @action(detail=True, methods=['post'])
    def sync(self, request, pk=None):
        integ = self.get_object()
        headers = {
            'Accept': 'application/vnd.github.v3+json',
            'User-Agent': 'Centria-Platform',
        }
        if integ.personal_access_token:
            headers['Authorization'] = f"token {integ.personal_access_token}"

        url = f"https://api.github.com/repos/{integ.repo_owner}/{integ.repo_name}/pulls?state=all&per_page=20"
        try:
            res = requests.get(url, headers=headers, timeout=10)
            if res.status_code != 200:
                return Response({'error': f'GitHub API error ({res.status_code}): {res.text}'}, status=status.HTTP_400_BAD_REQUEST)

            pr_data = res.json()
            synced_count = 0
            for pr in pr_data:
                pr_num = pr.get('number')
                title = pr.get('title', '')
                state = 'merged' if pr.get('merged_at') else pr.get('state', 'open')
                html_url = pr.get('html_url', '')
                author = pr.get('user', {}).get('login', '')

                # Try to link to task if task key mentioned in title or branch
                linked_task = None
                match = re.search(r'([A-Z]{2,10}-\d+)', title)
                if match:
                    task_key = match.group(1)
                    parts = task_key.split('-')
                    if len(parts) == 2 and parts[1].isdigit():
                        linked_task = Task.objects.filter(
                            company=request.company,
                            project__key=parts[0],
                            task_number=int(parts[1])
                        ).first()

                GitHubLinkedPR.objects.update_or_create(
                    integration=integ,
                    pr_number=pr_num,
                    defaults={
                        'title': title,
                        'state': state,
                        'html_url': html_url,
                        'author_username': author,
                        'linked_task': linked_task,
                    }
                )
                synced_count += 1

            integ.last_synced_at = timezone.now()
            integ.save(update_fields=['last_synced_at'])

            log_activity(
                company=request.company,
                user=request.user,
                action='UPDATE',
                resource_type='integration',
                resource_id=integ.id,
                description=f"Synced {synced_count} PRs from GitHub repo {integ.repo_full_name}"
            )

            prs = GitHubLinkedPR.objects.filter(integration=integ)
            return Response({
                'message': f"Synced {synced_count} pull requests.",
                'pull_requests': GitHubLinkedPRSerializer(prs, many=True).data
            })
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


import hmac
import hashlib
import os
from django.conf import settings


class GitHubWebhookView(views.APIView):
    """Webhook receiver for GitHub events with strict HMAC-SHA256 signature verification."""
    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        signature_header = (request.headers.get('X-Hub-Signature-256') or request.META.get('HTTP_X_HUB_SIGNATURE_256', '')).strip()
        if not signature_header or not signature_header.startswith('sha256='):
            return Response({'error': 'Missing or invalid signature header.'}, status=status.HTTP_401_UNAUTHORIZED)

        webhook_secret = getattr(settings, 'GITHUB_WEBHOOK_SECRET', '') or os.environ.get('GITHUB_WEBHOOK_SECRET', '')
        if not webhook_secret:
            return Response({'error': 'Server webhook secret not configured.'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        mac = hmac.new(webhook_secret.encode('utf-8'), msg=request.body, digestmod=hashlib.sha256)
        expected_sig = f"sha256={mac.hexdigest()}"

        if not hmac.compare_digest(signature_header, expected_sig):
            return Response({'error': 'Signature verification failed.'}, status=status.HTTP_403_FORBIDDEN)

        event_type = request.headers.get('X-GitHub-Event', request.META.get('HTTP_X_GITHUB_EVENT', 'ping'))
        if event_type == 'ping':
            return Response({'status': 'pong'}, status=status.HTTP_200_OK)

        return Response({'status': 'accepted', 'event': event_type}, status=status.HTTP_200_OK)
