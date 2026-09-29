from rest_framework import serializers
from .models import Workflow, WorkflowExecution, ApprovalRequest

class WorkflowSerializer(serializers.ModelSerializer):
    class Meta:
        model = Workflow
        fields = '__all__'
        read_only_fields = ('id', 'execution_count', 'created_at', 'updated_at')


class WorkflowExecutionSerializer(serializers.ModelSerializer):
    workflow_name = serializers.ReadOnlyField(source='workflow.name')
    triggered_by_name = serializers.ReadOnlyField(source='triggered_by.full_name')

    class Meta:
        model = WorkflowExecution
        fields = '__all__'
        read_only_fields = ('id', 'executed_at')


class ApprovalRequestSerializer(serializers.ModelSerializer):
    requested_by_name = serializers.ReadOnlyField(source='requested_by.full_name')
    assigned_to_name = serializers.ReadOnlyField(source='assigned_to.full_name')

    class Meta:
        model = ApprovalRequest
        fields = '__all__'
        read_only_fields = ('id', 'created_at', 'updated_at')
