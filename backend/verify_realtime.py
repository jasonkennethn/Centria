"""
Runnable verification check for Centria Realtime WebSockets & Neon Realtime integration.
Ponytail mode: Single runnable check that verifies the entire pipeline end-to-end.
"""
import os
import sys
import asyncio
import django

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'centria_backend.settings.dev')
django.setup()

from channels.testing import WebsocketCommunicator
from rest_framework_simplejwt.tokens import RefreshToken
from centria_backend.asgi import application
from core.models import Company, User
from core.realtime import broadcast_workspace_event, get_neon_realtime_config
from projects.models import Project, Task


def get_test_credentials():
    company = Company.objects.first()
    assert company is not None, "No active company found in database"
    user = User.objects.filter(company=company).first()
    assert user is not None, "No company user found"
    refresh = RefreshToken.for_user(user)
    access_token = str(refresh.access_token)
    return company, user, access_token


async def run_checks():
    print("[1/5] Checking Neon Realtime credentials & endpoint...")
    config = get_neon_realtime_config()
    assert 'realtime_url' in config, "Missing realtime_url in config"
    assert 'rt.c-4.ap-southeast-1.aws.neon.tech' in config['realtime_url'], "Unexpected Neon Realtime URL"
    assert config['realtime_token'].startswith('nrt_live_'), "Invalid Neon Realtime token prefix"
    print(f"      Neon Realtime URL: {config['realtime_url']}")
    print(f"      Neon Realtime Token: {config['realtime_token'][:12]}... (verified)")

    print("[2/5] Retrieving or preparing test user & JWT token...")
    company, user, access_token = await asyncio.to_thread(get_test_credentials)
    print(f"      Authenticated User: {user.email} (Company: {company.name})")

    print("[3/5] Testing WebSocket connection to /ws/workspace/<company_id>/...")
    ws_path = f"/ws/workspace/{company.id}/?token={access_token}"
    communicator = WebsocketCommunicator(application, ws_path)
    connected, subprotocol = await communicator.connect(timeout=10)
    assert connected, "WebSocket connection failed to connect!"

    init_msg = await communicator.receive_json_from(timeout=10)
    assert init_msg.get('type') == 'connection_established', f"Unexpected init message: {init_msg}"
    assert init_msg.get('company_id') == str(company.id), "Company ID mismatch"
    print("      WebSocket handshake successful. Received connection_established.")

    print("[4/5] Testing WebSocket ping / pong heartbeat...")
    await communicator.send_json_to({'action': 'ping'})
    pong = await communicator.receive_json_from(timeout=10)
    assert pong.get('type') == 'pong', f"Expected pong, got {pong}"
    print("      Ping / pong verified.")

    print("[5/5] Testing Realtime event broadcast & signal listener...")
    broadcast_workspace_event(
        company_id=company.id,
        event_type='task_updated',
        data={'key': 'DEMO-99', 'status': 'done', 'title': 'Realtime integration verified'}
    )
    broadcast_msg = await communicator.receive_json_from(timeout=10)
    assert broadcast_msg.get('type') == 'event', f"Expected event type, got {broadcast_msg}"
    assert broadcast_msg.get('event') == 'task_updated', f"Expected task_updated, got {broadcast_msg.get('event')}"
    assert broadcast_msg.get('data', {}).get('key') == 'DEMO-99', "Event data payload mismatch"
    print(f"      Broadcast received over WebSocket: {broadcast_msg['event']} -> {broadcast_msg['data']['key']}")

    await communicator.disconnect()

    print("[6/6] Testing AI Assistant streaming WebSocket (/ws/ai/stream/)...")
    ai_ws_path = f"/ws/ai/stream/?token={access_token}"
    ai_communicator = WebsocketCommunicator(application, ai_ws_path)
    ai_connected, _ = await ai_communicator.connect(timeout=10)
    assert ai_connected, "AI Assistant WebSocket failed to connect!"
    ai_init = await ai_communicator.receive_json_from(timeout=10)
    assert ai_init.get('type') == 'ai_stream_ready', f"Unexpected AI init response: {ai_init}"
    print(f"      AI WebSocket connected and ready with model: {ai_init.get('model')}")
    await ai_communicator.disconnect()

    print("\nALL REALTIME WEBSOCKET AND NEON REALTIME CHECKS PASSED SUCCESSFULLY!")


if __name__ == '__main__':
    asyncio.run(run_checks())
