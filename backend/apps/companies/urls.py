from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import CompanyViewSet, BranchViewSet, DepartmentViewSet, CompanyRoleViewSet, CompanyGenesisView

router = DefaultRouter()
router.register(r'workspaces', CompanyViewSet, basename='company')
router.register(r'branches', BranchViewSet, basename='branch')
router.register(r'departments', DepartmentViewSet, basename='department')
router.register(r'roles', CompanyRoleViewSet, basename='company_role')

urlpatterns = [
    path('genesis/', CompanyGenesisView.as_view(), name='company_genesis'),
    path('', include(router.urls)),
]
