from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    FinancialAccountViewSet, InvoiceViewSet,
    ExpenseViewSet, TransactionViewSet, FinancialSummaryView
)

router = DefaultRouter()
router.register(r'accounts', FinancialAccountViewSet, basename='financial_account')
router.register(r'invoices', InvoiceViewSet, basename='invoice')
router.register(r'expenses', ExpenseViewSet, basename='expense')
router.register(r'transactions', TransactionViewSet, basename='transaction')

urlpatterns = [
    path('summary/', FinancialSummaryView.as_view(), name='financial_summary'),
    path('', include(router.urls)),
]
