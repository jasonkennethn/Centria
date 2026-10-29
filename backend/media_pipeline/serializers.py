from rest_framework import serializers
from media_pipeline.models import MediaAsset


class MediaAssetSerializer(serializers.ModelSerializer):
    class Meta:
        model = MediaAsset
        fields = [
            'id', 'company', 'uploader', 'original_filename',
            'file_type', 'size_bytes', 's3_key', 'url',
            'width', 'height', 'created_at'
        ]
        read_only_fields = ['id', 'company', 'uploader', 's3_key', 'url', 'created_at']
