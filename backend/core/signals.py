"""
Real-time database change signal handlers for Centria.
Broadcasts instant updates via Channels WebSockets across:
1. Jira-style boards & sprints (Task status, assignments)
2. Tasks & projects (Progress, comments, assignments)
3. Approvals (Decisions, status transitions, pending count)
4. Notifications (Task assignments, mentions, status alerts)
5. GitHub integration (PR / synchronization status)
6. Dashboards (Live operational activity stream)
"""
import logging
from django.db import transaction
from django.db.models.signals import post_save
from django.dispatch import receiver
from core.realtime import broadcast_workspace_event, broadcast_user_event

logger = logging.getLogger('centria.signals')


def safe_on_commit(callback):
    """
    Executes callback only after the database transaction has committed.
    Prevents ghost updates where clients receive WebSocket broadcasts
    before row changes are committed or visible in PostgreSQL.
    """
    try:
        transaction.on_commit(callback)
    except Exception:
        callback()


@receiver(post_save, sender='projects.Task')
def task_realtime_broadcast(sender, instance, created, **kwargs):
    """Instant update for Jira boards, task lists, and sprint changes."""
    try:
        company_id = instance.company_id
        event_name = 'task_created' if created else 'task_updated'

        data = {
            'id': str(instance.id),
            'key': instance.key,
            'task_number': instance.task_number,
            'title': instance.title,
            'status': instance.status,
            'priority': instance.priority,
            'task_type': instance.task_type,
            'project_id': str(instance.project_id),
            'project_key': instance.project.key if instance.project else '',
            'assignee_id': str(instance.assignee_id) if instance.assignee_id else None,
            'assignee_name': instance.assignee.full_name if instance.assignee else 'Unassigned',
            'due_date': str(instance.due_date) if instance.due_date else None,
            'is_created': created,
        }

        assignee_id = instance.assignee_id
        task_key = instance.key
        task_title = instance.title
        task_status = instance.status
        task_id = str(instance.id)

        def dispatch():
            broadcast_workspace_event(company_id, event_name, data)
            if assignee_id:
                broadcast_user_event(assignee_id, 'notification', {
                    'title': 'Task Assignment',
                    'message': f"Assigned to {task_key}: {task_title} ({task_status.upper()})",
                    'resource_type': 'task',
                    'resource_id': task_id,
                })

        safe_on_commit(dispatch)
    except Exception as e:
        logger.warning(f"Error in task_realtime_broadcast: {e}")


@receiver(post_save, sender='projects.TaskComment')
def task_comment_realtime_broadcast(sender, instance, created, **kwargs):
    """Instant update for collaborative task discussions and comments."""
    if not created:
        return
    try:
        task = instance.task
        company_id = task.company_id
        data = {
            'task_id': str(task.id),
            'task_key': task.key,
            'comment_id': str(instance.id),
            'author_name': instance.author.full_name if instance.author else 'Team Member',
            'content_snippet': instance.content[:120],
            'created_at': instance.created_at.isoformat(),
        }

        assignee_id = task.assignee_id
        author_id = instance.author_id
        task_key = task.key
        task_id = str(task.id)

        def dispatch():
            broadcast_workspace_event(company_id, 'task_comment_created', data)
            if assignee_id and (not author_id or author_id != assignee_id):
                broadcast_user_event(assignee_id, 'notification', {
                    'title': f"New Comment on {task_key}",
                    'message': f"{data['author_name']}: {data['content_snippet']}",
                    'resource_type': 'task',
                    'resource_id': task_id,
                })

        safe_on_commit(dispatch)
    except Exception as e:
        logger.warning(f"Error in task_comment_realtime_broadcast: {e}")


@receiver(post_save, sender='approvals.ApprovalRequest')
def approval_realtime_broadcast(sender, instance, created, **kwargs):
    """Instant update for approvals workflow, decisions, and pending badge counters."""
    try:
        from approvals.models import ApprovalRequest
        company_id = instance.company_id
        pending_count = ApprovalRequest.objects.filter(company_id=company_id, status='pending').count()

        event_name = 'approval_created' if created else 'approval_updated'
        data = {
            'id': str(instance.id),
            'title': instance.title,
            'category': instance.category,
            'status': instance.status,
            'requester_name': instance.requester.full_name if instance.requester else 'Team Member',
            'decision_note': instance.decision_note,
            'pending_count': pending_count,
            'is_created': created,
        }

        status_val = instance.status
        requester_id = instance.requester_id
        title_val = instance.title
        instance_id = str(instance.id)
        decided_by_name = instance.decided_by.full_name if instance.decided_by else 'Reviewer'

        def dispatch():
            broadcast_workspace_event(company_id, event_name, data)
            if not created and status_val in ('approved', 'rejected') and requester_id:
                broadcast_user_event(requester_id, 'notification', {
                    'title': f"Approval Request {status_val.capitalize()}",
                    'message': f"'{title_val}' was {status_val} by {decided_by_name}.",
                    'resource_type': 'approval',
                    'resource_id': instance_id,
                })

        safe_on_commit(dispatch)
    except Exception as e:
        logger.warning(f"Error in approval_realtime_broadcast: {e}")


@receiver(post_save, sender='projects.Project')
def project_realtime_broadcast(sender, instance, created, **kwargs):
    """Instant update for project lifecycle and status."""
    try:
        company_id = instance.company_id
        data = {
            'id': str(instance.id),
            'key': instance.key,
            'name': instance.name,
            'status': instance.status,
            'is_created': created,
        }
        safe_on_commit(lambda: broadcast_workspace_event(company_id, 'project_updated', data))
    except Exception as e:
        logger.warning(f"Error in project_realtime_broadcast: {e}")


@receiver(post_save, sender='integrations.GitHubLinkedPR')
def github_pr_realtime_broadcast(sender, instance, created, **kwargs):
    """Instant synchronization status for GitHub PRs linked to tasks."""
    try:
        company_id = instance.integration.company_id
        data = {
            'pr_number': instance.pr_number,
            'title': instance.title,
            'state': instance.state,
            'html_url': instance.html_url,
            'linked_task_id': str(instance.linked_task_id) if instance.linked_task_id else None,
            'linked_task_key': instance.linked_task.key if instance.linked_task else None,
        }
        safe_on_commit(lambda: broadcast_workspace_event(company_id, 'github_sync', data))
    except Exception as e:
        logger.warning(f"Error in github_pr_realtime_broadcast: {e}")


@receiver(post_save, sender='audit.AuditLog')
def audit_activity_realtime_broadcast(sender, instance, created, **kwargs):
    """Instant live activity feed broadcast for company dashboards."""
    if not created or not instance.company_id:
        return
    try:
        data = {
            'id': str(instance.id),
            'action': instance.action,
            'resource_type': instance.resource_type,
            'description': instance.description,
            'user_name': instance.user.full_name if instance.user else 'System',
            'timestamp': instance.timestamp.isoformat(),
        }
        company_id = instance.company_id
        safe_on_commit(lambda: broadcast_workspace_event(company_id, 'dashboard_activity', data))
    except Exception as e:
        logger.warning(f"Error in audit_activity_realtime_broadcast: {e}")
