from rest_framework import views, permissions, status
from rest_framework.response import Response
from media_pipeline.services import process_and_upload_media
from media_pipeline.serializers import MediaAssetSerializer


class MediaUploadView(views.APIView):
    """Converts images to AVIF and stores in Neon Object Cloud S3."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        company = request.company
        if not company:
            return Response({'error': 'No active company workspace'}, status=status.HTTP_400_BAD_REQUEST)

        file_obj = request.FILES.get('file')
        if not file_obj:
            return Response({'error': 'No file uploaded'}, status=status.HTTP_400_BAD_REQUEST)

        folder = request.data.get('folder', 'uploads')
        asset = process_and_upload_media(
            uploaded_file=file_obj,
            company=company,
            user=request.user,
            folder=folder
        )

        return Response(MediaAssetSerializer(asset).data, status=status.HTTP_201_CREATED)
