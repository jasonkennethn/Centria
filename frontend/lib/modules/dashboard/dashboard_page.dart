import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/api_service.dart';
import '../../widgets/app_header.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/dual_mode_banner.dart';

class DashboardPage extends StatefulWidget {
  final Function(String route) onNavigate;
  final VoidCallback onOpenDrawer;

  const DashboardPage({super.key, required this.onNavigate, required this.onOpenDrawer});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ApiService _api = ApiService();

  bool _isLoading = true;
  bool _isBriefLoading = false;
  Map<String, dynamic>? _briefData;
  Map<String, dynamic>? _analyticsData;
  List<dynamic> _pendingApprovals = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    final analyticsRes = await _api.getExecutiveAnalytics();
    final approvalsRes = await _api.getApprovals();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (analyticsRes.isSuccess) {
          _analyticsData = analyticsRes.data;
        }
        if (approvalsRes.isSuccess && approvalsRes.data is List) {
          _pendingApprovals = approvalsRes.data;
        }
      });
      // Fetch morning brief using current telemetry
      _fetchMorningBrief();
    }
  }

  Future<void> _fetchMorningBrief() async {
    setState(() => _isBriefLoading = true);
    final kpis = _analyticsData?['kpis'] ?? {};

    final briefRes = await _api.getMorningBrief({
      'company_name': 'Centria Technologies Inc.',
      'cash_balance': kpis['total_cash'] ?? 92000,
      'runway_months': kpis['runway_months'] ?? 11.2,
      'pending_approvals': _pendingApprovals.length,
      'active_projects': kpis['active_projects'] ?? 3,
    });

    if (mounted) {
      setState(() {
        _isBriefLoading = false;
        if (briefRes.isSuccess) {
          _briefData = briefRes.data;
        }
      });
    }
  }

  Future<void> _handleApproval(String approvalId, String action) async {
    final res = await _api.executeApproval(approvalId, action, 'Processed via Executive Cockpit');
    if (res.isSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: action == 'approve' ? AppTheme.success : AppTheme.error,
          content: Text('Action "$action" executed successfully.'),
        ),
      );
      _loadDashboardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final kpis = _analyticsData?['kpis'] ?? {};
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Column(
        children: [
          AppHeader(title: 'Executive Cockpit', onOpenDrawer: widget.onOpenDrawer),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : RefreshIndicator(
                    onRefresh: _loadDashboardData,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Dual-Mode Architecture Banner
                          DualModeBanner(
                            title: 'Dual-Mode Control Active',
                            description: 'Direct manual management enabled across all modules. Gemini AI Copilot standing by.',
                            aiButtonLabel: 'Open ⌘K Copilot',
                            onAiAction: () => widget.onNavigate('/copilot'),
                          ),

                          // 8:00 AM Morning Briefing Card (Gemini AI)
                          _buildMorningBriefCard(),
                          const SizedBox(height: 24),

                          // Core KPI Metrics
                          const Text(
                            'LIVE COMPANY METRICS',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 12),

                          GridView.count(
                            crossAxisCount: isMobile ? 1 : (screenWidth < 1300 ? 2 : 4),
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              MetricCard(
                                title: 'Total Cash Balance',
                                value: '\$${(kpis['total_cash'] ?? 92000).toStringAsFixed(0)}',
                                subtitle: 'Neon DB Realtime Sync',
                                icon: Icons.account_balance,
                                iconColor: AppTheme.success,
                                trend: '+14.2%',
                              ),
                              MetricCard(
                                title: 'Financial Runway',
                                value: '${(kpis['runway_months'] ?? 11.2).toStringAsFixed(1)} Mo',
                                subtitle: 'Burn: \$${(kpis['monthly_burn'] ?? 8200).toStringAsFixed(0)}/mo',
                                icon: Icons.timer_outlined,
                                iconColor: AppTheme.accent,
                                trend: 'Healthy',
                              ),
                              MetricCard(
                                title: 'Active Headcount',
                                value: '${kpis['active_headcount'] ?? 14}',
                                subtitle: 'Across 4 Departments',
                                icon: Icons.people_outline,
                                iconColor: AppTheme.primary,
                                trend: '+2 this mo',
                              ),
                              MetricCard(
                                title: 'Pending Approvals',
                                value: '${_pendingApprovals.length}',
                                subtitle: '1-Click Action Queue',
                                icon: Icons.rule_outlined,
                                iconColor: AppTheme.warning,
                                trend: _pendingApprovals.isNotEmpty ? 'Action Req' : 'Clear',
                                isPositiveTrend: _pendingApprovals.isEmpty,
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // 1-Click Executive Approval Queue
                          _buildApprovalQueueSection(),
                          const SizedBox(height: 32),

                          // Quick Actions Row
                          _buildQuickActionsRow(),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMorningBriefCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withAlpha(80)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.wb_sunny_outlined, color: AppTheme.accent, size: 20),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '8:00 AM Executive Morning Brief',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  Text('Synthesized from Neon DB ledger and active operational queues', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: _isBriefLoading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent))
                    : const Icon(Icons.refresh, size: 18, color: AppTheme.accent),
                tooltip: 'Regenerate Brief',
                onPressed: _fetchMorningBrief,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.darkBorder),
          const SizedBox(height: 12),

          if (_briefData != null) ...[
            Text(
              _briefData!['headline'] ?? 'All systems operating at peak velocity.',
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
            ),
            const SizedBox(height: 12),
            if (_briefData!['action_cards'] is List)
              ...(_briefData!['action_cards'] as List).map(
                (card) => Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSubtle,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.darkBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt, color: AppTheme.warning, size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          card['title'] ?? card.toString(),
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ] else ...[
            const Text(
              'Analyzing enterprise telemetry across finance, HRMS, and development sprints...',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildApprovalQueueSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '1-CLICK EXECUTIVE APPROVAL QUEUE',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
            Text(
              '${_pendingApprovals.length} Pending Actions',
              style: const TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_pendingApprovals.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.check_circle_outline, color: AppTheme.success, size: 36),
                  SizedBox(height: 10),
                  Text('Approval Queue Clear', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                  Text('No pending invoices, leave requests, or workflow authorizations.', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _pendingApprovals.length,
            itemBuilder: (ctx, idx) {
              final item = _pendingApprovals[idx];
              final id = item['id'].toString();
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.pending_actions, color: AppTheme.warning, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] ?? 'Workflow Approval Request',
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            item['details'] ?? 'Requires authorized executive signature.',
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _handleApproval(id, 'approve'),
                      icon: const Icon(Icons.check, size: 14),
                      label: const Text('Approve', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _handleApproval(id, 'reject'),
                      icon: const Icon(Icons.close, size: 14, color: AppTheme.error),
                      label: const Text('Reject', style: TextStyle(color: AppTheme.error, fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildQuickActionsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EXECUTIVE SHORTCUTS',
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionChip(Icons.person_add_outlined, 'Onboard Employee', () => widget.onNavigate('/people')),
            _buildActionChip(Icons.receipt_long_outlined, 'Issue Invoice', () => widget.onNavigate('/finance')),
            _buildActionChip(Icons.cloud_upload_outlined, 'Upload Document to S3', () => widget.onNavigate('/documents')),
            _buildActionChip(Icons.add_task_outlined, 'New Task (Kanban)', () => widget.onNavigate('/operations')),
            _buildActionChip(Icons.shield_outlined, 'Governance Audit Room', () => widget.onNavigate('/governance')),
          ],
        ),
      ],
    );
  }

  Widget _buildActionChip(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.accent),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
