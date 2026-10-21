from django.contrib import admin
from django.urls import path, include
from accounts.views import health

urlpatterns = [
    path('', health, name='root_health'),
    path('health/', health, name='health'),
    path('healthz/', health, name='healthz'),
    path('admin/', admin.site.urls),
    path('api/auth/', include('accounts.urls')),
]
