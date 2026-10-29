"""
WebSocket URL routing for Centria backend.
Routes real-time channels to WorkspaceConsumer and AIAssistantConsumer.
"""
from django.urls import re_path
from core import consumers

websocket_urlpatterns = [
    re_path(r'^ws/workspace/(?P<company_id>[^/]+)/$', consumers.WorkspaceConsumer.as_asgi()),
    re_path(r'^ws/ai/stream/$', consumers.AIAssistantConsumer.as_asgi()),
]
