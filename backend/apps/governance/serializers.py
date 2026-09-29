from rest_framework import serializers
from .models import Policy, ComplianceItem, AuditLog, BoardDecision

class PolicySerializer(serializers.ModelSerializer):
    approved_by_name = serializers.ReadOnlyField(source='approved_by.full_name')

    class Meta:
        model = Policy
        fields = '__all__'
        read_only_fields = ('id', 'created_at', 'updated_at')


class ComplianceItemSerializer(serializers.ModelSerializer):
    assigned_to_name = serializers.ReadOnlyField(source='assigned_to.full_name')

    class Meta:
        model = ComplianceItem
        fields = '__all__'
        read_only_fields = ('id', 'created_at', 'updated_at')


class AuditLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = AuditLog
        fields = '__all__'
        read_only_fields = ('id', 'timestamp')


class BoardDecisionSerializer(serializers.ModelSerializer):
    class Meta:
        model = BoardDecision
        fields = '__all__'
        read_only_fields = ('id', 'created_at')
