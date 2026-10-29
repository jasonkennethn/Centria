"""
ASGI config for Centria enterprise operating system.
Multiplexes standard HTTP requests to Django and WebSockets to Channels with JWT authentication.
"""
import os
from django.core.asgi import get_asgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'centria_backend.settings.dev')
django_asgi_app = get_asgi_application()

from channels.routing import ProtocolTypeRouter, URLRouter
from core.routing import websocket_urlpatterns
from core.ws_auth import JwtAuthMiddleware

application = ProtocolTypeRouter({
    "http": django_asgi_app,
    "websocket": JwtAuthMiddleware(
        URLRouter(websocket_urlpatterns)
    ),
})
