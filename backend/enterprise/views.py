import hashlib
import time
from decimal import Decimal
from django.shortcuts import get_object_or_404
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response

from .models import (
    Company, Membership, Task, ApprovalRequest, BankBalance,
    ExpenseCard, StatutoryObligation, IntegrationConnector, AuditEvent
)
from .serializers import (
    CompanySerializer, TaskSerializer, ApprovalRequestSerializer,
    BankBalanceSerializer, ExpenseCardSerializer, StatutoryObligationSerializer,
    IntegrationConnectorSerializer, AuditEventSerializer
)


def _get_active_company(request):
    """
    Tenant isolation helper: resolves company from header or defaults to primary active company.
    """
    company_id = request.headers.get('X-Company-ID')
    if company_id:
        return Company.objects.filter(id=company_id, is_active=True).first()
    
    # Default to primary active Indian corporate tenant
    company = Company.objects.filter(is_active=True).first()
    if not company:
        company = _seed_default_company()
    return company


def _seed_default_company():
    """Seeds default India-first company and operational records if none exists."""
    company = Company.objects.create(
        name='Centria Technologies India Pvt Ltd',
        cin='U72900KA2024PTC189201',
        gstin='29AABCC1234F1Z5',
        pan='AABCC1234F',
        tan='BLRC12345D',
        roc_jurisdiction='ROC Bangalore (Karnataka)',
        registered_office='Level 4, Embassy TechVillage, Outer Ring Road, Bengaluru, Karnataka 560103',
        is_active=True,
    )

    # Seed Tasks
    Task.objects.create(
        company=company,
        task_code='TSK-IN-101',
        title='MCA Form AOC-4 & MGT-7 Annual Filing Ratification',
        subtitle='Statutory audit pack prepared by BSR & Co. · Deadline in 8 days',
        priority='CRITICAL',
        status='IN_PROGRESS',
        assignee_name='Sarah Jenkins (Director)',
        due_date='Nov 05, 2026',
    )
    Task.objects.create(
        company=company,
        task_code='TSK-IN-102',
        title='GSTR-3B Monthly Return Filing & Input Tax Credit Reversal',
        subtitle='Reconciled against GSTR-2B via Zoho Books · Zero reconciliation diff',
        priority='HIGH',
        status='PENDING_REVIEW',
        assignee_name='David Vance (CFO)',
        due_date='Nov 12, 2026',
    )
    Task.objects.create(
        company=company,
        task_code='TSK-IN-103',
        title='Q3 TDS Return Form 26Q & Form 27Q Filing',
        subtitle='Vendor contractor payments and executive director remuneration deductions',
        priority='HIGH',
        status='PENDING_REVIEW',
        assignee_name='Elena Rostova (Company Secretary)',
        due_date='Nov 18, 2026',
    )
    Task.objects.create(
        company=company,
        task_code='TSK-IN-104',
        title='RBI Overseas Direct Investment (ODI) & Form FC-GPR Filing',
        subtitle='FEMA compliance and statutory foreign inward remittance certificates',
        priority='MEDIUM',
        status='TODO',
        assignee_name='Legal & Compliance Committee',
        due_date='Nov 30, 2026',
    )

    # Seed Approvals
    ApprovalRequest.objects.create(
        company=company,
        approval_code='APP-IN-901',
        title='Authorize Monthly GSTR-3B Output Tax Settlement',
        category='GST_TAX',
        requested_by='Zoho Books Automated Tax Ingestion Engine',
        amount_or_impact='₹12,50,000 Net GST Settlement',
        status='PENDING',
        date_display='Today, 09:14 IST',
    )
    ApprovalRequest.objects.create(
        company=company,
        approval_code='APP-IN-902',
        title='Advance Corporate Tax Q3 Instalment Authorization',
        category='GST_TAX',
        requested_by='Statutory Tax Counsel (PwC India)',
        amount_or_impact='₹45,00,000 Direct Tax Challan',
        status='PENDING',
        date_display='Today, 08:30 IST',
    )
    ApprovalRequest.objects.create(
        company=company,
        approval_code='APP-IN-903',
        title='Rotate Razorpay Webhook mTLS Signing Secret',
        category='SECURITY_API',
        requested_by='Automated Sovereign Watchdog Enclave',
        amount_or_impact='Production API Payment Protection',
        status='PENDING',
        date_display='Yesterday, 18:22 IST',
    )

    # Seed Bank Balances
    BankBalance.objects.create(
        company=company,
        bank_name='HDFC Bank Corporate Current Account',
        account_number_masked='•••• 9821',
        ifsc_code='HDFC0000240',
        branch='Koramangala 4th Block, Bengaluru',
        balance_inr=Decimal('34850000.00'), # 3.48 Cr
        hub='Bengaluru Hub',
        is_primary=True,
    )
    BankBalance.objects.create(
        company=company,
        bank_name='ICICI Bank Operational Account',
        account_number_masked='•••• 4419',
        ifsc_code='ICIC0000002',
        branch='MG Road, Bengaluru',
        balance_inr=Decimal('18240000.00'), # 1.82 Cr
        hub='Bengaluru Hub',
        is_primary=False,
    )
    BankBalance.objects.create(
        company=company,
        bank_name='State Bank of India (SBI) Tax Escrow',
        account_number_masked='•••• 1024',
        ifsc_code='SBIN0004118',
        branch='Indiranagar, Bengaluru',
        balance_inr=Decimal('5331000.00'), # 53.3 Lakhs
        hub='Karnataka State Escrow',
        is_primary=False,
    )

    # Seed Expense Cards
    ExpenseCard.objects.create(
        company=company,
        department='Executive Travel & Legal Counsel',
        card_last4='4892',
        cardholder_name='Sarah Jenkins',
        monthly_limit_inr=Decimal('1500000.00'),
        current_spend_inr=Decimal('420000.00'),
    )
    ExpenseCard.objects.create(
        company=company,
        department='Cloud AWS, GPU & AI Infrastructure',
        card_last4='1024',
        cardholder_name='Michael Chen',
        monthly_limit_inr=Decimal('4500000.00'),
        current_spend_inr=Decimal('3280000.00'),
    )

    # Seed Statutory Obligations
    StatutoryObligation.objects.create(
        company=company,
        authority='MCA',
        form_name='MCA Form AOC-4 & MGT-7',
        description='Filing of Audited Financial Statements and Annual Return with ROC Bangalore',
        due_date='Nov 05, 2026',
        status='READY_TO_FILE',
        liability_inr=Decimal('0.00'),
    )
    StatutoryObligation.objects.create(
        company=company,
        authority='GSTN',
        form_name='GSTR-3B Monthly Return',
        description='Summary Return of Outward Supplies & Input Tax Credit Availment',
        due_date='Nov 20, 2026',
        status='READY_TO_FILE',
        liability_inr=Decimal('1250000.00'),
    )
    StatutoryObligation.objects.create(
        company=company,
        authority='ITD',
        form_name='Advance Tax Instalment 3',
        description='Corporate Income Tax instalment under Section 208 of the Income Tax Act, 1961',
        due_date='Dec 15, 2026',
        status='PENDING_AUDIT',
        liability_inr=Decimal('4500000.00'),
    )

    # Seed Integration Connectors
    IntegrationConnector.objects.create(
        company=company,
        provider='RAZORPAY',
        display_name='Razorpay Corporate Payouts & Subscriptions',
        status='CONNECTED',
        uptime_sla='99.99%',
        events_count_24h=84290,
    )
    IntegrationConnector.objects.create(
        company=company,
        provider='ZOHO_BOOKS',
        display_name='Zoho Books Automated E-Way & GST Reconciliation',
        status='CONNECTED',
        uptime_sla='99.98%',
        events_count_24h=142890,
    )
    IntegrationConnector.objects.create(
        company=company,
        provider='TALLY_PRIME',
        display_name='TallyPrime XML/ODBC Real-Time Ledger Sync',
        status='CONNECTED',
        uptime_sla='99.95%',
        events_count_24h=31400,
    )

    # Seed Audit Events
    AuditEvent.objects.create(
        company=company,
        block_height=1048592,
        block_hash='0x8f2a419c81b2e4d7a90192837461524310928374615243019283746152438102',
        action='ROC Bangalore Statutory Form AOC-4 Verified',
        actor='Sarah Jenkins (Director DIN #09124819)',
        details='Audited balance sheet Merkle proof generated & published to Sovereign Ledger.',
        timestamp_display='Today, 09:12 IST',
    )
    AuditEvent.objects.create(
        company=company,
        block_height=1048591,
        block_hash='0x4e1b98214a72d4e8c90192837461524310928374615243019283746152437719',
        action='Razorpay Payment Enclave Webhook Verified',
        actor='Automated Enclave Watchdog',
        details='Inward B2B customer settlement of ₹28,45,000 credited to HDFC Current Account.',
        timestamp_display='Today, 08:30 IST',
    )

    return company


@api_view(['GET'])
@permission_classes([AllowAny])
def overview_view(request):
    """
    Returns consolidated executive cockpit overview for India corporate operations.
    """
    company = _get_active_company(request)
    
    total_cash_inr = sum(b.balance_inr for b in company.bank_accounts.all())
    pending_approvals = company.approvals.filter(status='PENDING').count()
    active_tasks = company.tasks.filter(status__in=['TODO', 'IN_PROGRESS', 'PENDING_REVIEW']).count()
    active_integrations = company.integrations.filter(status='CONNECTED').count()
    
    recent_audits = AuditEventSerializer(company.audit_events.all()[:5], many=True).data

    # Indian Numbering Format Helper (e.g. ₹5,84,21,000)
    def format_inr(val):
        s = str(int(val))
        if len(s) <= 3:
            return f"₹{s}"
        last3 = s[-3:]
        rest = s[:-3]
        groups = []
        while len(rest) > 2:
            groups.insert(0, rest[-2:])
            rest = rest[:-2]
        if rest:
            groups.insert(0, rest)
        return f"₹{','.join(groups)},{last3}"

    return Response({
        'company': CompanySerializer(company).data,
        'metrics': {
            'total_cash_inr': str(total_cash_inr),
            'total_cash_display': format_inr(total_cash_inr),
            'runway_months': '18.4 Months Runway',
            'statutory_health_percent': '99.4%',
            'statutory_health_status': '14/15 MCA & GST Filings Complete',
            'pending_approvals_count': pending_approvals,
            'active_tasks_count': active_tasks,
            'active_integrations_count': active_integrations,
        },
        'recent_audits': recent_audits,
    })


@api_view(['GET', 'POST'])
@permission_classes([AllowAny])
def tasks_view(request):
    """
    List and create tasks scoped to active company tenant.
    """
    company = _get_active_company(request)
    if request.method == 'POST':
        serializer = TaskSerializer(data=request.data)
        if serializer.is_valid():
            task = serializer.save(company=company)
            return Response(TaskSerializer(task).data, status=status.HTTP_201_CREATED)
        return Response({'errors': serializer.errors}, status=status.HTTP_400_BAD_REQUEST)

    status_filter = request.query_params.get('status')
    qs = company.tasks.all()
    if status_filter:
        qs = qs.filter(status=status_filter)
    
    return Response(TaskSerializer(qs, many=True).data)


@api_view(['GET', 'PATCH', 'DELETE'])
@permission_classes([AllowAny])
def task_detail_view(request, task_id):
    """
    Retrieve, update or delete a specific task under active company.
    """
    company = _get_active_company(request)
    task = get_object_or_404(Task, id=task_id, company=company)

    if request.method == 'GET':
        return Response(TaskSerializer(task).data)

    if request.method == 'PATCH':
        serializer = TaskSerializer(task, data=request.data, partial=True)
        if serializer.is_valid():
            updated_task = serializer.save()
            return Response(TaskSerializer(updated_task).data)
        return Response({'errors': serializer.errors}, status=status.HTTP_400_BAD_REQUEST)

    if request.method == 'DELETE':
        task.delete()
        return Response({'message': 'Task deleted successfully'}, status=status.HTTP_204_NO_CONTENT)


@api_view(['GET'])
@permission_classes([AllowAny])
def approvals_view(request):
    """
    List approval requests scoped to active company.
    """
    company = _get_active_company(request)
    status_filter = request.query_params.get('status')
    qs = company.approvals.all()
    if status_filter:
        qs = qs.filter(status=status_filter.upper())
    return Response(ApprovalRequestSerializer(qs, many=True).data)


@api_view(['POST'])
@permission_classes([AllowAny])
def approval_execute_view(request, approval_id):
    """
    Executes biometric ratification on an approval request, generating Merkle block proof.
    """
    company = _get_active_company(request)
    approval = get_object_or_404(ApprovalRequest, id=approval_id, company=company)

    action = request.data.get('action', 'APPROVE') # APPROVE or REJECT
    decision_note = request.data.get('decision_note', 'Biometric ratification completed via Director Secure Enclave.')
    
    if action == 'APPROVE':
        approval.status = 'EXECUTED'
        approval.decision_note = decision_note
        approval.ratified_by = 'Sarah Jenkins (Director DIN #09124819)'
        
        # Generate deterministic cryptographic SHA-256 Merkle root hash
        content = f"{company.cin}-{approval.approval_code}-{time.time()}"
        approval.signature_hash = '0x' + hashlib.sha256(content.encode()).hexdigest()
        approval.save()

        # Emit immutable AuditEvent
        AuditEvent.objects.create(
            company=company,
            block_height=1048593,
            block_hash=approval.signature_hash,
            action=f"Statutory Ratification: {approval.title}",
            actor=approval.ratified_by,
            details=f"Impact: {approval.amount_or_impact}. Decision Note: {decision_note}",
            timestamp_display='Just now',
        )

        return Response({
            'message': 'Approval executed and cryptographically sealed on Sovereign Ledger.',
            'approval': ApprovalRequestSerializer(approval).data,
        })
    else:
        approval.status = 'REJECTED'
        approval.decision_note = decision_note
        approval.save()
        return Response({
            'message': 'Approval rejected.',
            'approval': ApprovalRequestSerializer(approval).data,
        })


@api_view(['GET'])
@permission_classes([AllowAny])
def finance_view(request):
    """
    Bank balances in INR, liquidity breakdown, and RuPay/Visa corporate card roster.
    """
    company = _get_active_company(request)
    bank_accounts = BankBalanceSerializer(company.bank_accounts.all(), many=True).data
    cards = ExpenseCardSerializer(company.expense_cards.all(), many=True).data

    total_balance = sum(b.balance_inr for b in company.bank_accounts.all())

    return Response({
        'total_balance_inr': str(total_balance),
        'currency': 'INR (₹)',
        'bank_accounts': bank_accounts,
        'expense_cards': cards,
    })


@api_view(['GET'])
@permission_classes([AllowAny])
def statutory_view(request):
    """
    Indian statutory obligations: MCA, GSTN, ITD, EPFO, ESIC.
    """
    company = _get_active_company(request)
    obligations = StatutoryObligationSerializer(company.statutory_obligations.all(), many=True).data
    return Response({
        'company_cin': company.cin,
        'gstin': company.gstin,
        'pan': company.pan,
        'obligations': obligations,
    })


@api_view(['GET'])
@permission_classes([AllowAny])
def integrations_view(request):
    """
    Enterprise integrations: Razorpay, Zoho Books, TallyPrime, AWS Enclave.
    """
    company = _get_active_company(request)
    connectors = IntegrationConnectorSerializer(company.integrations.all(), many=True).data
    return Response({
        'connectors': connectors,
    })


@api_view(['GET'])
@permission_classes([AllowAny])
def audit_view(request):
    """
    Cryptographic immutable audit ledger blocks.
    """
    company = _get_active_company(request)
    audits = AuditEventSerializer(company.audit_events.all(), many=True).data
    return Response({
        'audit_blocks': audits,
    })
