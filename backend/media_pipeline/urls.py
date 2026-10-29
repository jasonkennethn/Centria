from django.urls import path
from media_pipeline.views import MediaUploadView

urlpatterns = [
    path('upload/', MediaUploadView.as_view(), name='media_upload'),
]
