from django.urls import path, include
from rest_framework.routers import DefaultRouter
from integrations.views import GitHubIntegrationViewSet, GitHubWebhookView

router = DefaultRouter()
router.register(r'github', GitHubIntegrationViewSet, basename='github_integration')

urlpatterns = [
    path('github/webhook/', GitHubWebhookView.as_view(), name='github_webhook'),
    path('', include(router.urls)),
]
