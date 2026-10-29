from rest_framework import serializers
from ai_engine.models import AIConversation, AIMessage, AIUsageQuota


class AIMessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = AIMessage
        fields = ['id', 'conversation', 'sender', 'content', 'citations', 'tokens_used', 'created_at']
        read_only_fields = ['id', 'created_at']


class AIConversationSerializer(serializers.ModelSerializer):
    messages = AIMessageSerializer(many=True, read_only=True)
    last_message = serializers.SerializerMethodField()

    class Meta:
        model = AIConversation
        fields = ['id', 'company', 'user', 'title', 'context_type', 'context_id', 'is_archived', 'messages', 'last_message', 'created_at', 'updated_at']
        read_only_fields = ['id', 'company', 'user', 'created_at', 'updated_at']

    def get_last_message(self, obj):
        last = obj.messages.order_by('-created_at').first()
        return AIMessageSerializer(last).data if last else None


class AskAIRequestSerializer(serializers.Serializer):
    prompt = serializers.CharField(max_length=4000)
    conversation_id = serializers.UUIDField(required=False, allow_null=True)
    context_type = serializers.ChoiceField(
        choices=['general', 'project', 'task', 'document', 'reporting'],
        default='general'
    )
    context_id = serializers.CharField(required=False, allow_blank=True, default='')
