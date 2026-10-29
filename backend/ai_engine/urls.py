from django.urls import path, include
from rest_framework.routers import DefaultRouter
from ai_engine.views import AIConversationViewSet, AskAIView

router = DefaultRouter()
router.register(r'conversations', AIConversationViewSet, basename='ai_conversation')

urlpatterns = [
    path('ask/', AskAIView.as_view(), name='ask_ai'),
    path('', include(router.urls)),
]
