from rest_framework import serializers
from .models import Company, Branch, Department, CompanyRole

class BranchSerializer(serializers.ModelSerializer):
    class Meta:
        model = Branch
        fields = '__all__'
        read_only_fields = ('id', 'created_at')


class DepartmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Department
        fields = '__all__'
        read_only_fields = ('id', 'created_at')


class CompanyRoleSerializer(serializers.ModelSerializer):
    class Meta:
        model = CompanyRole
        fields = '__all__'
        read_only_fields = ('id', 'created_at')


class CompanySerializer(serializers.ModelSerializer):
    branches = BranchSerializer(many=True, read_only=True)
    departments = DepartmentSerializer(many=True, read_only=True)
    custom_roles = CompanyRoleSerializer(many=True, read_only=True)

    class Meta:
        model = Company
        fields = (
            'id', 'name', 'slug', 'legal_name', 'tax_id', 'industry',
            'team_size', 'logo_url', 'currency', 'country', 'timezone',
            'fiscal_year_start_month', 'owner', 'is_genesis_completed',
            'is_active', 'created_at', 'updated_at',
            'branches', 'departments', 'custom_roles'
        )
        read_only_fields = ('id', 'owner', 'created_at', 'updated_at')


class GenesisInputSerializer(serializers.Serializer):
    company_name = serializers.CharField(max_length=255)
    industry = serializers.CharField(max_length=100)
    team_size = serializers.CharField(max_length=50)
    description = serializers.CharField(max_length=1000, required=False, allow_blank=True)
    currency = serializers.CharField(max_length=10, default='USD')
    country = serializers.CharField(max_length=100, default='United States')
