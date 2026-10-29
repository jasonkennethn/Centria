from django.urls import path, include
from rest_framework.routers import DefaultRouter
from integrations.views import GitHubIntegrationViewSet

router = DefaultRouter()
router.register(r'github', GitHubIntegrationViewSet, basename='github_integration')

urlpatterns = [
    path('', include(router.urls)),
]
