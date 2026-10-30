from rest_framework import viewsets, permissions, views, status, exceptions
from rest_framework.response import Response
from rest_framework.decorators import action
from django.db.models import Count, Q
from projects.models import Project, Task, TaskComment, Customer
from projects.serializers import (
    ProjectSerializer,
    TaskSerializer,
    TaskCommentSerializer,
    CustomerSerializer,
)
from approvals.models import ApprovalRequest
from audit.models import log_activity, AuditLog


class ProjectViewSet(viewsets.ModelViewSet):
    serializer_class = ProjectSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        if not self.request.company:
            return Project.objects.none()
        return Project.objects.filter(company=self.request.company).annotate(
            task_count=Count('tasks'),
            open_task_count=Count('tasks', filter=~Q(tasks__status='done'))
        ).select_related('lead')

    def perform_create(self, serializer):
        lead = serializer.validated_data.get('lead')
        if lead and lead.company_id and lead.company_id != self.request.company.id:
            raise exceptions.PermissionDenied("Selected lead must belong to your company.")
        project = serializer.save(company=self.request.company)
        log_activity(
            company=self.request.company,
            user=self.request.user,
            action='CREATE',
            resource_type='project',
            resource_id=project.id,
            description=f"Project '{project.name}' created by {self.request.user.email}"
        )


class TaskViewSet(viewsets.ModelViewSet):
    serializer_class = TaskSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        if not self.request.company:
            return Task.objects.none()
        qs = Task.objects.filter(company=self.request.company).select_related('project', 'assignee', 'creator')
        
        project_id = self.request.query_params.get('project')
        if project_id:
            qs = qs.filter(project_id=project_id)
            
        status_filter = self.request.query_params.get('status')
        if status_filter:
            qs = qs.filter(status=status_filter)
            
        assignee_filter = self.request.query_params.get('assignee')
        if assignee_filter:
            if assignee_filter == 'me':
                qs = qs.filter(assignee=self.request.user)
            else:
                qs = qs.filter(assignee_id=assignee_filter)
                
        return qs

    def perform_create(self, serializer):
        project = serializer.validated_data.get('project')
        if project and project.company_id != self.request.company.id:
            raise exceptions.PermissionDenied("Project does not belong to your company.")

        assignee = serializer.validated_data.get('assignee')
        if assignee and assignee.company_id and assignee.company_id != self.request.company.id:
            raise exceptions.PermissionDenied("Assignee does not belong to your company.")

        task = serializer.save(company=self.request.company, creator=self.request.user)
        log_activity(
            company=self.request.company,
            user=self.request.user,
            action='CREATE',
            resource_type='task',
            resource_id=task.id,
            description=f"Task '{task.key}: {task.title}' created."
        )

    def perform_update(self, serializer):
        project = serializer.validated_data.get('project')
        if project and project.company_id != self.request.company.id:
            raise exceptions.PermissionDenied("Project does not belong to your company.")

        assignee = serializer.validated_data.get('assignee')
        if assignee and assignee.company_id and assignee.company_id != self.request.company.id:
            raise exceptions.PermissionDenied("Assignee does not belong to your company.")

        old_status = self.get_object().status
        task = serializer.save()
        if old_status != task.status:
            log_activity(
                company=self.request.company,
                user=self.request.user,
                action='UPDATE',
                resource_type='task',
                resource_id=task.id,
                description=f"Task '{task.key}' status updated from {old_status} to {task.status}"
            )

    @action(detail=True, methods=['post'], url_path='comments')
    def add_comment(self, request, pk=None):
        task = self.get_object()
        if task.company_id != request.company.id:
            return Response({'error': 'Permission denied.'}, status=status.HTTP_403_FORBIDDEN)
        content = request.data.get('content', '').strip()
        if not content:
            return Response({'error': 'Comment content cannot be empty'}, status=status.HTTP_400_BAD_REQUEST)
        comment = TaskComment.objects.create(
            task=task,
            author=request.user,
            content=content
        )
        return Response(TaskCommentSerializer(comment).data, status=status.HTTP_201_CREATED)


class CustomerViewSet(viewsets.ModelViewSet):
    serializer_class = CustomerSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        if not self.request.company:
            return Customer.objects.none()
        return Customer.objects.filter(company=self.request.company)

    def perform_create(self, serializer):
        customer = serializer.save(company=self.request.company)
        log_activity(
            company=self.request.company,
            user=self.request.user,
            action='CREATE',
            resource_type='customer',
            resource_id=customer.id,
            description=f"Customer '{customer.name}' added."
        )


class DashboardMyDayView(views.APIView):
    """Aggregates workspace metrics, next steps, and pending approvals for My Day dashboard."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        company = request.company
        user = request.user
        if not company:
            return Response({'error': 'No company active'}, status=status.HTTP_400_BAD_REQUEST)

        active_projects_count = Project.objects.filter(company=company, status='active').count()
        total_open_tasks = Task.objects.filter(company=company).exclude(status='done').count()
        urgent_tasks_count = Task.objects.filter(company=company, priority__in=['high', 'urgent']).exclude(status='done').count()
        pending_approvals_count = ApprovalRequest.objects.filter(company=company, status='pending').count()

        # My Next Steps (assigned to me and not done)
        my_tasks = Task.objects.filter(
            company=company,
            assignee=user
        ).exclude(status='done').order_by('due_date', '-created_at')[:5]

        # Recent activities
        recent_logs = AuditLog.objects.filter(company=company).order_by('-timestamp')[:8]
        activity_items = [{
            'id': str(log.id),
            'action': log.action,
            'description': log.description,
            'user': log.user.full_name if log.user else 'System',
            'timestamp': log.timestamp.isoformat(),
        } for log in recent_logs]

        return Response({
            'workspace_name': company.name,
            'user_name': user.full_name,
            'metrics': {
                'active_projects': active_projects_count,
                'open_issues': total_open_tasks,
                'urgent_issues': urgent_tasks_count,
                'pending_reviews': pending_approvals_count,
            },
            'next_steps': TaskSerializer(my_tasks, many=True).data,
            'recent_activity': activity_items,
        })
