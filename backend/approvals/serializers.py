from rest_framework import serializers
from core.serializers import UserSerializer
from approvals.models import ApprovalRequest


class ApprovalRequestSerializer(serializers.ModelSerializer):
    requester_details = UserSerializer(source='requester', read_only=True)
    assigned_approver_details = UserSerializer(source='assigned_approver', read_only=True)
    decided_by_details = UserSerializer(source='decided_by', read_only=True)

    class Meta:
        model = ApprovalRequest
        fields = [
            'id', 'company', 'title', 'description', 'category', 'status',
            'requester', 'requester_details',
            'assigned_approver', 'assigned_approver_details',
            'target_resource_type', 'target_resource_id',
            'decision_note', 'decided_at', 'decided_by', 'decided_by_details',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'company', 'requester', 'status', 'decided_at', 'decided_by', 'created_at', 'updated_at']
