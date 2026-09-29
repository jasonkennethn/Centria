from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import EmployeeViewSet, AttendanceViewSet, LeaveRequestViewSet, OnboardingTaskViewSet

router = DefaultRouter()
router.register(r'employees', EmployeeViewSet, basename='employee')
router.register(r'attendance', AttendanceViewSet, basename='attendance')
router.register(r'leave-requests', LeaveRequestViewSet, basename='leave_request')
router.register(r'onboarding-tasks', OnboardingTaskViewSet, basename='onboarding_task')

urlpatterns = [
    path('', include(router.urls)),
]
