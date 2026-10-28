from django.urls import path
from .views import (
    overview_view,
    tasks_view,
    task_detail_view,
    approvals_view,
    approval_execute_view,
    finance_view,
    statutory_view,
    integrations_view,
    audit_view,
)

urlpatterns = [
    path('overview/', overview_view, name='overview'),
    path('tasks/', tasks_view, name='tasks'),
    path('tasks/<uuid:task_id>/', task_detail_view, name='task_detail'),
    path('approvals/', approvals_view, name='approvals'),
    path('approvals/<uuid:approval_id>/execute/', approval_execute_view, name='approval_execute'),
    path('finance/', finance_view, name='finance'),
    path('statutory/', statutory_view, name='statutory'),
    path('integrations/', integrations_view, name='integrations'),
    path('audit/', audit_view, name='audit'),
]
