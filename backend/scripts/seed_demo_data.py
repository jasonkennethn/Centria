"""
Seed script to populate a sample company workspace for testing and demo.
"""

import os
import sys
from pathlib import Path

# Add backend directory to sys.path
BASE_DIR = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(BASE_DIR))

import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'centria.settings')
django.setup()

from django.contrib.auth import get_user_model
from apps.companies.models import Company, Branch, Department, CompanyRole
from apps.people.models import Employee, Attendance, LeaveRequest, OnboardingTask
from apps.finance.models import FinancialAccount, Invoice, Expense
from apps.operations.models import Product, Project, Task, Milestone
from apps.governance.models import Policy, ComplianceItem, AuditLog
from apps.workflows.models import Workflow, ApprovalRequest
from apps.documents.models import Document, DocumentAnalysis
from datetime import date, timedelta
from decimal import Decimal

User = get_user_model()

def seed_data():
    print("Starting Centria database seeding...")

    # 1. Create Super Admin User
    user, created = User.objects.get_or_create(
        email="admin@celarox.com",
        defaults={
            "full_name": "Jason Kenneth",
            "phone_number": "+1 (555) 019-2834",
            "role": "SUPER_ADMIN",
            "is_email_verified": True,
            "is_staff": True,
            "is_superuser": True
        }
    )
    user.set_password("Admin@Centria2026")
    user.is_email_verified = True
    user.save()
    if created:
        print(f"Created Admin User: {user.email}")
    else:
        print(f"Updated Admin User password: {user.email}")

    # 2. Create Company
    company, created = Company.objects.get_or_create(
        slug="centria-technologies",
        defaults={
            "name": "Centria Technologies Inc.",
            "legal_name": "Centria Technologies Corporation",
            "tax_id": "US-EIN-9481920",
            "industry": "Artificial Intelligence & Enterprise SaaS",
            "team_size": "10-50",
            "currency": "USD",
            "country": "United States",
            "timezone": "America/New_York",
            "owner": user,
            "is_genesis_completed": True
        }
    )
    print(f"Company: {company.name}")

    # 3. Create Branches & Departments
    hq, _ = Branch.objects.get_or_create(
        company=company,
        name="Global Headquarters",
        defaults={"code": "HQ-NYC", "city": "New York", "country": "United States", "is_headquarters": True}
    )

    eng_dept, _ = Department.objects.get_or_create(company=company, code="ENG", defaults={"name": "Engineering & AI Systems", "branch": hq})
    ops_dept, _ = Department.objects.get_or_create(company=company, code="OPS", defaults={"name": "Operations & People", "branch": hq})
    fin_dept, _ = Department.objects.get_or_create(company=company, code="FIN", defaults={"name": "Finance & Accounting", "branch": hq})
    mkt_dept, _ = Department.objects.get_or_create(company=company, code="MKT", defaults={"name": "Growth & Client Success", "branch": hq})

    # Roles
    admin_role, _ = CompanyRole.objects.get_or_create(company=company, name="Executive Admin", defaults={"permissions_json": {"all": True}})
    mgr_role, _ = CompanyRole.objects.get_or_create(company=company, name="Department Manager", defaults={"permissions_json": {"manage": True}})
    staff_role, _ = CompanyRole.objects.get_or_create(company=company, name="Senior Engineer", defaults={"permissions_json": {"view": True, "edit": True}})

    # 4. Employees
    emp1, _ = Employee.objects.get_or_create(
        company=company,
        email="alex.morgan@centria.io",
        defaults={
            "first_name": "Alex",
            "last_name": "Morgan",
            "job_title": "Lead AI Architect",
            "department": eng_dept,
            "company_role": staff_role,
            "employment_type": "FULL_TIME",
            "salary_amount": Decimal("145000.00"),
            "joining_date": date(2025, 1, 15)
        }
    )
    emp2, _ = Employee.objects.get_or_create(
        company=company,
        email="sarah.chen@centria.io",
        defaults={
            "first_name": "Sarah",
            "last_name": "Chen",
            "job_title": "Operations & HR Director",
            "department": ops_dept,
            "company_role": mgr_role,
            "employment_type": "FULL_TIME",
            "salary_amount": Decimal("120000.00"),
            "joining_date": date(2025, 2, 1)
        }
    )

    # 5. Financial Account, Invoices, Expenses
    bank_acc, _ = FinancialAccount.objects.get_or_create(
        company=company,
        name="Silicon Valley Bank - Operating",
        defaults={"account_type": "BANK", "balance": Decimal("84200.00"), "account_number_last4": "8821"}
    )

    Invoice.objects.get_or_create(
        company=company,
        invoice_number="INV-2026-001",
        defaults={
            "client_name": "Vertex Global Capital",
            "client_email": "billing@vertexcapital.com",
            "issue_date": date.today() - timedelta(days=5),
            "due_date": date.today() + timedelta(days=25),
            "subtotal": Decimal("15000.00"),
            "tax_rate": Decimal("0.00"),
            "total_amount": Decimal("15000.00"),
            "status": "SENT",
            "line_items_json": [{"description": "Centria AI Enterprise Pilot & Integration", "quantity": 1, "rate": 15000}]
        }
    )

    Expense.objects.get_or_create(
        company=company,
        title="AWS & Neon Cloud Infrastructure Q1",
        defaults={
            "vendor": "Amazon Web Services",
            "category": "SOFTWARE",
            "amount": Decimal("1250.00"),
            "expense_date": date.today() - timedelta(days=10),
            "status": "APPROVED",
            "submitted_by": user
        }
    )

    # 6. Projects & Tasks
    product, _ = Product.objects.get_or_create(company=company, name="Centria AI Platform Core", defaults={"status": "ACTIVE"})
    proj, _ = Project.objects.get_or_create(
        company=company,
        name="Q1 Multi-Platform Enterprise Rollout",
        defaults={
            "product": product,
            "description": "Deploy Flutter web, mobile apps and Neon S3 integrations",
            "status": "IN_PROGRESS",
            "delay_risk_level": "LOW",
            "delay_risk_score": 12
        }
    )

    Task.objects.get_or_create(
        company=company,
        project=proj,
        title="Verify Neon S3 Multimodal Receipt Ingestion",
        defaults={"priority": "HIGH", "status": "DONE", "estimated_hours": Decimal("4.0")}
    )
    Task.objects.get_or_create(
        company=company,
        project=proj,
        title="Finalize Brevo Transactional Email Templates",
        defaults={"priority": "URGENT", "status": "IN_PROGRESS", "estimated_hours": Decimal("3.0")}
    )

    # 7. Approvals
    ApprovalRequest.objects.get_or_create(
        company=company,
        title="Vendor Invoice Sign-off: Vertex Integration",
        defaults={
            "module": "Finance",
            "description": "Approve outgoing milestone payment of $4,500 to backend contractor",
            "requested_by": user,
            "assigned_to": user,
            "status": "PENDING"
        }
    )

    # 8. Policies
    Policy.objects.get_or_create(
        company=company,
        title="Global Information Security Policy",
        defaults={
            "category": "Security",
            "content": "All customer data must be encrypted in transit and at rest using AES-256 and TLS 1.3.",
            "status": "PUBLISHED",
            "approved_by": user
        }
    )

    print("Centria database seeded successfully with realistic enterprise data!")

if __name__ == '__main__':
    seed_data()
