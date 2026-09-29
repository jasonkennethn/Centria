from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.decorators import action
from .models import CustomField, CustomFieldValue
from .serializers import CustomFieldSerializer, CustomFieldValueSerializer

class CustomFieldViewSet(viewsets.ModelViewSet):
    serializer_class = CustomFieldSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        company_id = self.request.query_params.get('company_id')
        target_entity = self.request.query_params.get('target_entity')
        qs = CustomField.objects.filter(company__owner=self.request.user)
        if company_id:
            qs = qs.filter(company__id=company_id)
        if target_entity:
            qs = qs.filter(target_entity=target_entity.upper())
        return qs

    @action(detail=True, methods=['post'])
    def set_value(self, request, pk=None):
        custom_field = self.get_object()
        entity_id = request.data.get('entity_id')
        if not entity_id:
            return Response({'detail': 'entity_id is required.'}, status=status.HTTP_400_BAD_REQUEST)

        val, _ = CustomFieldValue.objects.update_or_create(
            custom_field=custom_field,
            entity_id=entity_id,
            defaults={
                'value_text': request.data.get('value_text', ''),
                'value_number': request.data.get('value_number'),
                'value_date': request.data.get('value_date'),
                'value_boolean': request.data.get('value_boolean'),
                'value_json': request.data.get('value_json', {}),
            }
        )
        return Response(CustomFieldValueSerializer(val).data)
