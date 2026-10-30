from rest_framework import viewsets, permissions, views, status
from rest_framework.response import Response
from ai_engine.models import AIConversation
from ai_engine.serializers import AIConversationSerializer, AskAIRequestSerializer
from ai_engine.services import run_centria_assistant
from audit.models import log_activity


class AIConversationViewSet(viewsets.ModelViewSet):
    serializer_class = AIConversationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        if not self.request.company:
            return AIConversation.objects.none()
        return AIConversation.objects.filter(company=self.request.company, user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(company=self.request.company, user=self.request.user)


class AskAIView(views.APIView):
    """Entrypoint for Centria Assistant queries across all operational contexts."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        company = request.company
        if not company:
            return Response({'error': 'No active company workspace'}, status=status.HTTP_400_BAD_REQUEST)

        serializer = AskAIRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        result = run_centria_assistant(
            company=company,
            user=request.user,
            prompt=data['prompt'],
            conversation_id=data.get('conversation_id'),
            context_type=data.get('context_type', 'general'),
            context_id=data.get('context_id', '')
        )

        if 'error' in result:
            return Response({'error': result['error']}, status=result.get('status_code', status.HTTP_500_INTERNAL_SERVER_ERROR))

        log_activity(
            company=company,
            user=request.user,
            action='AI_QUERY',
            resource_type='ai',
            resource_id=result.get('conversation_id'),
            description=f"AI query executed in context '{data.get('context_type')}' with {len(result.get('citations', []))} citations."
        )

        return Response(result, status=status.HTTP_200_OK)
