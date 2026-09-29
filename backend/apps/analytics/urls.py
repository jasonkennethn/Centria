from django.urls import path
from .views import ExecutiveDashboardAnalyticsView

urlpatterns = [
    path('dashboard/', ExecutiveDashboardAnalyticsView.as_view(), name='dashboard_analytics'),
]
