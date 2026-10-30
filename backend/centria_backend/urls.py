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
    path('api/health/', lambda request: JsonResponse({'status': 'healthy', 'service': 'centria'}), name='api_health'),
    path('health/', lambda request: JsonResponse({'status': 'healthy', 'service': 'centria'}), name='health'),
]

if settings.DEBUG:
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)

from django.http import JsonResponse


def custom_bad_request(request, exception=None):
    return JsonResponse({'error': 'Bad Request', 'status_code': 400}, status=400)


def custom_permission_denied(request, exception=None):
    return JsonResponse({'error': 'Permission Denied', 'status_code': 403}, status=403)


def custom_not_found(request, exception=None):
    return JsonResponse({'error': 'Endpoint Not Found', 'status_code': 404}, status=404)


def custom_server_error(request):
    return JsonResponse({'error': 'Internal Server Error', 'status_code': 500}, status=500)


handler400 = 'centria_backend.urls.custom_bad_request'
handler403 = 'centria_backend.urls.custom_permission_denied'
handler404 = 'centria_backend.urls.custom_not_found'
handler500 = 'centria_backend.urls.custom_server_error'
