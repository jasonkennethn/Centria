from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import WorkflowViewSet, WorkflowExecutionViewSet, ApprovalRequestViewSet

router = DefaultRouter()
router.register(r'definitions', WorkflowViewSet, basename='workflow')
router.register(r'executions', WorkflowExecutionViewSet, basename='workflow_execution')
router.register(r'approvals', ApprovalRequestViewSet, basename='approval_request')

urlpatterns = [
    path('', include(router.urls)),
]
