import re
from rest_framework import viewsets, permissions, status, views
from rest_framework.response import Response
from django.utils.text import slugify
from .models import Company, Branch, Department, CompanyRole
from .serializers import (
    CompanySerializer, BranchSerializer, DepartmentSerializer,
    CompanyRoleSerializer, GenesisInputSerializer
)
from apps.ai_engine.services.gemini_service import generate_company_genesis
from apps.governance.models import Policy
from apps.workflows.models import Workflow
from apps.operations.models import Project, Task

class CompanyViewSet(viewsets.ModelViewSet):
    serializer_class = CompanySerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Company.objects.filter(owner=self.request.user)

    def perform_create(self, serializer):
        name = serializer.validated_data.get('name', 'My Company')
        slug = slugify(name)
        # ensure unique slug
        base_slug = slug
        count = 1
        while Company.objects.filter(slug=slug).exists():
            slug = f"{base_slug}-{count}"
            count += 1
        serializer.save(owner=self.request.user, slug=slug)


class BranchViewSet(viewsets.ModelViewSet):
    serializer_class = BranchSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        company_id = self.request.query_params.get('company_id')
        if company_id:
            return Branch.objects.filter(company__id=company_id, company__owner=self.request.user)
        return Branch.objects.filter(company__owner=self.request.user)


class DepartmentViewSet(viewsets.ModelViewSet):
    serializer_class = DepartmentSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        company_id = self.request.query_params.get('company_id')
        if company_id:
            return Department.objects.filter(company__id=company_id, company__owner=self.request.user)
        return Department.objects.filter(company__owner=self.request.user)


class CompanyRoleViewSet(viewsets.ModelViewSet):
    serializer_class = CompanyRoleSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        company_id = self.request.query_params.get('company_id')
        if company_id:
            return CompanyRole.objects.filter(company__id=company_id, company__owner=self.request.user)
        return CompanyRole.objects.filter(company__owner=self.request.user)


class CompanyGenesisView(views.APIView):
    """
    60-Second Company Genesis Wizard:
    Creates company and auto-provisions departments, roles, policies, workflows, and initial project tasks.
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = GenesisInputSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        data = serializer.validated_data
        company_name = data['company_name']
        industry = data['industry']
        team_size = data['team_size']
        description = data.get('description', '')
        currency = data.get('currency', 'USD')
        country = data.get('country', 'United States')

        # 1. Create the Company Entity
        slug = slugify(company_name)
        base_slug = slug
        count = 1
        while Company.objects.filter(slug=slug).exists():
            slug = f"{base_slug}-{count}"
            count += 1

        company = Company.objects.create(
            name=company_name,
            slug=slug,
            industry=industry,
            team_size=team_size,
            currency=currency,
            country=country,
            owner=request.user,
            is_genesis_completed=True
        )

        # 2. Create Default Branch (HQ)
        hq = Branch.objects.create(
            company=company,
            name=f"{company_name} Headquarters",
            code="HQ-01",
            city="Global",
            country=country,
            is_headquarters=True
        )

        # 3. Generate AI Genesis blueprint via Gemini
        genesis_data = generate_company_genesis(company_name, industry, team_size, description)

        # 4. Provision Departments
        created_depts = []
        for d in genesis_data.get('departments', []):
            dept = Department.objects.create(
                company=company,
                branch=hq,
                name=d.get('name', 'Department'),
                code=d.get('code', 'GEN'),
                description=d.get('description', '')
            )
            created_depts.append(dept.name)

        # 5. Provision Roles
        for r in genesis_data.get('roles', []):
            CompanyRole.objects.create(
                company=company,
                name=r.get('name', 'Role'),
                description=r.get('description', ''),
                permissions_json={"all": True} if "Admin" in r.get('name', '') else {"view": True, "edit": True}
            )

        # 6. Provision Policies
        for p in genesis_data.get('policies', []):
            Policy.objects.create(
                company=company,
                title=p.get('title', 'Corporate Policy'),
                category=p.get('category', 'General'),
                content=p.get('summary', 'Standard operational compliance guidelines.'),
                status='Published',
                approved_by=request.user
            )

        # 7. Provision Workflows
        for w in genesis_data.get('workflows', []):
            Workflow.objects.create(
                company=company,
                name=w.get('name', 'Workflow'),
                trigger_type=w.get('trigger', 'MANUAL'),
                actions_json={"action": w.get('action', 'NOTIFY')},
                is_active=True
            )

        # 8. Provision Initial Projects & Tasks
        for proj in genesis_data.get('initial_projects', []):
            project = Project.objects.create(
                company=company,
                name=proj.get('name', 'Foundational Launch'),
                description=proj.get('description', 'Initial company roadmap'),
                status='InProgress'
            )
            for t in proj.get('tasks', []):
                Task.objects.create(
                    company=company,
                    project=project,
                    title=t.get('title', 'Launch Task'),
                    priority=t.get('priority', 'Medium'),
                    estimated_hours=t.get('hours', 4),
                    status='Todo'
                )

        return Response({
            'message': f"Company '{company_name}' provisioned successfully via 60-Second Genesis.",
            'company': CompanySerializer(company).data,
            'genesis_summary': {
                'departments_created': len(created_depts),
                'roles_created': len(genesis_data.get('roles', [])),
                'policies_created': len(genesis_data.get('policies', [])),
                'workflows_created': len(genesis_data.get('workflows', [])),
            }
        }, status=status.HTTP_201_CREATED)
