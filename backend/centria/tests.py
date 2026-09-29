from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIClient
from rest_framework import status
from django.contrib.auth import get_user_model
from apps.companies.models import Company, Department
from apps.people.models import Employee
from apps.finance.models import FinancialAccount, Invoice
from apps.operations.models import Project, Task

User = get_user_model()

class CentriaBackendTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            email="tester@celarox.com",
            password="Password@123",
            full_name="Centria Tester",
            role="SUPER_ADMIN",
            is_email_verified=True
        )
        # Obtain JWT Token
        res = self.client.post('/api/auth/login/', {
            'email': 'tester@celarox.com',
            'password': 'Password@123'
        })
        self.token = res.data['tokens']['access']
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {self.token}')

        # Create base company
        self.company = Company.objects.create(
            name="Test Corp",
            slug="test-corp",
            owner=self.user,
            is_genesis_completed=True
        )

    def test_health_check(self):
        res = self.client.get('/api/health/')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.json()['status'], 'healthy')

    def test_company_workspace_list(self):
        res = self.client.get('/api/companies/workspaces/')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertGreaterEqual(len(res.data), 1)

    def test_genesis_wizard_endpoint(self):
        res = self.client.post('/api/companies/genesis/', {
            'company_name': 'Quantum Logic AI',
            'industry': 'AI SaaS',
            'team_size': '5-15',
            'description': 'Building next-gen company orchestration'
        })
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        self.assertIn('genesis_summary', res.data)

    def test_people_and_leave_workflow(self):
        emp_res = self.client.post('/api/people/employees/', {
            'company': str(self.company.id),
            'first_name': 'Jane',
            'last_name': 'Doe',
            'email': 'jane.doe@testcorp.com',
            'job_title': 'Senior Systems Architect'
        })
        self.assertEqual(emp_res.status_code, status.HTTP_201_CREATED)
        emp_id = emp_res.data['id']

        leave_res = self.client.post('/api/people/leave-requests/', {
            'company': str(self.company.id),
            'employee': emp_id,
            'leave_type': 'PAID',
            'start_date': '2026-10-01',
            'end_date': '2026-10-03',
            'reason': 'Attending AI Tech Conference'
        })
        self.assertEqual(leave_res.status_code, status.HTTP_201_CREATED)

    def test_finance_summary_and_invoices(self):
        acc = FinancialAccount.objects.create(
            company=self.company,
            name="Test Bank Account",
            balance=50000.00
        )
        inv_res = self.client.post('/api/finance/invoices/', {
            'company': str(self.company.id),
            'invoice_number': 'INV-TEST-01',
            'client_name': 'Acme Global',
            'client_email': 'acme@test.com',
            'issue_date': '2026-09-01',
            'due_date': '2026-09-30',
            'subtotal': 10000.00,
            'tax_rate': 0.00,
            'total_amount': 10000.00,
            'status': 'DRAFT'
        })
        self.assertEqual(inv_res.status_code, status.HTTP_201_CREATED)

        summary_res = self.client.get('/api/finance/summary/')
        self.assertEqual(summary_res.status_code, status.HTTP_200_OK)
        self.assertIn('total_cash_balance', summary_res.data)

    def test_executive_morning_brief_ai(self):
        res = self.client.post('/api/ai/morning-brief/', {
            'company_data': {
                'company_name': 'Test Corp',
                'cash_balance': 92000,
                'runway_months': 11.2,
                'pending_approvals': 2,
                'active_projects': 3
            }
        }, format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertIn('headline', res.data)
        self.assertIn('action_cards', res.data)
