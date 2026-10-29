from django.urls import path, include
from rest_framework.routers import DefaultRouter
from approvals.views import ApprovalRequestViewSet

router = DefaultRouter()
router.register(r'requests', ApprovalRequestViewSet, basename='approval_request')

urlpatterns = [
    path('', include(router.urls)),
]
