from django.urls import path
from .views import ExecutiveMorningBriefView, AICopilotChatView, OmnibarActionView

urlpatterns = [
    path('morning-brief/', ExecutiveMorningBriefView.as_view(), name='morning_brief'),
    path('chat/', AICopilotChatView.as_view(), name='ai_chat'),
    path('omnibar/', OmnibarActionView.as_view(), name='omnibar_action'),
]
