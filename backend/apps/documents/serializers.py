from rest_framework import serializers
from .models import Document, DocumentVersion, DocumentAnalysis

class DocumentAnalysisSerializer(serializers.ModelSerializer):
    class Meta:
        model = DocumentAnalysis
        fields = '__all__'
        read_only_fields = ('id', 'analyzed_at')


class DocumentVersionSerializer(serializers.ModelSerializer):
    uploaded_by_name = serializers.ReadOnlyField(source='uploaded_by.full_name')

    class Meta:
        model = DocumentVersion
        fields = '__all__'
        read_only_fields = ('id', 'created_at')


class DocumentSerializer(serializers.ModelSerializer):
    uploaded_by_name = serializers.ReadOnlyField(source='uploaded_by.full_name')
    ai_analysis = DocumentAnalysisSerializer(read_only=True)
    versions = DocumentVersionSerializer(many=True, read_only=True)

    class Meta:
        model = Document
        fields = '__all__'
        read_only_fields = ('id', 'uploaded_by', 'created_at', 'updated_at')
