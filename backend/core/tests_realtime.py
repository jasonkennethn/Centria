"""
Tests for Django Channels WebSocket consumers and real-time event broadcasting.
"""
from django.test import TestCase
from channels.testing import WebsocketCommunicator
from rest_framework_simplejwt.tokens import RefreshToken
from centria_backend.asgi import application
from core.models import Company, User
from core.realtime import broadcast_workspace_event, get_neon_realtime_config


class RealtimeWebSocketTests(TestCase):
    def setUp(self):
        self.company = Company.objects.create(name='Realtime Test Co', slug='realtime-co')
        self.user = User.objects.create_user(
            email='realtime_user@test.com',
            password='Password123!',
            company=self.company,
            full_name='Test Operator'
        )
        refresh = RefreshToken.for_user(self.user)
        self.access_token = str(refresh.access_token)

    async def test_workspace_websocket_connection_and_broadcast(self):
        # 1. Connect via WebSocket with JWT token
        path = f"/ws/workspace/{self.company.id}/?token={self.access_token}"
        communicator = WebsocketCommunicator(application, path)
        connected, _ = await communicator.connect()
        self.assertTrue(connected, "WebSocket connection failed to establish.")

        # 2. Receive connection_established packet
        initial_msg = await communicator.receive_json_from()
        self.assertEqual(initial_msg.get('type'), 'connection_established')
        self.assertEqual(initial_msg.get('company_id'), str(self.company.id))

        # 3. Test ping / pong
        await communicator.send_json_to({'action': 'ping'})
        pong_msg = await communicator.receive_json_from()
        self.assertEqual(pong_msg.get('type'), 'pong')

        # 4. Broadcast real-time event and verify delivery
        broadcast_workspace_event(
            company_id=self.company.id,
            event_type='task_updated',
            data={'key': 'TST-1', 'status': 'in_progress'}
        )
        event_msg = await communicator.receive_json_from()
        self.assertEqual(event_msg.get('type'), 'event')
        self.assertEqual(event_msg.get('event'), 'task_updated')
        self.assertEqual(event_msg.get('data', {}).get('key'), 'TST-1')

        await communicator.disconnect()

    def test_neon_realtime_config(self):
        config = get_neon_realtime_config()
        self.assertIn('realtime_url', config)
        self.assertIn('realtime_token', config)
        self.assertTrue(len(config['realtime_url']) > 0)
