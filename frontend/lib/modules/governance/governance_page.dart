import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/api_service.dart';
import '../../widgets/app_header.dart';
import '../../widgets/dual_mode_banner.dart';

class GovernancePage extends StatefulWidget {
  final VoidCallback onOpenDrawer;
  final Function(String route) onNavigate;

  const GovernancePage({super.key, required this.onOpenDrawer, required this.onNavigate});

  @override
  State<GovernancePage> createState() => _GovernancePageState();
}

class _GovernancePageState extends State<GovernancePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _api = ApiService();
  bool _isLoading = true;
  List<dynamic> _policies = [];
  List<dynamic> _complianceItems = [];
  List<dynamic> _auditLogs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final polRes = await _api.getPolicies();
    final compRes = await _api.getComplianceItems();
    final auditRes = await _api.getAuditLogs();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (polRes.isSuccess && polRes.data is List) _policies = polRes.data;
        if (compRes.isSuccess && compRes.data is List) _complianceItems = compRes.data;
        if (auditRes.isSuccess && auditRes.data is List) _auditLogs = auditRes.data;
      });
    }
  }

  void _showAddPolicyDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String category = 'INFORMATION_SECURITY';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.darkCard,
          title: const Text('Publish Corporate Policy', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(labelText: 'Policy Title', hintText: 'Remote Access & Encryption Policy'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  dropdownColor: AppTheme.darkCard,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  items: const [
                    DropdownMenuItem(value: 'INFORMATION_SECURITY', child: Text('Information Security')),
                    DropdownMenuItem(value: 'HR_CONDUCT', child: Text('HR & Code of Conduct')),
                    DropdownMenuItem(value: 'FINANCIAL_COMPLIANCE', child: Text('Financial Compliance')),
                    DropdownMenuItem(value: 'DATA_PRIVACY', child: Text('Data Privacy & GDPR')),
                  ],
                  onChanged: (val) => setDialogState(() => category = val!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 4,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(labelText: 'Policy Requirements / Text'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.isEmpty) return;
                Navigator.pop(ctx);
                final res = await _api.createPolicy({
                  'title': titleCtrl.text.trim(),
                  'category': category,
                  'description': descCtrl.text.trim(),
                  'status': 'PUBLISHED',
                });
                if (res.isSuccess) _loadData();
              },
              child: const Text('Publish Policy'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Column(
        children: [
          AppHeader(title: 'Governance & Immutable Audit Room', onOpenDrawer: widget.onOpenDrawer),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DualModeBanner(
                    title: 'Immutable Compliance Vault',
                    description: 'Track corporate governance, tax deadlines, regulatory filings, and write-once immutable audit logs.',
                    aiButtonLabel: 'AI Audit Verification',
                    onAiAction: () => widget.onNavigate('/copilot'),
                  ),
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
                          Tab(text: 'Policies (${_policies.length})'),
                          Tab(text: 'Compliance Deadlines (${_complianceItems.length})'),
                          Tab(text: 'Immutable Audit Trail (${_auditLogs.length})'),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _showAddPolicyDialog,
                        icon: const Icon(Icons.add_moderator, size: 16),
                        label: const Text('New Policy'),
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
                      height: 520,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildPoliciesView(),
                          _buildComplianceView(),
                          _buildAuditLogsView(),
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

  Widget _buildPoliciesView() {
    return ListView.builder(
      itemCount: _policies.length,
      itemBuilder: (ctx, idx) {
        final p = _policies[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.verified_user_outlined, color: AppTheme.accent),
            title: Text(p['title'] ?? 'Policy', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
            subtitle: Text('${p['category']} • Status: ${p['status']}', style: const TextStyle(color: AppTheme.textMuted)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.success.withAlpha(20), borderRadius: BorderRadius.circular(6)),
              child: const Text('COMPLIANT', style: TextStyle(color: AppTheme.success, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildComplianceView() {
    return ListView.builder(
      itemCount: _complianceItems.length,
      itemBuilder: (ctx, idx) {
        final c = _complianceItems[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.event_available, color: AppTheme.warning),
            title: Text(c['title'] ?? 'Filing', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
            subtitle: Text('Authority: ${c['authority'] ?? 'Government'} • Due: ${c['due_date'] ?? '2026-12-31'}', style: const TextStyle(color: AppTheme.textMuted)),
          ),
        );
      },
    );
  }

  Widget _buildAuditLogsView() {
    return ListView.builder(
      itemCount: _auditLogs.length,
      itemBuilder: (ctx, idx) {
        final log = _auditLogs[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            dense: true,
            leading: const Icon(Icons.fingerprint, color: AppTheme.primary, size: 20),
            title: Text(log['action'] ?? 'ACTIVITY_LOGGED', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
            subtitle: Text('${log['entity_type']} (ID: ${log['entity_id']}) • ${log['timestamp']}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            trailing: const Text('IMMUTABLE', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
          ),
        );
      },
    );
  }
}
