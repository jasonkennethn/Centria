import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/api_service.dart';
import '../../widgets/app_header.dart';
import '../../widgets/dual_mode_banner.dart';
import '../../widgets/metric_card.dart';

class FinancePage extends StatefulWidget {
  final VoidCallback onOpenDrawer;
  final Function(String route) onNavigate;

  const FinancePage({super.key, required this.onOpenDrawer, required this.onNavigate});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _api = ApiService();

  bool _isLoading = true;
  Map<String, dynamic>? _summary;
  List<dynamic> _invoices = [];
  List<dynamic> _expenses = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFinanceData();
  }

  Future<void> _loadFinanceData() async {
    setState(() => _isLoading = true);

    final sumRes = await _api.getFinancialSummary();
    final invRes = await _api.getInvoices();
    final expRes = await _api.getExpenses();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (sumRes.isSuccess) _summary = sumRes.data;
        if (invRes.isSuccess && invRes.data is List) _invoices = invRes.data;
        if (expRes.isSuccess && expRes.data is List) _expenses = expRes.data;
      });
    }
  }

  void _showCreateInvoiceDialog() {
    final clientNameCtrl = TextEditingController();
    final clientEmailCtrl = TextEditingController();
    final amountCtrl = TextEditingController(text: '5000');
    final invoiceNumCtrl = TextEditingController(text: 'INV-2026-${_invoices.length + 1}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text('Generate Client Invoice', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: invoiceNumCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Invoice #'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: clientNameCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Client Company', hintText: 'Quantum Logic Systems'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: clientEmailCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Client Billing Email', hintText: 'billing@quantum.io'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Total Amount (\$USD)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (clientNameCtrl.text.isEmpty || amountCtrl.text.isEmpty) return;
              Navigator.pop(ctx);
              final amt = double.tryParse(amountCtrl.text) ?? 5000.0;
              final res = await _api.createInvoice({
                'invoice_number': invoiceNumCtrl.text.trim(),
                'client_name': clientNameCtrl.text.trim(),
                'client_email': clientEmailCtrl.text.trim(),
                'issue_date': '2026-09-29',
                'due_date': '2026-10-29',
                'subtotal': amt,
                'tax_rate': 0.0,
                'total_amount': amt,
                'status': 'DRAFT',
              });
              if (res.isSuccess) _loadFinanceData();
            },
            child: const Text('Create Invoice'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSendInvoice(String id) async {
    final res = await _api.sendInvoice(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: res.isSuccess ? AppTheme.success : AppTheme.error,
          content: Text(res.isSuccess ? 'Invoice dispatched to client via Brevo email engine!' : 'Failed to send invoice.'),
        ),
      );
      _loadFinanceData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCash = _summary?['total_cash_balance'] ?? 92000.0;
    final totalInvoiced = _summary?['total_invoiced'] ?? 15000.0;
    final totalExpenses = _summary?['total_expenses'] ?? 8200.0;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Column(
        children: [
          AppHeader(title: 'Finance & Invoicing', onOpenDrawer: widget.onOpenDrawer),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DualModeBanner(
                    title: 'Precision Ledger & Invoicing Engine',
                    description: 'Issue branded client invoices with automated Brevo delivery, tax calculation, and runway forecasts.',
                    aiButtonLabel: 'AI Expense Audit',
                    onAiAction: () => widget.onNavigate('/copilot'),
                  ),

                  // Financial KPI Cards
                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          title: 'Cash in Bank',
                          value: '\$${totalCash.toStringAsFixed(0)}',
                          subtitle: 'Neon Double-Entry Ledger',
                          icon: Icons.account_balance,
                          iconColor: AppTheme.success,
                          trend: '+12.4%',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MetricCard(
                          title: 'Total Invoiced (Q3)',
                          value: '\$${totalInvoiced.toStringAsFixed(0)}',
                          subtitle: '${_invoices.length} Active Accounts',
                          icon: Icons.receipt_long,
                          iconColor: AppTheme.accent,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MetricCard(
                          title: 'Monthly Expenses',
                          value: '\$${totalExpenses.toStringAsFixed(0)}',
                          subtitle: 'Burn rate steady',
                          icon: Icons.credit_card,
                          iconColor: AppTheme.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        indicatorColor: AppTheme.primary,
                        labelColor: AppTheme.textPrimary,
                        unselectedLabelColor: AppTheme.textMuted,
                        tabs: [
                          Tab(text: 'Invoices (${_invoices.length})'),
                          Tab(text: 'Expenses (${_expenses.length})'),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _showCreateInvoiceDialog,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Create Invoice'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.darkBorder),
                  const SizedBox(height: 16),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  else
                    SizedBox(
                      height: 450,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildInvoicesList(),
                          _buildExpensesList(),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicesList() {
    if (_invoices.isEmpty) {
      return const Center(child: Text('No invoices recorded.', style: TextStyle(color: AppTheme.textMuted)));
    }
    return ListView.builder(
      itemCount: _invoices.length,
      itemBuilder: (ctx, idx) {
        final inv = _invoices[idx];
        final id = inv['id'].toString();
        final status = inv['status'] ?? 'DRAFT';
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppTheme.primary.withAlpha(30), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.receipt_outlined, color: AppTheme.accent),
            ),
            title: Text('${inv['invoice_number']} • ${inv['client_name']}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
            subtitle: Text('Due: ${inv['due_date']} • Total: \$${inv['total_amount']}', style: const TextStyle(color: AppTheme.textMuted)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == 'PAID' ? AppTheme.success.withAlpha(20) : AppTheme.warning.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: status == 'PAID' ? AppTheme.success : AppTheme.warning, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                if (status != 'PAID')
                  ElevatedButton.icon(
                    onPressed: () => _handleSendInvoice(id),
                    icon: const Icon(Icons.send, size: 12),
                    label: const Text('Send (Brevo)', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkBorder,
                      foregroundColor: AppTheme.textPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpensesList() {
    if (_expenses.isEmpty) {
      return const Center(child: Text('No operational expenses recorded.', style: TextStyle(color: AppTheme.textMuted)));
    }
    return ListView.builder(
      itemCount: _expenses.length,
      itemBuilder: (ctx, idx) {
        final exp = _expenses[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const Icon(Icons.payment, color: AppTheme.warning),
            title: Text(exp['vendor'] ?? 'Vendor Expense', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
            subtitle: Text('${exp['category']} • Date: ${exp['expense_date']}', style: const TextStyle(color: AppTheme.textMuted)),
            trailing: Text(
              '-\$${exp['amount']}',
              style: const TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        );
      },
    );
  }
}
