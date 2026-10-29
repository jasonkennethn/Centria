from django.urls import path, include
from rest_framework.routers import DefaultRouter
from projects.views import (
    ProjectViewSet,
    TaskViewSet,
    CustomerViewSet,
    DashboardMyDayView,
)

router = DefaultRouter()
router.register(r'items', ProjectViewSet, basename='project')
router.register(r'tasks', TaskViewSet, basename='task')
router.register(r'customers', CustomerViewSet, basename='customer')

urlpatterns = [
    path('dashboard/', DashboardMyDayView.as_view(), name='dashboard_my_day'),
    path('', include(router.urls)),
]
