from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.decorators import action
from .models import Workflow, WorkflowExecution, ApprovalRequest
from .serializers import (
    WorkflowSerializer, WorkflowExecutionSerializer, ApprovalRequestSerializer
)
from apps.authentication.services.brevo_service import send_brevo_email

class WorkflowViewSet(viewsets.ModelViewSet):
    serializer_class = WorkflowSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        company_id = self.request.query_params.get('company_id')
        if company_id:
            return Workflow.objects.filter(company__id=company_id)
        return Workflow.objects.filter(company__owner=self.request.user)

    @action(detail=True, methods=['post'])
    def execute(self, request, pk=None):
        workflow = self.get_object()
        workflow.execution_count += 1
        workflow.save()

        # Record Execution
        execution = WorkflowExecution.objects.create(
            workflow=workflow,
            triggered_by=request.user,
            status='SUCCESS',
            context_data=request.data.get('context', {}),
            log_output=f"Executed workflow '{workflow.name}' with trigger '{workflow.trigger_type}'."
        )

        return Response({
            'message': f"Workflow '{workflow.name}' triggered successfully.",
            'execution': WorkflowExecutionSerializer(execution).data
        })


class WorkflowExecutionViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = WorkflowExecutionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        workflow_id = self.request.query_params.get('workflow_id')
        if workflow_id:
            return WorkflowExecution.objects.filter(workflow__id=workflow_id)
        return WorkflowExecution.objects.filter(workflow__company__owner=self.request.user)


class ApprovalRequestViewSet(viewsets.ModelViewSet):
    """1-Click Executive Approvals Engine."""

    serializer_class = ApprovalRequestSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        company_id = self.request.query_params.get('company_id')
        status_filter = self.request.query_params.get('status')
        qs = ApprovalRequest.objects.filter(company__owner=self.request.user)
        if company_id:
            qs = qs.filter(company__id=company_id)
        if status_filter:
            qs = qs.filter(status=status_filter.upper())
        return qs

    @action(detail=True, methods=['post'])
    def approve(self, request, pk=None):
        approval = self.get_object()
        approval.status = 'APPROVED'
        approval.reviewer_comment = request.data.get('comments', '1-Click approved from Executive Cockpit.')
        approval.save()
        return Response({'message': f"Approval '{approval.title}' approved successfully.", 'approval': ApprovalRequestSerializer(approval).data})

    @action(detail=True, methods=['post'])
    def reject(self, request, pk=None):
        approval = self.get_object()
        approval.status = 'REJECTED'
        approval.reviewer_comment = request.data.get('comments', 'Rejected by executive.')
        approval.save()
        return Response({'message': f"Approval '{approval.title}' rejected.", 'approval': ApprovalRequestSerializer(approval).data})
