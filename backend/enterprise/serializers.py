from rest_framework import serializers
from .models import (
    Company, Membership, Task, ApprovalRequest, BankBalance,
    ExpenseCard, StatutoryObligation, IntegrationConnector, AuditEvent
)


class CompanySerializer(serializers.ModelSerializer):
    class Meta:
        model = Company
        fields = [
            'id', 'name', 'cin', 'gstin', 'pan', 'tan',
            'roc_jurisdiction', 'incorporation_date', 'registered_office',
            'is_active', 'created_at', 'updated_at'
        ]


class MembershipSerializer(serializers.ModelSerializer):
    user_email = serializers.EmailField(source='user.email', read_only=True)
    company_name = serializers.CharField(source='company.name', read_only=True)

    class Meta:
        model = Membership
        fields = [
            'id', 'user_email', 'company', 'company_name',
            'role', 'din_number', 'is_active', 'created_at'
        ]


class TaskSerializer(serializers.ModelSerializer):
    class Meta:
        model = Task
        fields = [
            'id', 'task_code', 'title', 'subtitle',
            'priority', 'status', 'assignee_name',
            'due_date', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class ApprovalRequestSerializer(serializers.ModelSerializer):
    class Meta:
        model = ApprovalRequest
        fields = [
            'id', 'approval_code', 'title', 'category',
            'requested_by', 'amount_or_impact', 'status',
            'decision_note', 'ratified_by', 'signature_hash',
            'date_display', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class BankBalanceSerializer(serializers.ModelSerializer):
    class Meta:
        model = BankBalance
        fields = [
            'id', 'bank_name', 'account_number_masked', 'ifsc_code',
            'branch', 'balance_inr', 'hub', 'is_primary', 'last_synced'
        ]


class ExpenseCardSerializer(serializers.ModelSerializer):
    class Meta:
        model = ExpenseCard
        fields = [
            'id', 'department', 'card_last4', 'cardholder_name',
            'monthly_limit_inr', 'current_spend_inr', 'is_active'
        ]


class StatutoryObligationSerializer(serializers.ModelSerializer):
    class Meta:
        model = StatutoryObligation
        fields = [
            'id', 'authority', 'form_name', 'description',
            'due_date', 'status', 'liability_inr', 'ack_number'
        ]


class IntegrationConnectorSerializer(serializers.ModelSerializer):
    class Meta:
        model = IntegrationConnector
        fields = [
            'id', 'provider', 'display_name', 'status',
            'uptime_sla', 'events_count_24h', 'last_sync'
        ]


class AuditEventSerializer(serializers.ModelSerializer):
    class Meta:
        model = AuditEvent
        fields = [
            'id', 'block_height', 'block_hash', 'action',
            'actor', 'details', 'timestamp_display', 'created_at'
        ]
