"""
WebSocket JWT Authentication Middleware for Django Channels.
Extracts JWT tokens from query strings (?token=...) or Authorization headers.
"""
from urllib.parse import parse_qs
from django.contrib.auth.models import AnonymousUser
from channels.db import database_sync_to_async
from rest_framework_simplejwt.tokens import AccessToken
from core.models import User


@database_sync_to_async
def get_user_from_token(token_str):
    """Validates the JWT token and fetches the User with Company preloaded and expiration timestamp."""
    try:
        token = AccessToken(token_str)
        user_id = token.get('user_id')
        if not user_id:
            return AnonymousUser(), None, None
        user = User.objects.select_related('company', 'role').filter(id=user_id, is_active=True).first()
        if not user or (user.company and not user.company.is_active and not (user.is_platform_admin or user.is_superuser)):
            return AnonymousUser(), None, None
        return user, user.company, token.get('exp')
    except Exception:
        return AnonymousUser(), None, None


@database_sync_to_async
def validate_ws_user_state(user_id, company_id=None):
    """
    Verifies that a connected user is still active in the database
    and still belongs to the authorized company.
    """
    try:
        user = User.objects.select_related('company', 'role').filter(id=user_id, is_active=True).first()
        if not user:
            return False, None, None
        if user.company and not user.company.is_active and not (user.is_platform_admin or user.is_superuser):
            return False, None, None
        if company_id and not (user.is_platform_admin or user.is_superuser):
            if not user.company or str(user.company.id) != str(company_id):
                return False, None, None
        return True, user, user.company
    except Exception:
        return False, None, None


class JwtAuthMiddleware:
    """
    Channels ASGI middleware to authenticate incoming WebSocket connections
    using DRF SimpleJWT tokens.
    """
    def __init__(self, inner):
        self.inner = inner

    async def __call__(self, scope, receive, send):
        token_str = None

        # 1. Check query parameters (?token=...)
        query_string = scope.get('query_string', b'').decode('utf-8')
        if query_string:
            params = parse_qs(query_string)
            if 'token' in params and params['token']:
                token_str = params['token'][0]

        # 2. Fallback to Authorization header
        if not token_str:
            headers = dict(scope.get('headers', []))
            auth_header = headers.get(b'authorization', b'').decode('utf-8')
            if auth_header.startswith('Bearer '):
                token_str = auth_header.split(' ', 1)[1]

        if token_str:
            user, company, exp = await get_user_from_token(token_str)
            scope['user'] = user
            scope['company'] = company
            scope['token_exp'] = exp
            scope['token_str'] = token_str
        else:
            scope['user'] = AnonymousUser()
            scope['company'] = None
            scope['token_exp'] = None
            scope['token_str'] = None

        return await self.inner(scope, receive, send)
