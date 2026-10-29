from django.utils import timezone
from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.decorators import action
from approvals.models import ApprovalRequest
from approvals.serializers import ApprovalRequestSerializer
from audit.models import log_activity


class ApprovalRequestViewSet(viewsets.ModelViewSet):
    serializer_class = ApprovalRequestSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        if not self.request.company:
            return ApprovalRequest.objects.none()
        qs = ApprovalRequest.objects.filter(company=self.request.company).select_related('requester', 'assigned_approver', 'decided_by')
        
        status_param = self.request.query_params.get('status')
        if status_param:
            qs = qs.filter(status=status_param)
            
        category_param = self.request.query_params.get('category')
        if category_param:
            qs = qs.filter(category=category_param)
            
        assigned_to_me = self.request.query_params.get('assigned_to_me')
        if assigned_to_me in ('true', '1'):
            qs = qs.filter(assigned_approver=self.request.user)
            
        return qs

    def perform_create(self, serializer):
        req = serializer.save(company=self.request.company, requester=self.request.user)
        log_activity(
            company=self.request.company,
            user=self.request.user,
            action='CREATE',
            resource_type='approval',
            resource_id=req.id,
            description=f"Approval request '{req.title}' submitted for category {req.category}."
        )

    @action(detail=True, methods=['post'])
    def approve(self, request, pk=None):
        req = self.get_object()
        if req.status != 'pending':
            return Response({'error': f'Request is already {req.status}'}, status=status.HTTP_400_BAD_REQUEST)

        note = request.data.get('decision_note', '').strip()
        req.status = 'approved'
        req.decision_note = note
        req.decided_by = request.user
        req.decided_at = timezone.now()
        req.save(update_fields=['status', 'decision_note', 'decided_by', 'decided_at'])

        log_activity(
            company=request.company,
            user=request.user,
            action='APPROVE',
            resource_type='approval',
            resource_id=req.id,
            description=f"Approval '{req.title}' APPROVED by {request.user.email}."
        )

        return Response(ApprovalRequestSerializer(req).data)

    @action(detail=True, methods=['post'])
    def reject(self, request, pk=None):
        req = self.get_object()
        if req.status != 'pending':
            return Response({'error': f'Request is already {req.status}'}, status=status.HTTP_400_BAD_REQUEST)

        note = request.data.get('decision_note', '').strip()
        req.status = 'rejected'
        req.decision_note = note
        req.decided_by = request.user
        req.decided_at = timezone.now()
        req.save(update_fields=['status', 'decision_note', 'decided_by', 'decided_at'])

        log_activity(
            company=request.company,
            user=request.user,
            action='REJECT',
            resource_type='approval',
            resource_id=req.id,
            description=f"Approval '{req.title}' REJECTED by {request.user.email}."
        )

        return Response(ApprovalRequestSerializer(req).data)
