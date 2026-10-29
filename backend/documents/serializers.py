from rest_framework import serializers
from core.serializers import UserSerializer
from documents.models import Document, DocumentChunk


class DocumentChunkSerializer(serializers.ModelSerializer):
    class Meta:
        model = DocumentChunk
        fields = ['id', 'chunk_index', 'content', 'token_count', 'metadata', 'created_at']


class DocumentSerializer(serializers.ModelSerializer):
    uploaded_by_details = UserSerializer(source='uploaded_by', read_only=True)
    chunks_count = serializers.IntegerField(source='chunk_count', read_only=True)

    class Meta:
        model = Document
        fields = [
            'id', 'company', 'title', 'description', 'file_url', 'file_type',
            'file_size_bytes', 'uploaded_by', 'uploaded_by_details',
            'is_indexed', 'indexed_at', 'chunk_count', 'chunks_count', 'tags',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'company', 'is_indexed', 'indexed_at', 'chunk_count', 'created_at', 'updated_at']
