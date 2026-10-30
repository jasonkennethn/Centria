from django.http import JsonResponse
from rest_framework_simplejwt.authentication import JWTAuthentication
from django.utils.deprecation import MiddlewareMixin
from core.models import Company


class CompanyIsolationMiddleware(MiddlewareMixin):
    """
    Ensures every request has request.company scoped to the authenticated user's organization.
    Authenticates JWT tokens before DRF view layer runs and returns 401 on invalid/expired tokens.
    Supports X-Company-ID override exclusively for platform administrators.
    Enforces active organization checks so disabled companies cannot access data.
    """
    def __init__(self, get_response=None):
        super().__init__(get_response)
        self.jwt_auth = JWTAuthentication()

    def process_request(self, request):
        request.company = None

        # Authenticate JWT token if Authorization header is provided
        header = self.jwt_auth.get_header(request)
        if header is not None:
            try:
                raw_token = self.jwt_auth.get_raw_token(header)
                if raw_token is not None:
                    validated_token = self.jwt_auth.get_validated_token(raw_token)
                    request.user = self.jwt_auth.get_user(validated_token)
                    request.auth = validated_token
            except Exception:
                # Do not silently swallow JWT errors when an Authorization header was explicitly provided.
                return JsonResponse(
                    {'detail': 'Invalid or expired authentication token.', 'code': 'token_not_valid'},
                    status=401
                )

        user = getattr(request, 'user', None)
        if user and user.is_authenticated:
            if not user.is_active:
                return JsonResponse({'detail': 'User account is disabled.'}, status=403)

            company_override = request.headers.get('X-Company-ID')
            if (user.is_platform_admin or user.is_superuser) and company_override:
                try:
                    override_company = Company.objects.filter(id=company_override, is_active=True).first()
                    request.company = override_company if override_company else user.company
                except Exception:
                    request.company = user.company
            else:
                request.company = user.company

            if request.company and not request.company.is_active and not (user.is_platform_admin or user.is_superuser):
                return JsonResponse({'detail': 'Company account is inactive or suspended.'}, status=403)
