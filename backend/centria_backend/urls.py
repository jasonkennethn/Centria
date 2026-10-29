"""centria_backend URL Configuration."""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/auth/', include('core.urls')),
    path('api/projects/', include('projects.urls')),
    path('api/documents/', include('documents.urls')),
    path('api/ai/', include('ai_engine.urls')),
    path('api/approvals/', include('approvals.urls')),
    path('api/integrations/', include('integrations.urls')),
    path('api/media/', include('media_pipeline.urls')),
]

if settings.DEBUG:
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
