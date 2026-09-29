from rest_framework import viewsets, permissions, status, views
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from .models import Document, DocumentVersion, DocumentAnalysis
from .serializers import DocumentSerializer, DocumentAnalysisSerializer
from .services.s3_service import upload_file_to_s3
from apps.ai_engine.services.gemini_service import analyze_document_content

class DocumentViewSet(viewsets.ModelViewSet):
    serializer_class = DocumentSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def get_queryset(self):
        company_id = self.request.query_params.get('company_id')
        category = self.request.query_params.get('category')
        qs = Document.objects.filter(company__owner=self.request.user)
        if company_id:
            qs = qs.filter(company__id=company_id)
        if category:
            qs = qs.filter(category=category.upper())
        return qs

    def create(self, request, *args, **kwargs):
        file_obj = request.FILES.get('file')
        title = request.data.get('title', 'Uploaded Document')
        category = request.data.get('category', 'OTHER')
        company_id = request.data.get('company_id')

        if not company_id:
            return Response({'detail': 'company_id is required.'}, status=status.HTTP_400_BAD_REQUEST)

        file_url = request.data.get('file_url', '')
        file_size = 0
        mime_type = 'application/octet-stream'
        s3_key = ''

        if file_obj:
            s3_result = upload_file_to_s3(file_obj, file_obj.name, folder="documents")
            file_url = s3_result.get('file_url', '')
            s3_key = s3_result.get('s3_key', '')
            file_size = s3_result.get('file_size', 0)
            mime_type = s3_result.get('mime_type', '')

        doc = Document.objects.create(
            company_id=company_id,
            title=title,
            category=category,
            file_url=file_url,
            s3_key=s3_key,
            file_size=file_size,
            mime_type=mime_type,
            uploaded_by=request.user
        )

        # Trigger Gemini AI Analysis
        analysis_data = analyze_document_content(f"Document: {title}, Category: {category}", title)
        DocumentAnalysis.objects.create(
            document=doc,
            ai_summary=analysis_data.get('summary', 'Uploaded document analyzed.'),
            key_dates_json=analysis_data.get('key_dates', []),
            action_items_json=analysis_data.get('action_items', []),
            extracted_entities_json=analysis_data.get('extracted_entities', {}),
            confidence_score=analysis_data.get('confidence_score', 90)
        )

        return Response(DocumentSerializer(doc).data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=['post'])
    def summarize(self, request, pk=None):
        doc = self.get_object()
        analysis_data = analyze_document_content(f"Title: {doc.title}\nCategory: {doc.category}", doc.title)

        analysis, _ = DocumentAnalysis.objects.update_or_create(
            document=doc,
            defaults={
                'ai_summary': analysis_data.get('summary', ''),
                'key_dates_json': analysis_data.get('key_dates', []),
                'action_items_json': analysis_data.get('action_items', []),
                'extracted_entities_json': analysis_data.get('extracted_entities', {}),
                'confidence_score': analysis_data.get('confidence_score', 92)
            }
        )
        return Response(DocumentAnalysisSerializer(analysis).data)
