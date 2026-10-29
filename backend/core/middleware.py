from rest_framework_simplejwt.authentication import JWTAuthentication
from django.utils.deprecation import MiddlewareMixin
from core.models import Company


class CompanyIsolationMiddleware(MiddlewareMixin):
    """
    Ensures every request has request.company scoped to the authenticated user's organization.
    Supports JWT header authentication before DRF view layer runs.
    Supports X-Company-ID override exclusively for platform administrators.
    """
    def __init__(self, get_response=None):
        super().__init__(get_response)
        self.jwt_auth = JWTAuthentication()

    def process_request(self, request):
        request.company = None
        
        # If user isn't authenticated yet via session, try JWT
        if not getattr(request, 'user', None) or not request.user.is_authenticated:
            try:
                auth_res = self.jwt_auth.authenticate(request)
                if auth_res:
                    request.user, request.auth = auth_res
            except Exception:
                pass

        user = getattr(request, 'user', None)
        if user and user.is_authenticated:
            company_override = request.headers.get('X-Company-ID')
            if user.is_platform_admin and company_override:
                try:
                    request.company = Company.objects.filter(id=company_override, is_active=True).first()
                except Exception:
                    request.company = user.company
            else:
                request.company = user.company
