from rest_framework import viewsets, permissions, status, views
from rest_framework.response import Response
from rest_framework.decorators import action
from .models import Policy, ComplianceItem, AuditLog, BoardDecision
from .serializers import (
    PolicySerializer, ComplianceItemSerializer,
    AuditLogSerializer, BoardDecisionSerializer
)

class PolicyViewSet(viewsets.ModelViewSet):
    serializer_class = PolicySerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        company_id = self.request.query_params.get('company_id')
        if company_id:
            return Policy.objects.filter(company__id=company_id)
        return Policy.objects.filter(company__owner=self.request.user)

    def perform_create(self, serializer):
        serializer.save(approved_by=self.request.user)


class ComplianceItemViewSet(viewsets.ModelViewSet):
    serializer_class = ComplianceItemSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        company_id = self.request.query_params.get('company_id')
        if company_id:
            return ComplianceItem.objects.filter(company__id=company_id)
        return ComplianceItem.objects.filter(company__owner=self.request.user)


class AuditLogViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = AuditLogSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        company_id = self.request.query_params.get('company_id')
        if company_id:
            return AuditLog.objects.filter(company__id=company_id)
        return AuditLog.objects.filter(company__owner=self.request.user)


class BoardDecisionViewSet(viewsets.ModelViewSet):
    serializer_class = BoardDecisionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        company_id = self.request.query_params.get('company_id')
        if company_id:
            return BoardDecision.objects.filter(company__id=company_id)
        return BoardDecision.objects.filter(company__owner=self.request.user)
