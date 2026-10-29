from django.core.management.base import BaseCommand
from django.utils import timezone
from core.models import Company, User, Role
from core.views import bootstrap_company_roles
from projects.models import Project, Task, Customer
from approvals.models import ApprovalRequest


class Command(BaseCommand):
    help = 'Seeds initial platform admin and demo data matching Centria preview.'

    def handle(self, *args, **options):
        # 1. Platform Admin
        admin_email = 'jasonkennethn@gmail.com'
        admin_user = User.objects.filter(email=admin_email).first()
        if not admin_user:
            admin_user = User.objects.create_superuser(
                email=admin_email,
                password='CentriaAdmin@2026!',
                full_name='Jason Kenneth',
                is_platform_admin=True,
                is_staff=True,
            )
            self.stdout.write(self.style.SUCCESS(f"Platform admin created: {admin_email}"))
        else:
            admin_user.is_platform_admin = True
            admin_user.is_staff = True
            admin_user.is_superuser = True
            admin_user.set_password('CentriaAdmin@2026!')
            admin_user.save()
            self.stdout.write(self.style.SUCCESS(f"Platform admin updated: {admin_email}"))

        # 2. Demo Company: Northstar Studio (from HTML preview)
        company, created = Company.objects.get_or_create(
            slug='northstar',
            defaults={
                'name': 'Northstar Studio',
                'plan': 'growth',
                'domain': 'northstar.io',
            }
        )
        roles = bootstrap_company_roles(company)
        owner_role = roles.get('Owner')
        pm_role = roles.get('Project Manager')

        # Link admin user to company too
        if not admin_user.company:
            admin_user.company = company
            admin_user.role = owner_role
            admin_user.save()

        # Create Priya Sharma (from the preview mock)
        priya, _ = User.objects.get_or_create(
            email='priya@northstar.io',
            defaults={
                'full_name': 'Priya Sharma',
                'company': company,
                'role': pm_role,
            }
        )
        priya.set_password('Northstar@2026!')
        priya.save()

        # Create Projects
        prj1, _ = Project.objects.get_or_create(
            company=company,
            key='POR',
            defaults={
                'name': 'Customer Portal Refresh',
                'description': 'Modernize client portal and feedback intake workflows.',
                'lead': priya,
                'status': 'active',
            }
        )

        prj2, _ = Project.objects.get_or_create(
            company=company,
            key='REL',
            defaults={
                'name': 'Release 1.4',
                'description': 'Core platform stability and performance improvements.',
                'lead': priya,
                'status': 'active',
            }
        )

        # Create Tasks matching the exact mockup
        Task.objects.get_or_create(
            project=prj1,
            task_number=1,
            defaults={
                'company': company,
                'title': 'Review customer feedback',
                'description': 'Synthesize recent user interviews and support tickets from portal refresh.',
                'task_type': 'task',
                'status': 'done',
                'priority': 'medium',
                'assignee': priya,
                'creator': priya,
            }
        )

        Task.objects.get_or_create(
            project=prj2,
            task_number=1,
            defaults={
                'company': company,
                'title': 'Confirm release checklist',
                'description': 'Verify all deployment gates and compliance signoffs are in order.',
                'task_type': 'task',
                'status': 'in_review',
                'priority': 'urgent',
                'assignee': priya,
                'creator': priya,
            }
        )

        Task.objects.get_or_create(
            project=prj1,
            task_number=2,
            defaults={
                'company': company,
                'title': 'Approve updated scope',
                'description': 'Client workspace adjustments for Q4 milestones.',
                'task_type': 'task',
                'status': 'todo',
                'priority': 'high',
                'assignee': priya,
                'creator': priya,
            }
        )

        # Create Pending Approval Request (from the preview mock)
        ApprovalRequest.objects.get_or_create(
            company=company,
            title='Release 1.4 Checklist Sign-off',
            defaults={
                'description': 'Final release gate approval for version 1.4 production deployment.',
                'category': 'release',
                'status': 'pending',
                'requester': priya,
                'assigned_approver': admin_user,
            }
        )

        # Create Demo Customers
        Customer.objects.get_or_create(
            company=company,
            name='Acme Corp',
            defaults={
                'email': 'contact@acme.corp',
                'company_name': 'Acme Global',
                'status': 'active',
                'notes': 'Enterprise pilot customer.',
            }
        )

        self.stdout.write(self.style.SUCCESS("Demo workspace 'Northstar Studio' seeded successfully!"))
