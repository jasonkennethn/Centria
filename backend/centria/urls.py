"""
Centria Enterprise URL Configuration.
"""

from django.contrib import admin
from django.urls import path, include
from django.http import JsonResponse

def health_check(request):
    return JsonResponse({
        'status': 'healthy',
        'service': 'Centria Enterprise Operating System API',
        'version': '1.0.0-production',
        'hosting': 'Render',
        'database': 'Neon DB PostgreSQL',
        'object_cloud': 'Neon Object Cloud S3',
        'mail_service': 'Brevo (Centira <no-reply@celarox.com>)',
        'ai_engine': 'Google Gemini 1.5'
    })

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/health/', health_check, name='health_check'),
    path('api/auth/', include('apps.authentication.urls')),
    path('api/companies/', include('apps.companies.urls')),
    path('api/people/', include('apps.people.urls')),
    path('api/workflows/', include('apps.workflows.urls')),
    path('api/documents/', include('apps.documents.urls')),
    path('api/governance/', include('apps.governance.urls')),
    path('api/operations/', include('apps.operations.urls')),
    path('api/finance/', include('apps.finance.urls')),
    path('api/analytics/', include('apps.analytics.urls')),
    path('api/ai/', include('apps.ai_engine.urls')),
    path('api/customization/', include('apps.customization.urls')),
]
