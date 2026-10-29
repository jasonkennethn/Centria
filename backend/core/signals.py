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
from django.db.models.signals import post_save
from django.dispatch import receiver
from core.realtime import broadcast_workspace_event, broadcast_user_event

logger = logging.getLogger('centria.signals')


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
        broadcast_workspace_event(company_id, event_name, data)

        # Notify assigned user if newly assigned
        if instance.assignee_id:
            broadcast_user_event(instance.assignee_id, 'notification', {
                'title': 'Task Assignment',
                'message': f"Assigned to {instance.key}: {instance.title} ({instance.status.upper()})",
                'resource_type': 'task',
                'resource_id': str(instance.id),
            })
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
        broadcast_workspace_event(company_id, 'task_comment_created', data)

        # Notify task assignee if someone else commented
        if task.assignee_id and (not instance.author_id or instance.author_id != task.assignee_id):
            broadcast_user_event(task.assignee_id, 'notification', {
                'title': f"New Comment on {task.key}",
                'message': f"{data['author_name']}: {data['content_snippet']}",
                'resource_type': 'task',
                'resource_id': str(task.id),
            })
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
        broadcast_workspace_event(company_id, event_name, data)

        # If decided, notify requester
        if not created and instance.status in ('approved', 'rejected') and instance.requester_id:
            broadcast_user_event(instance.requester_id, 'notification', {
                'title': f"Approval Request {instance.status.capitalize()}",
                'message': f"'{instance.title}' was {instance.status} by {instance.decided_by.full_name if instance.decided_by else 'Reviewer'}.",
                'resource_type': 'approval',
                'resource_id': str(instance.id),
            })
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
        broadcast_workspace_event(company_id, 'project_updated', data)
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
        broadcast_workspace_event(company_id, 'github_sync', data)
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
        broadcast_workspace_event(instance.company_id, 'dashboard_activity', data)
    except Exception as e:
        logger.warning(f"Error in audit_activity_realtime_broadcast: {e}")
