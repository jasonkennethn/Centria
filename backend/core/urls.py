from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from core.views import (
    CentriaTokenObtainPairView,
    RegisterView,
    ForgotPasswordView,
    ResetPasswordView,
    MeView,
    TeamListView,
    PlatformAdminOverviewView,
)

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', CentriaTokenObtainPairView.as_view(), name='login'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('forgot-password/', ForgotPasswordView.as_view(), name='forgot_password'),
    path('reset-password/', ResetPasswordView.as_view(), name='reset_password'),
    path('me/', MeView.as_view(), name='me'),
    path('team/', TeamListView.as_view(), name='team_list'),
    path('platform-admin/', PlatformAdminOverviewView.as_view(), name='platform_admin_overview'),
]
