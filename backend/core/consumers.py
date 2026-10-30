"""
Django Channels WebSocket Consumers for Centria:
1. WorkspaceConsumer: Real-time broadcast listener for Jira boards, tasks, approvals, notifications, GitHub sync, and live activity feeds.
2. AIAssistantConsumer: Real-time token streaming for Google Gemini AI assistant responses.
"""
import json
import logging
import asyncio
import threading
from channels.generic.websocket import AsyncJsonWebsocketConsumer
from channels.db import database_sync_to_async
from django.conf import settings
from django.utils import timezone
import google.generativeai as genai
from core.ws_auth import get_user_from_token, validate_ws_user_state

logger = logging.getLogger('centria.realtime')


class WorkspaceConsumer(AsyncJsonWebsocketConsumer):
    """
    Subscribes connected users to their organization's real-time event group.
    Path: /ws/workspace/<company_id>/
    """
    async def connect(self):
        self.company_id = self.scope['url_route']['kwargs'].get('company_id')
        self.user = self.scope.get('user')
        
        # Security: require authenticated user
        if not self.user or not self.user.is_authenticated:
            logger.warning("Unauthenticated WebSocket connection attempt rejected.")
            await self.close(code=4001)
            return

        # Security: ensure user belongs to this company or is platform admin
        is_member = await self._is_user_authorized_for_company(self.user, self.company_id)
        if not is_member:
            logger.warning(f"User {self.user.id} unauthorized for company {self.company_id}")
            await self.close(code=4003)
            return

        self.workspace_group_name = f"workspace_{self.company_id}"
        self.user_group_name = f"user_{self.user.id}"

        # Join workspace channel group
        await self.channel_layer.group_add(
            self.workspace_group_name,
            self.channel_name
        )
        # Join user private channel group
        await self.channel_layer.group_add(
            self.user_group_name,
            self.channel_name
        )

        self.token_exp = self.scope.get('token_exp')
        self._heartbeat_task = asyncio.create_task(self._periodic_heartbeat())

        await self.accept()

        # Send initial confirmation and Neon Realtime endpoint metadata
        await self.send_json({
            "type": "connection_established",
            "company_id": str(self.company_id),
            "user_id": str(self.user.id),
            "neon_realtime_url": getattr(settings, 'NEON_REALTIME_URL', ''),
            "status": "online",
            "server_time": timezone.now().isoformat(),
        })

    async def disconnect(self, close_code):
        if hasattr(self, '_heartbeat_task') and self._heartbeat_task:
            self._heartbeat_task.cancel()
        if hasattr(self, 'workspace_group_name'):
            await self.channel_layer.group_discard(
                self.workspace_group_name,
                self.channel_name
            )
        if hasattr(self, 'user_group_name'):
            await self.channel_layer.group_discard(
                self.user_group_name,
                self.channel_name
            )

    async def _periodic_heartbeat(self):
        try:
            while True:
                await asyncio.sleep(45)
                if self.token_exp and timezone.now().timestamp() > self.token_exp:
                    logger.warning(f"Closing expired WS connection for user {getattr(self.user, 'id', None)}")
                    try:
                        await self.send_json({"type": "error", "code": "token_expired", "message": "Authentication token expired. Please reconnect."})
                    except Exception:
                        pass
                    await self.close(code=4001)
                    break
                if self.user and hasattr(self.user, 'id'):
                    is_valid, _, _ = await validate_ws_user_state(self.user.id, self.company_id)
                    if not is_valid:
                        logger.warning(f"Closing revoked WS connection for user {self.user.id}")
                        try:
                            await self.send_json({"type": "error", "code": "user_revoked", "message": "User session has been revoked or company access disabled."})
                        except Exception:
                            pass
                        await self.close(code=4001)
                        break
        except asyncio.CancelledError:
            pass
        except Exception as e:
            logger.debug(f"Workspace periodic heartbeat stopped: {e}")

    async def receive_json(self, content, **kwargs):
        """Handle client inbound messages (ping, heartbeat, token refresh)."""
        # 1. Validate that connected user is still active in DB and tenant membership holds
        is_valid, user, company = await validate_ws_user_state(self.user.id, self.company_id)
        if not is_valid:
            logger.warning(f"Closing WS connection for revoked or disabled user {self.user.id}")
            await self.send_json({
                "type": "error",
                "code": "user_revoked",
                "message": "User session has been revoked or company access disabled."
            })
            await self.close(code=4001)
            return

        # 2. Token refresh support on heartbeat / ping or explicit refresh
        refreshed_token = content.get('token')
        action = content.get('action')

        if refreshed_token:
            new_user, new_company, new_exp = await get_user_from_token(refreshed_token)
            if new_user and new_user.is_authenticated and str(new_user.id) == str(self.user.id):
                self.token_exp = new_exp
                self.scope['token_exp'] = new_exp
                if action == 'refresh_token':
                    await self.send_json({
                        "type": "token_refreshed",
                        "status": "valid",
                        "server_time": timezone.now().isoformat()
                    })
                    return
            else:
                logger.warning(f"Invalid refresh token provided for user {self.user.id}")
                await self.send_json({"type": "error", "code": "token_invalid", "message": "Provided token is invalid."})
                await self.close(code=4001)
                return

        # 3. Check token expiry
        if self.token_exp and timezone.now().timestamp() > self.token_exp:
            logger.warning(f"WebSocket session expired for user {self.user.id}")
            await self.send_json({"type": "error", "code": "token_expired", "message": "Authentication token expired. Please reconnect."})
            await self.close(code=4001)
            return

        # 4. Inbound heartbeats
        if action in ('ping', 'heartbeat'):
            await self.send_json({
                "type": "pong",
                "status": "healthy",
                "timestamp": timezone.now().isoformat()
            })
        elif action == 'echo':
            await self.send_json({
                "type": "echo_response",
                "payload": content.get('payload')
            })

    async def workspace_event(self, event):
        """Dispatches broadcast event from channel layer to client WebSocket."""
        await self.send_json({
            "type": "event",
            "event": event.get("event"),
            "company_id": event.get("company_id"),
            "data": event.get("data", {}),
            "timestamp": timezone.now().isoformat(),
        })

    @database_sync_to_async
    def _is_user_authorized_for_company(self, user, company_id):
        if user.is_platform_admin or user.is_superuser:
            return True
        if not user.company:
            return False
        return str(user.company.id) == str(company_id)


class AIAssistantConsumer(AsyncJsonWebsocketConsumer):
    """
    Handles streaming Gemini 2.5 Flash token generations over WebSocket.
    Path: /ws/ai/stream/
    """
    async def connect(self):
        self.user = self.scope.get('user')
        if not self.user or not self.user.is_authenticated:
            await self.close(code=4001)
            return

        self.company = self.scope.get('company') or getattr(self.user, 'company', None)
        if not self.company:
            await self.close(code=4003)
            return

        self.token_exp = self.scope.get('token_exp')
        self._cancellation_event = threading.Event()
        self._heartbeat_task = asyncio.create_task(self._periodic_heartbeat())

        await self.accept()
        await self.send_json({
            "type": "ai_stream_ready",
            "model": getattr(settings, 'GEMINI_MODEL', 'models/gemini-2.5-flash'),
        })

    async def disconnect(self, close_code):
        if hasattr(self, '_heartbeat_task') and self._heartbeat_task:
            self._heartbeat_task.cancel()
        if hasattr(self, '_cancellation_event'):
            self._cancellation_event.set()

    async def _periodic_heartbeat(self):
        try:
            while True:
                await asyncio.sleep(45)
                if self.token_exp and timezone.now().timestamp() > self.token_exp:
                    try:
                        await self.send_json({"type": "error", "code": "token_expired", "message": "Authentication token expired. Please reconnect."})
                    except Exception:
                        pass
                    await self.close(code=4001)
                    break
                if self.user and hasattr(self.user, 'id'):
                    is_valid, _, _ = await validate_ws_user_state(self.user.id, getattr(self.company, 'id', None))
                    if not is_valid:
                        try:
                            await self.send_json({"type": "error", "code": "user_revoked", "message": "User session has been revoked or company access disabled."})
                        except Exception:
                            pass
                        await self.close(code=4001)
                        break
        except asyncio.CancelledError:
            pass
        except Exception as e:
            logger.debug(f"AI Assistant periodic heartbeat stopped: {e}")

    async def receive_json(self, content, **kwargs):
        """
        Receives prompt payload and streams response tokens chunk-by-chunk.
        """
        # Validate that connected user is still active in DB
        is_valid, user, company = await validate_ws_user_state(
            self.user.id, getattr(self.company, 'id', None)
        )
        if not is_valid:
            await self.send_json({
                "type": "error",
                "code": "user_revoked",
                "message": "User session has been revoked or company access disabled."
            })
            await self.close(code=4001)
            return

        # Check token expiration
        if self.token_exp and timezone.now().timestamp() > self.token_exp:
            await self.send_json({
                "type": "error",
                "code": "token_expired",
                "message": "Authentication token expired. Please reconnect."
            })
            await self.close(code=4001)
            return

        # Enforce bounded prompt length (prevents Gemini 400 errors and DB payload issues)
        prompt = content.get('prompt', '').strip()
        if not prompt:
            await self.send_json({"type": "error", "message": "Prompt cannot be empty."})
            return
        if len(prompt) > 8192:
            await self.send_json({
                "type": "error",
                "message": "Prompt exceeds maximum allowable length of 8192 characters."
            })
            return

        context_type = content.get('context_type', 'general')
        context_id = content.get('context_id', '')
        conv_id = content.get('conversation_id', '')

        # 1. Prepare grounding & conversation in DB
        setup_result = await self._setup_conversation(prompt, conv_id, context_type, context_id)
        if 'error' in setup_result:
            await self.send_json({"type": "error", "message": setup_result['error']})
            return

        conversation_id = setup_result['conversation_id']
        full_prompt = setup_result['full_prompt']
        citations = setup_result['citations']

        # Notify client streaming has begun
        await self.send_json({
            "type": "stream_start",
            "conversation_id": conversation_id,
            "citations": citations,
        })

        # 2. Run Gemini streaming generation in worker thread with cancellation support
        queue = asyncio.Queue()
        loop = asyncio.get_running_loop()
        self._cancellation_event.clear()
        cancel_evt = self._cancellation_event

        def worker():
            try:
                genai.configure(api_key=getattr(settings, 'GEMINI_API_KEY', ''))
                model_name = getattr(settings, 'GEMINI_MODEL', 'models/gemini-2.5-flash')
                model = genai.GenerativeModel(model_name)
                response = model.generate_content(full_prompt, stream=True)
                for chunk in response:
                    if cancel_evt.is_set():
                        break
                    
                    text_chunk = ""
                    try:
                        text_chunk = chunk.text
                    except (AttributeError, ValueError, Exception):
                        if hasattr(chunk, 'candidates') and chunk.candidates:
                            candidate = chunk.candidates[0]
                            if hasattr(candidate, 'content') and hasattr(candidate.content, 'parts'):
                                text_chunk = "".join([getattr(p, 'text', '') for p in candidate.content.parts if hasattr(p, 'text')])
                    
                    if text_chunk and not cancel_evt.is_set():
                        if not loop.is_closed():
                            loop.call_soon_threadsafe(queue.put_nowait, ("chunk", text_chunk))
            except Exception as e:
                logger.error(f"Gemini streaming exception: {e}")
                if not cancel_evt.is_set() and not loop.is_closed():
                    loop.call_soon_threadsafe(queue.put_nowait, ("error", str(e)))
            finally:
                if not loop.is_closed():
                    loop.call_soon_threadsafe(queue.put_nowait, ("done", None))

        threading.Thread(target=worker, daemon=True).start()

        full_reply = []
        has_error = False

        try:
            while True:
                kind, val = await queue.get()
                if kind == "chunk":
                    full_reply.append(val)
                    await self.send_json({
                        "type": "token",
                        "chunk": val,
                        "conversation_id": conversation_id,
                    })
                elif kind == "error":
                    has_error = True
                    await self.send_json({
                        "type": "error",
                        "message": f"Generation failed: {val}",
                        "conversation_id": conversation_id,
                    })
                    break
                elif kind == "done":
                    break
        except Exception as e:
            logger.warning(f"Client disconnected or socket closed during streaming: {e}")
            cancel_evt.set()
            return

        complete_text = "".join(full_reply).strip()
        if not complete_text and not has_error:
            complete_text = "I have completed processing your request."

        # 3. Save conversation turn and log activity in DB atomically (DB-after-API)
        msg_id = await self._finalize_ai_turn(conversation_id, prompt, complete_text, citations, full_prompt)

        # Notify completion
        try:
            await self.send_json({
                "type": "stream_done",
                "conversation_id": conversation_id,
                "message_id": msg_id,
                "citations": citations,
                "full_response": complete_text,
            })
        except Exception:
            cancel_evt.set()

    @database_sync_to_async
    def _setup_conversation(self, prompt, conversation_id, context_type, context_id):
        from ai_engine.models import AIConversation
        from ai_engine.services import check_and_increment_quota, gather_context
        from documents.services import search_knowledge_base

        allowed, err_msg = check_and_increment_quota(self.company, self.user)
        if not allowed:
            return {'error': err_msg}

        conversation = None
        if conversation_id:
            conversation = AIConversation.objects.filter(company=self.company, id=conversation_id).first()

        if not conversation:
            title_snippet = prompt[:45] + ('...' if len(prompt) > 45 else '')
            conversation = AIConversation.objects.create(
                company=self.company,
                user=self.user,
                title=title_snippet,
                context_type=context_type,
                context_id=context_id or ''
            )

        # Retrieve RAG Citations
        citations = search_knowledge_base(self.company, prompt, top_k=3)
        rag_context = ""
        if citations:
            rag_context = "Relevant Company Documents & Knowledge Base:\n"
            for i, c in enumerate(citations):
                rag_context += f"[{i+1}] Source: {c['document_title']}\nExcerpt: {c['excerpt']}\n\n"

        ops_context = gather_context(self.company, context_type, context_id)

        system_instruction = (
            "You are Centria AI, the intelligent Company Operating System assistant for modern software & IT teams.\n"
            "Your mission is to help teams manage projects, issues, company knowledge, and approvals with absolute clarity.\n"
            "Always be concise, professional, actionable, and grounded.\n"
            "If you use information from the provided knowledge base documents, cite the document name explicitly."
        )

        full_prompt = f"{system_instruction}\n\n{ops_context}\n{rag_context}\nUser Question: {prompt}\n\nCentria Assistant Response:"

        return {
            'conversation_id': str(conversation.id),
            'full_prompt': full_prompt,
            'citations': citations,
        }

    @database_sync_to_async
    def _finalize_ai_turn(self, conversation_id, prompt, complete_text, citations, full_prompt):
        from ai_engine.models import AIConversation, AIMessage
        from audit.models import log_activity
        from django.db import transaction

        with transaction.atomic():
            conversation = AIConversation.objects.filter(id=conversation_id).first()
            if not conversation:
                return ""

            AIMessage.objects.create(
                conversation=conversation,
                sender='user',
                content=prompt,
            )

            ai_msg = AIMessage.objects.create(
                conversation=conversation,
                sender='assistant',
                content=complete_text,
                citations=citations,
                tokens_used=len(full_prompt.split()) + len(complete_text.split())
            )

            log_activity(
                company=self.company,
                user=self.user,
                action='AI_QUERY',
                resource_type='ai',
                resource_id=str(conversation.id),
                description=f"Streamed AI query finished with {len(citations)} citations."
            )

            return str(ai_msg.id)
