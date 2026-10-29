"""
Real-time dispatch services for Centria.
Handles WebSocket broadcasts across Channels groups and exposes Neon Realtime configurations.
"""
import logging
import asyncio
from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer
from django.conf import settings

logger = logging.getLogger('centria.realtime')


def broadcast_workspace_event(company_id, event_type: str, data: dict):
    """
    Broadcasts a real-time event to all connected workspace members.
    Channels group: workspace_<company_id>
    Safe for both synchronous signals/views and asynchronous event loops.
    """
    if not company_id:
        return
    
    channel_layer = get_channel_layer()
    if not channel_layer:
        return

    group_name = f"workspace_{company_id}"
    message = {
        "type": "workspace_event",
        "event": event_type,
        "company_id": str(company_id),
        "data": data,
    }
    try:
        try:
            loop = asyncio.get_running_loop()
        except RuntimeError:
            loop = None

        if loop and loop.is_running():
            asyncio.create_task(channel_layer.group_send(group_name, message))
        else:
            async_to_sync(channel_layer.group_send)(group_name, message)
    except Exception as e:
        logger.warning(f"Error broadcasting workspace event {event_type} to {group_name}: {e}")


def broadcast_user_event(user_id, event_type: str, data: dict):
    """
    Broadcasts a private event to a specific user (e.g. mentions, private alerts).
    Channels group: user_<user_id>
    Safe for both synchronous signals/views and asynchronous event loops.
    """
    if not user_id:
        return

    channel_layer = get_channel_layer()
    if not channel_layer:
        return

    group_name = f"user_{user_id}"
    message = {
        "type": "workspace_event",
        "event": event_type,
        "user_id": str(user_id),
        "data": data,
    }
    try:
        try:
            loop = asyncio.get_running_loop()
        except RuntimeError:
            loop = None

        if loop and loop.is_running():
            asyncio.create_task(channel_layer.group_send(group_name, message))
        else:
            async_to_sync(channel_layer.group_send)(group_name, message)
    except Exception as e:
        logger.warning(f"Error broadcasting user event {event_type} to {group_name}: {e}")


def get_neon_realtime_config():
    """Returns Neon Realtime configuration credentials for the active environment."""
    return {
        "realtime_url": getattr(settings, 'NEON_REALTIME_URL', ''),
        "realtime_token": getattr(settings, 'NEON_REALTIME_TOKEN', ''),
        "status": "ready" if getattr(settings, 'NEON_REALTIME_URL', '') else "not_configured",
    }
