from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import PolicyViewSet, ComplianceItemViewSet, AuditLogViewSet, BoardDecisionViewSet

router = DefaultRouter()
router.register(r'policies', PolicyViewSet, basename='policy')
router.register(r'compliance', ComplianceItemViewSet, basename='compliance')
router.register(r'audit-logs', AuditLogViewSet, basename='audit_log')
router.register(r'board-decisions', BoardDecisionViewSet, basename='board_decision')

urlpatterns = [
    path('', include(router.urls)),
]
