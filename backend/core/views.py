import random
import string
from datetime import timedelta
from django.utils import timezone
from django.utils.text import slugify
from django.db import transaction
from rest_framework import status, permissions, views, generics
from rest_framework.response import Response
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.tokens import RefreshToken

from core.models import Company, User, Role, PasswordResetOTP
from core.serializers import (
    UserSerializer,
    CompanySerializer,
    RoleSerializer,
    CentriaTokenObtainPairSerializer,
    RegisterSerializer,
    ForgotPasswordSerializer,
    ResetPasswordSerializer,
)
from core.email_service import send_otp_email
from audit.models import log_activity


DEFAULT_PERMISSIONS = {
    'Owner': ['*'],
    'Admin': [
        'projects.*', 'tasks.*', 'documents.*', 'ai.*', 'approvals.*', 'integrations.*', 'team.manage'
    ],
    'Project Manager': [
        'projects.*', 'tasks.*', 'documents.read', 'documents.upload', 'ai.*', 'approvals.request'
    ],
    'Member': [
        'projects.read', 'tasks.read', 'tasks.create', 'tasks.update', 'documents.read', 'ai.use', 'approvals.request'
    ],
    'Viewer': [
        'projects.read', 'tasks.read', 'documents.read'
    ]
}


def bootstrap_company_roles(company):
    """Creates default roles for a newly registered company."""
    roles = {}
    for role_name, perms in DEFAULT_PERMISSIONS.items():
        role, _ = Role.objects.get_or_create(
            company=company,
            name=role_name,
            defaults={
                'description': f"Default {role_name} role",
                'is_system': True,
                'permissions': perms
            }
        )
        roles[role_name] = role
    return roles


class CentriaTokenObtainPairView(TokenObtainPairView):
    serializer_class = CentriaTokenObtainPairSerializer

    def post(self, request, *args, **kwargs):
        res = super().post(request, *args, **kwargs)
        if res.status_code == 200:
            user = User.objects.filter(email=request.data.get('email', '').strip().lower()).first()
            if user:
                user.last_login = timezone.now()
                user.save(update_fields=['last_login'])
                log_activity(
                    company=user.company,
                    user=user,
                    action='LOGIN',
                    resource_type='auth',
                    description=f"User {user.email} logged in successfully."
                )
        return res


class RegisterView(views.APIView):
    permission_classes = [permissions.AllowAny]

    @transaction.atomic
    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        company_name = data['company_name'].strip()
        base_slug = slugify(company_name) or 'workspace'
        slug = base_slug
        counter = 1
        while Company.objects.filter(slug=slug).exists():
            slug = f"{base_slug}-{counter}"
            counter += 1

        company = Company.objects.create(
            name=company_name,
            slug=slug,
            plan='free'
        )

        roles = bootstrap_company_roles(company)
        owner_role = roles.get('Owner')

        email = data['email'].strip().lower()
        is_platform_admin = (email == 'jasonkennethn@gmail.com')

        user = User.objects.create_user(
            email=email,
            password=data['password'],
            full_name=data['full_name'].strip(),
            company=company,
            role=owner_role,
            is_platform_admin=is_platform_admin,
            is_staff=is_platform_admin,
        )

        log_activity(
            company=company,
            user=user,
            action='CREATE',
            resource_type='company',
            resource_id=company.id,
            description=f"Company '{company.name}' created by {user.email}"
        )

        refresh = RefreshToken.for_user(user)
        return Response({
            'message': 'Account created successfully',
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'user': UserSerializer(user).data,
            'company': CompanySerializer(company).data,
        }, status=status.HTTP_201_CREATED)


class ForgotPasswordView(views.APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = ForgotPasswordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        email = serializer.validated_data['email'].strip().lower()

        user = User.objects.filter(email=email, is_active=True).first()
        if user:
            # Generate 6-digit OTP
            otp_code = ''.join(random.choices(string.digits, k=6))
            expires_at = timezone.now() + timedelta(minutes=10)

            # Invalidate previous unused OTPs
            PasswordResetOTP.objects.filter(user=user, is_used=False).update(is_used=True)

            PasswordResetOTP.objects.create(
                user=user,
                otp_code=otp_code,
                expires_at=expires_at,
            )

            send_otp_email(user.email, otp_code, user.full_name)
            log_activity(
                company=user.company,
                user=user,
                action='UPDATE',
                resource_type='auth',
                description=f"Password reset OTP sent to {user.email}"
            )

        # Always return 200 to prevent email enumeration
        return Response({
            'message': 'If an account matches that email, a verification code has been sent.'
        }, status=status.HTTP_200_OK)


class ResetPasswordView(views.APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = ResetPasswordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        email = data['email'].strip().lower()
        otp_code = data['otp_code'].strip()
        new_password = data['new_password']

        user = User.objects.filter(email=email, is_active=True).first()
        if not user:
            return Response({'error': 'Invalid email or code.'}, status=status.HTTP_400_BAD_REQUEST)

        otp_record = PasswordResetOTP.objects.filter(
            user=user,
            otp_code=otp_code,
            is_used=False,
            expires_at__gte=timezone.now()
        ).first()

        if not otp_record:
            return Response({'error': 'Invalid or expired verification code.'}, status=status.HTTP_400_BAD_REQUEST)

        otp_record.is_used = True
        otp_record.save(update_fields=['is_used'])

        user.set_password(new_password)
        user.save(update_fields=['password'])

        log_activity(
            company=user.company,
            user=user,
            action='UPDATE',
            resource_type='auth',
            description=f"Password successfully reset for {user.email}"
        )

        return Response({'message': 'Password has been reset successfully. You can now sign in.'}, status=status.HTTP_200_OK)


class MeView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        return Response(UserSerializer(request.user).data)

    def put(self, request):
        serializer = UserSerializer(request.user, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)


class TeamListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        if not request.company:
            return Response([], status=status.HTTP_200_OK)
        users = User.objects.filter(company=request.company, is_active=True).select_related('role')
        return Response(UserSerializer(users, many=True).data)

    def post(self, request):
        if not request.company:
            return Response({'error': 'No company workspace active'}, status=status.HTTP_400_BAD_REQUEST)

        email = request.data.get('email', '').strip().lower()
        full_name = request.data.get('full_name', '').strip() or email.split('@')[0]
        role_id = request.data.get('role_id')
        role = Role.objects.filter(company=request.company, id=role_id).first() if role_id else None

        if not role:
            role = Role.objects.filter(company=request.company, name='Member').first()

        if User.objects.filter(email=email).exists():
            return Response({'error': 'User with this email already exists'}, status=status.HTTP_400_BAD_REQUEST)

        # Temporary password generated
        temp_pwd = ''.join(random.choices(string.ascii_letters + string.digits, k=12))
        user = User.objects.create_user(
            email=email,
            password=temp_pwd,
            full_name=full_name,
            company=request.company,
            role=role,
        )

        log_activity(
            company=request.company,
            user=request.user,
            action='CREATE',
            resource_type='team',
            resource_id=user.id,
            description=f"Invited {user.email} to workspace as {role.name if role else 'Member'}"
        )

        return Response({
            'message': f"User {user.email} added to team.",
            'user': UserSerializer(user).data,
            'temporary_password': temp_pwd
        }, status=status.HTTP_201_CREATED)


class PlatformAdminOverviewView(views.APIView):
    """Platform admin overview for jasonkennethn@gmail.com."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        if not request.user.is_platform_admin:
            return Response({'error': 'Platform administrator access required.'}, status=status.HTTP_403_FORBIDDEN)

        companies_count = Company.objects.count()
        users_count = User.objects.count()
        active_companies = Company.objects.filter(is_active=True).count()
        recent_companies = CompanySerializer(Company.objects.order_by('-created_at')[:10], many=True).data

        return Response({
            'total_companies': companies_count,
            'active_companies': active_companies,
            'total_users': users_count,
            'recent_companies': recent_companies,
        })


class RealtimeConfigView(views.APIView):
    """Exposes real-time connectivity endpoints and Neon Realtime credentials for authenticated clients."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        from core.realtime import get_neon_realtime_config
        config = get_neon_realtime_config()
        config['company_id'] = str(request.company.id) if request.company else None
        config['ws_workspace_url'] = f"/ws/workspace/{request.company.id}/" if request.company else None
        config['ws_ai_stream_url'] = "/ws/ai/stream/"
        return Response(config)
