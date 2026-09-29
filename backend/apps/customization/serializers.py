from rest_framework import serializers
from .models import CustomField, CustomFieldValue

class CustomFieldValueSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomFieldValue
        fields = '__all__'
        read_only_fields = ('id',)


class CustomFieldSerializer(serializers.ModelSerializer):
    values = CustomFieldValueSerializer(many=True, read_only=True)

    class Meta:
        model = CustomField
        fields = '__all__'
        read_only_fields = ('id', 'created_at')
