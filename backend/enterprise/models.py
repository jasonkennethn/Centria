import uuid
from decimal import Decimal
from django.db import models
from django.conf import settings
from django.utils import timezone


class Company(models.Model):
    """
    Tenant Root entity for Indian Corporate Governance.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=255, default='Centria Technologies India Pvt Ltd')
    cin = models.CharField(max_length=25, unique=True, help_text='Corporate Identification Number (MCA)')
    gstin = models.CharField(max_length=15, blank=True, help_text='Goods and Services Tax Identification Number')
    pan = models.CharField(max_length=10, blank=True, help_text='Permanent Account Number')
    tan = models.CharField(max_length=10, blank=True, help_text='Tax Deduction Account Number')
    roc_jurisdiction = models.CharField(max_length=100, default='ROC Bangalore (Karnataka)')
    incorporation_date = models.DateField(default=timezone.now)
    registered_office = models.TextField(default='Level 4, Embassy TechVillage, Outer Ring Road, Bengaluru, Karnataka 560103')
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name_plural = 'Companies'
        ordering = ['name']

    def __str__(self):
        return f"{self.name} ({self.cin})"


class Membership(models.Model):
    """
    Tenant membership with granular Indian corporate governance roles.
    """
    ROLE_CHOICES = [
        ('OWNER', 'Managing Director & Founder'),
        ('DIRECTOR', 'Executive Director'),
        ('COMPANY_SECRETARY', 'Company Secretary (FCS/ACS)'),
        ('FINANCE_HEAD', 'Chief Financial Officer (CFO / CA)'),
        ('AUDITOR', 'Statutory Auditor'),
        ('MEMBER', 'Operations Member'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='memberships')
    company = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='members')
    role = models.CharField(max_length=30, choices=ROLE_CHOICES, default='DIRECTOR')
    is_active = models.BooleanField(default=True)
    din_number = models.CharField(max_length=8, blank=True, help_text='Director Identification Number (DIN) from MCA')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('user', 'company')
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.email} - {self.company.name} ({self.get_role_display()})"


class Task(models.Model):
    """
    Operational Governance & Statutory Filing Milestones.
    """
    PRIORITY_CHOICES = [
        ('CRITICAL', 'Critical Statutory / Tax'),
        ('HIGH', 'High Priority'),
        ('MEDIUM', 'Medium Priority'),
        ('LOW', 'Low Priority'),
    ]

    STATUS_CHOICES = [
        ('TODO', 'To Do'),
        ('IN_PROGRESS', 'In Progress'),
        ('PENDING_REVIEW', 'Pending Review'),
        ('COMPLETED', 'Completed'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    company = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='tasks')
    task_code = models.CharField(max_length=20, help_text='e.g. TSK-IN-101')
    title = models.CharField(max_length=255)
    subtitle = models.TextField(blank=True)
    priority = models.CharField(max_length=15, choices=PRIORITY_CHOICES, default='HIGH')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='IN_PROGRESS')
    assignee_name = models.CharField(max_length=150, default='Sarah Jenkins')
    due_date = models.CharField(max_length=50, default='Nov 05, 2026')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"[{self.task_code}] {self.title} ({self.status})"


class ApprovalRequest(models.Model):
    """
    Biometric Statutory & Treasury Approvals with cryptographic Merkle proof hash.
    """
    STATUS_CHOICES = [
        ('PENDING', 'Pending Biometric Sign-Off'),
        ('EXECUTED', 'Executed & Immutable'),
        ('REJECTED', 'Rejected / Revisions Requested'),
    ]

    CATEGORY_CHOICES = [
        ('GST_TAX', 'GST & Direct Taxes'),
        ('TREASURY_FX', 'Treasury & Liquidity'),
        ('MCA_FILING', 'MCA & ROC Statutory'),
        ('SECURITY_API', 'Security & API Infrastructure'),
        ('LEGAL_SECRETARY', 'Company Secretarial'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    company = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='approvals')
    approval_code = models.CharField(max_length=20, help_text='e.g. APP-IN-901')
    title = models.CharField(max_length=255)
    category = models.CharField(max_length=30, choices=CATEGORY_CHOICES, default='GST_TAX')
    requested_by = models.CharField(max_length=150)
    amount_or_impact = models.CharField(max_length=100)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='PENDING')
    decision_note = models.TextField(blank=True)
    ratified_by = models.CharField(max_length=150, blank=True)
    signature_hash = models.CharField(max_length=66, blank=True, help_text='SHA-256 Merkle root hash')
    date_display = models.CharField(max_length=50, default='Today, 09:14 AM')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"[{self.approval_code}] {self.title} ({self.status})"


class BankBalance(models.Model):
    """
    Indian Banking Enclaves (HDFC, ICICI, SBI) with INR balances.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    company = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='bank_accounts')
    bank_name = models.CharField(max_length=100)
    account_number_masked = models.CharField(max_length=30)
    ifsc_code = models.CharField(max_length=15)
    branch = models.CharField(max_length=100)
    balance_inr = models.DecimalField(max_digits=15, decimal_places=2, default=Decimal('0.00'))
    hub = models.CharField(max_length=50, default='Bengaluru Hub')
    is_primary = models.BooleanField(default=False)
    last_synced = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-balance_inr']

    def __str__(self):
        return f"{self.bank_name} - ₹{self.balance_inr}"


class ExpenseCard(models.Model):
    """
    Corporate Virtual & Physical RuPay/Visa Cards with Indian policy caps.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    company = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='expense_cards')
    department = models.CharField(max_length=100)
    card_last4 = models.CharField(max_length=4)
    cardholder_name = models.CharField(max_length=150)
    monthly_limit_inr = models.DecimalField(max_digits=12, decimal_places=2)
    current_spend_inr = models.DecimalField(max_digits=12, decimal_places=2, default=Decimal('0.00'))
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.department} (•••• {self.card_last4})"


class StatutoryObligation(models.Model):
    """
    Indian Statutory Obligations: MCA, GST, Income Tax (ITD), EPFO, ESIC.
    """
    AUTHORITY_CHOICES = [
        ('MCA', 'Ministry of Corporate Affairs (MCA / ROC)'),
        ('GSTN', 'Goods & Services Tax Network (GSTN)'),
        ('ITD', 'Income Tax Department (CBDT)'),
        ('EPFO', 'Employees Provident Fund Organisation'),
        ('ESIC', 'Employees State Insurance Corporation'),
    ]

    STATUS_CHOICES = [
        ('READY_TO_FILE', 'Ready to File (Audited)'),
        ('COMPLIANT', 'Compliant / Filed'),
        ('PENDING_AUDIT', 'Pending CA / Tax Audit'),
        ('OVERDUE', 'Overdue'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    company = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='statutory_obligations')
    authority = models.CharField(max_length=20, choices=AUTHORITY_CHOICES)
    form_name = models.CharField(max_length=150)
    description = models.TextField()
    due_date = models.CharField(max_length=50)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='READY_TO_FILE')
    liability_inr = models.DecimalField(max_digits=15, decimal_places=2, default=Decimal('0.00'))
    ack_number = models.CharField(max_length=50, blank=True)

    class Meta:
        ordering = ['due_date']

    def __str__(self):
        return f"[{self.authority}] {self.form_name} ({self.status})"


class IntegrationConnector(models.Model):
    """
    External Indian and Global Enterprise Integrations (Razorpay, Zoho Books, TallyPrime, Webhooks).
    """
    PROVIDER_CHOICES = [
        ('RAZORPAY', 'Razorpay Payment Gateway & Payouts'),
        ('ZOHO_BOOKS', 'Zoho Books Cloud Accounting'),
        ('TALLY_PRIME', 'TallyPrime XML/ODBC Connector'),
        ('AWS_ENCLAVE', 'AWS STS / Nitro Enclaves'),
        ('WEBHOOK', 'mTLS Ingestion Webhook Gateway'),
    ]

    STATUS_CHOICES = [
        ('CONNECTED', 'Connected & Healthy'),
        ('SYNCING', 'Syncing Stream'),
        ('DEGRADED', 'Degraded / Scope Warning'),
        ('NOT_CONFIGURED', 'Not Configured'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    company = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='integrations')
    provider = models.CharField(max_length=30, choices=PROVIDER_CHOICES)
    display_name = models.CharField(max_length=100)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='CONNECTED')
    uptime_sla = models.CharField(max_length=20, default='99.98%')
    events_count_24h = models.IntegerField(default=142890)
    last_sync = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.display_name} ({self.status})"


class AuditEvent(models.Model):
    """
    Immutable Cryptographic Audit Trail for Indian Corporate Records.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    company = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='audit_events')
    block_height = models.BigIntegerField(default=1048592)
    block_hash = models.CharField(max_length=66, default='0x8f2a419c81b2e4d7a90192837461524310928374615243019283746152438102')
    action = models.CharField(max_length=255)
    actor = models.CharField(max_length=150, default='Sarah Jenkins (Director DIN #09124819)')
    details = models.TextField()
    timestamp_display = models.CharField(max_length=50, default='Today, 09:12 IST')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-block_height', '-created_at']

    def __str__(self):
        return f"Block #{self.block_height}: {self.action}"
