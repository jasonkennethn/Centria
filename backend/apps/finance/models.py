import uuid
from django.db import models
from django.conf import settings
from apps.companies.models import Company

class FinancialAccount(models.Model):
    """Company bank account, credit card, or cash wallet."""

    ACCOUNT_TYPES = (
        ('BANK', 'Operating Bank Account'),
        ('CREDIT_CARD', 'Corporate Credit Card'),
        ('SAVINGS', 'Reserve / Savings'),
        ('PAYROLL', 'Payroll Escrow'),
    )

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    company = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='financial_accounts')
    name = models.CharField(max_length=150)
    account_type = models.CharField(max_length=30, choices=ACCOUNT_TYPES, default='BANK')
    institution_name = models.CharField(max_length=150, blank=True)
    account_number_last4 = models.CharField(max_length=10, blank=True)
    balance = models.DecimalField(max_digits=14, decimal_places=2, default=0.0)
    currency = models.CharField(max_length=10, default='USD')
    is_active = models.BooleanField(default=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name} (${self.balance:,.2f})"


class Invoice(models.Model):
    """Client Invoices with line items and Brevo email dispatch."""

    STATUS_CHOICES = (
        ('DRAFT', 'Draft'),
        ('SENT', 'Sent to Client'),
        ('PAID', 'Paid'),
        ('OVERDUE', 'Overdue'),
        ('CANCELLED', 'Cancelled'),
    )

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    company = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='invoices')
    invoice_number = models.CharField(max_length=50)
    client_name = models.CharField(max_length=255)
    client_email = models.EmailField()
    client_address = models.TextField(blank=True)
    issue_date = models.DateField()
    due_date = models.DateField()
    subtotal = models.DecimalField(max_digits=12, decimal_places=2, default=0.0)
    tax_rate = models.DecimalField(max_digits=5, decimal_places=2, default=0.0)
    tax_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0.0)
    total_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0.0)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='DRAFT')
    line_items_json = models.JSONField(default=list, blank=True)
    notes = models.TextField(blank=True)
    payment_link = models.URLField(max_length=1000, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-issue_date', '-created_at']

    def __str__(self):
        return f"Invoice #{self.invoice_number} - {self.client_name} (${self.total_amount})"


class Expense(models.Model):
    """Company operational expenses with Neon S3 receipt attachments."""

    CATEGORY_CHOICES = (
        ('SOFTWARE', 'Software & Subscriptions'),
        ('PAYROLL', 'Salaries & Contractors'),
        ('OFFICE', 'Office & Rent'),
        ('TRAVEL', 'Travel & Meals'),
        ('MARKETING', 'Marketing & Ads'),
        ('LEGAL', 'Legal & Professional Services'),
        ('EQUIPMENT', 'Hardware & Equipment'),
        ('OTHER', 'General Operational'),
    )

    STATUS_CHOICES = (
        ('PENDING', 'Pending Review'),
        ('APPROVED', 'Approved & Reimbursed'),
        ('REJECTED', 'Rejected'),
    )

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    company = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='expenses')
    account = models.ForeignKey(FinancialAccount, on_delete=models.SET_NULL, null=True, blank=True, related_name='expenses')
    title = models.CharField(max_length=255)
    vendor = models.CharField(max_length=150, blank=True)
    category = models.CharField(max_length=30, choices=CATEGORY_CHOICES, default='OTHER')
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    currency = models.CharField(max_length=10, default='USD')
    expense_date = models.DateField()
    receipt_url = models.URLField(max_length=1000, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='APPROVED')
    submitted_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True)
    notes = models.TextField(blank=True)

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-expense_date']

    def __str__(self):
        return f"{self.title} - ${self.amount} ({self.category})"


class Transaction(models.Model):
    """Double-entry cash flow transaction."""

    TYPE_CHOICES = (
        ('INCOME', 'Income / Inflow'),
        ('EXPENSE', 'Expense / Outflow'),
        ('TRANSFER', 'Account Transfer'),
    )

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    company = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='transactions')
    account = models.ForeignKey(FinancialAccount, on_delete=models.CASCADE, related_name='transactions')
    transaction_type = models.CharField(max_length=20, choices=TYPE_CHOICES)
    amount = models.DecimalField(max_digits=14, decimal_places=2)
    description = models.CharField(max_length=255)
    date = models.DateField()
    reference_number = models.CharField(max_length=100, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-date', '-created_at']
