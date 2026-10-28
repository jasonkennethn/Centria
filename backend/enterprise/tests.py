import uuid
from decimal import Decimal
from django.test import TestCase
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient

from .models import (
    Company, Task, ApprovalRequest, BankBalance,
    StatutoryObligation, IntegrationConnector, AuditEvent
)


class TenantIsolationAndIndianEnterpriseTestCase(TestCase):
    """
    Comprehensive Tenant Isolation and Sovereign Operations Test Suite.
    Ensures Company A can never read, modify, or execute approvals on Company B's assets.
    """

    def setUp(self):
        self.client = APIClient()

        # Company A: Centria Technologies India Pvt Ltd (Bengaluru)
        self.company_a = Company.objects.create(
            name='Centria Technologies India Pvt Ltd',
            cin='U72900KA2024PTC189201',
            gstin='29AABCC1234F1Z5',
            pan='AABCC1234F',
            tan='BLRC12345D',
            roc_jurisdiction='ROC Bangalore (Karnataka)',
            registered_office='Embassy TechVillage, Bengaluru',
            is_active=True,
        )

        # Company B: Bharat Enterprises Ltd (Mumbai)
        self.company_b = Company.objects.create(
            name='Bharat Enterprises Ltd',
            cin='U74999MH2022PLC123456',
            gstin='27BBBBB1234B1Z9',
            pan='BBBBB1234B',
            tan='MUMC98765E',
            roc_jurisdiction='ROC Mumbai (Maharashtra)',
            registered_office='Bandra Kurla Complex, Mumbai',
            is_active=True,
        )

        # Company A Assets
        self.task_a = Task.objects.create(
            company=self.company_a,
            task_code='TSK-A-001',
            title='MCA Form AOC-4 Ratification',
            priority='CRITICAL',
            status='IN_PROGRESS',
            assignee_name='Director A',
            due_date='Nov 05, 2026',
        )

        self.approval_a = ApprovalRequest.objects.create(
            company=self.company_a,
            approval_code='APR-A-001',
            category='TREASURY_FX',
            title='AWS India Mumbai Data Residency Migration',
            amount_or_impact='₹48,50,000 / yr',
            status='PENDING',
            requested_by='CTO A',
        )

        self.bank_a = BankBalance.objects.create(
            company=self.company_a,
            bank_name='HDFC Bank',
            branch='Koramangala, Bengaluru',
            account_number_masked='•••• 8920',
            ifsc_code='HDFC0000240',
            balance_inr=Decimal('34215000.00'),
        )

        # Company B Assets
        self.task_b = Task.objects.create(
            company=self.company_b,
            task_code='TSK-B-999',
            title='Secret Acquisition Audit for Company B',
            priority='URGENT',
            status='TODO',
            assignee_name='Director B',
            due_date='Dec 01, 2026',
        )

        self.approval_b = ApprovalRequest.objects.create(
            company=self.company_b,
            approval_code='APR-B-999',
            category='LEGAL_SECRETARY',
            title='Hostile Takeover Bid Ratification',
            amount_or_impact='₹25,00,00,000',
            status='PENDING',
            requested_by='CEO B',
        )

    def test_overview_tenant_isolation(self):
        """Company A overview must strictly only compute Company A metrics."""
        response = self.client.get(
            reverse('overview'),
            HTTP_X_COMPANY_ID=str(self.company_a.id)
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertEqual(data['company']['cin'], 'U72900KA2024PTC189201')
        self.assertEqual(data['metrics']['total_cash_inr'], '34215000.00')

    def test_task_list_tenant_isolation(self):
        """Company A task listing must never reveal Company B tasks."""
        response = self.client.get(
            reverse('tasks'),
            HTTP_X_COMPANY_ID=str(self.company_a.id)
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        tasks = response.json()
        task_codes = [t['task_code'] for t in tasks]
        self.assertIn('TSK-A-001', task_codes)
        self.assertNotIn('TSK-B-999', task_codes)

    def test_cross_tenant_task_access_blocked(self):
        """Company A cannot access, modify, or delete Company B task."""
        # GET Company B task using Company A header -> MUST 404
        get_res = self.client.get(
            reverse('task_detail', kwargs={'task_id': self.task_b.id}),
            HTTP_X_COMPANY_ID=str(self.company_a.id)
        )
        self.assertEqual(get_res.status_code, status.HTTP_404_NOT_FOUND)

        # PATCH Company B task using Company A header -> MUST 404
        patch_res = self.client.patch(
            reverse('task_detail', kwargs={'task_id': self.task_b.id}),
            {'title': 'Compromised Title'},
            format='json',
            HTTP_X_COMPANY_ID=str(self.company_a.id)
        )
        self.assertEqual(patch_res.status_code, status.HTTP_404_NOT_FOUND)
        self.task_b.refresh_from_db()
        self.assertEqual(self.task_b.title, 'Secret Acquisition Audit for Company B')

        # DELETE Company B task using Company A header -> MUST 404
        del_res = self.client.delete(
            reverse('task_detail', kwargs={'task_id': self.task_b.id}),
            HTTP_X_COMPANY_ID=str(self.company_a.id)
        )
        self.assertEqual(del_res.status_code, status.HTTP_404_NOT_FOUND)
        self.assertTrue(Task.objects.filter(id=self.task_b.id).exists())

    def test_approval_list_tenant_isolation(self):
        """Company A approval listing must never reveal Company B approvals."""
        response = self.client.get(
            reverse('approvals'),
            HTTP_X_COMPANY_ID=str(self.company_a.id)
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        approvals = response.json()
        codes = [a['approval_code'] for a in approvals]
        self.assertIn('APR-A-001', codes)
        self.assertNotIn('APR-B-999', codes)

    def test_cross_tenant_approval_execution_blocked(self):
        """Company A cannot ratify or reject Company B approval request."""
        execute_res = self.client.post(
            reverse('approval_execute', kwargs={'approval_id': self.approval_b.id}),
            {'action': 'APPROVE', 'decision_note': 'Unauthorized biometric signature'},
            format='json',
            HTTP_X_COMPANY_ID=str(self.company_a.id)
        )
        self.assertEqual(execute_res.status_code, status.HTTP_404_NOT_FOUND)
        self.approval_b.refresh_from_db()
        self.assertEqual(self.approval_b.status, 'PENDING')
        self.assertFalse(self.approval_b.signature_hash)

    def test_approval_biometric_execution_and_merkle_audit(self):
        """Company A ratifying its own approval generates Merkle hash and AuditEvent."""
        execute_res = self.client.post(
            reverse('approval_execute', kwargs={'approval_id': self.approval_a.id}),
            {'action': 'APPROVE', 'decision_note': 'Approved by Director via Biometric Passkey'},
            format='json',
            HTTP_X_COMPANY_ID=str(self.company_a.id)
        )
        self.assertEqual(execute_res.status_code, status.HTTP_200_OK)
        self.approval_a.refresh_from_db()
        self.assertEqual(self.approval_a.status, 'EXECUTED')
        self.assertIsNotNone(self.approval_a.signature_hash)
        self.assertTrue(self.approval_a.signature_hash.startswith('0x'))

        # Verify audit event emitted
        audit = AuditEvent.objects.filter(
            company=self.company_a,
            block_hash=self.approval_a.signature_hash
        ).first()
        self.assertIsNotNone(audit)
        self.assertIn('Statutory Ratification', audit.action)
