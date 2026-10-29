from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django.contrib.auth.password_validation import validate_password
from core.models import Company, User, Role, PasswordResetOTP


class RoleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Role
        fields = ['id', 'name', 'description', 'is_system', 'permissions']


class CompanySerializer(serializers.ModelSerializer):
    class Meta:
        model = Company
        fields = ['id', 'name', 'slug', 'domain', 'logo_url', 'plan', 'is_active', 'created_at']
        read_only_fields = ['id', 'created_at']


class UserSerializer(serializers.ModelSerializer):
    role_details = RoleSerializer(source='role', read_only=True)
    company_details = CompanySerializer(source='company', read_only=True)

    class Meta:
        model = User
        fields = [
            'id', 'email', 'full_name', 'avatar_url', 'company', 'company_details',
            'role', 'role_details', 'is_platform_admin', 'is_staff', 'is_active', 'date_joined'
        ]
        read_only_fields = ['id', 'is_platform_admin', 'is_staff', 'date_joined']


class CentriaTokenObtainPairSerializer(TokenObtainPairSerializer):
    """Enriches JWT with user profile and company context."""
    def validate(self, attrs):
        data = super().validate(attrs)
        user = self.user
        data['user'] = {
            'id': str(user.id),
            'email': user.email,
            'full_name': user.full_name,
            'avatar_url': user.avatar_url,
            'is_platform_admin': user.is_platform_admin,
            'company': {
                'id': str(user.company.id) if user.company else None,
                'name': user.company.name if user.company else None,
                'slug': user.company.slug if user.company else None,
                'plan': user.company.plan if user.company else 'free',
            } if user.company else None,
            'role': {
                'id': str(user.role.id) if user.role else None,
                'name': user.role.name if user.role else 'Member',
                'permissions': user.role.permissions if user.role else [],
            } if user.role else None,
        }
        return data


class RegisterSerializer(serializers.Serializer):
    company_name = serializers.CharField(max_length=255)
    full_name = serializers.CharField(max_length=255)
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True, min_length=8)

    def validate_email(self, value):
        norm = value.strip().lower()
        if User.objects.filter(email=norm).exists():
            raise serializers.ValidationError("An account with this email already exists.")
        return norm


class ForgotPasswordSerializer(serializers.Serializer):
    email = serializers.EmailField()


class ResetPasswordSerializer(serializers.Serializer):
    email = serializers.EmailField()
    otp_code = serializers.CharField(max_length=6, min_length=6)
    new_password = serializers.CharField(write_only=True, min_length=8)

    def validate_new_password(self, value):
        validate_password(value)
        return value
