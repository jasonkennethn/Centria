from rest_framework import serializers
from .models import FinancialAccount, Invoice, Expense, Transaction

class FinancialAccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = FinancialAccount
        fields = '__all__'
        read_only_fields = ('id', 'created_at', 'updated_at')


class InvoiceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Invoice
        fields = '__all__'
        read_only_fields = ('id', 'created_at', 'updated_at')


class ExpenseSerializer(serializers.ModelSerializer):
    submitted_by_name = serializers.ReadOnlyField(source='submitted_by.full_name')

    class Meta:
        model = Expense
        fields = '__all__'
        read_only_fields = ('id', 'created_at')


class TransactionSerializer(serializers.ModelSerializer):
    account_name = serializers.ReadOnlyField(source='account.name')

    class Meta:
        model = Transaction
        fields = '__all__'
        read_only_fields = ('id', 'created_at')
