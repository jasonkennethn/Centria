import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/design_tokens.dart';
import '../core/theme/typography.dart';
import '../core/components/buttons.dart';
import '../core/components/cards.dart';
import '../core/components/badges.dart';
import '../core/utils/feedback.dart';
import '../data/demo_data.dart';

/// 1. Company Overview Screen (Executive Cockpit)
class CompanyOverviewScreen extends StatefulWidget {
  const CompanyOverviewScreen({super.key});

  @override
  State<CompanyOverviewScreen> createState() => _CompanyOverviewScreenState();
}

class _CompanyOverviewScreenState extends State<CompanyOverviewScreen> {
  String _selectedCurrency = 'EUR (€)';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Acme Global Ltd', style: CentriaTypography.headlineLg),
                        const SizedBox(width: 8),
                        const StatusBadge.verified(label: 'UK #0912481'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Executive Cockpit · Sovereign Balance Sheet & Real-Time Statutory Health',
                      style: CentriaTypography.bodySm,
                    ),
                  ],
                ),
              ),
              // Currency toggle
              Container(
                decoration: BoxDecoration(
                  color: CentriaColors.surfaceInset,
                  borderRadius: CentriaRadii.componentRadius,
                  border: Border.all(color: CentriaColors.structuralStroke),
                ),
                child: Row(
                  children: ['EUR (€)', 'GBP (£)'].map((c) {
                    final isSel = _selectedCurrency == c;
                    return InkWell(
                      onTap: () => setState(() => _selectedCurrency = c),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel ? CentriaColors.primary900 : Colors.transparent,
                          borderRadius: CentriaRadii.componentRadius,
                        ),
                        child: Text(
                          c,
                          style: CentriaTypography.labelSm.copyWith(
                            color: isSel ? Colors.white : CentriaColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // High-priority AI Proposal / Alert
          AIProposalCard(
            title: 'HMRC CT600 Annual Tax Filing Due in 8 Days',
            description:
                'Statutory computation prepared by PwC Tax. R&D credit of €94,200 applied against Corporation Tax. Requires executive biometric ratification before filing.',
            confidence: '99% conf',
            onAccept: () {
              CentriaFeedback.showBiometricConfirmationDialog(
                context,
                title: 'Authorize CT600 Statutory Filing',
                actionLabel: 'HMRC CT600 Return Signed with Biometrics',
                consequenceText:
                    'This action locks the FY25 statutory tax pack and publishes the Merkle root to the sovereign ledger.',
                onConfirm: () {},
              );
            },
            onReject: () => CentriaFeedback.showAction(context, title: 'Proposal flagged for tax advisor clarification'),
          ),
          const SizedBox(height: 20),

          // Key Metrics Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              return GridView.count(
                crossAxisCount: isWide ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: isWide ? 1.6 : 1.3,
                children: [
                  MetricCard(
                    label: 'Consolidated Cash',
                    value: _selectedCurrency.startsWith('EUR') ? '€5,842,100' : '£4,980,450',
                    subtitle: '18.4 Months Runway',
                    icon: Icons.account_balance_rounded,
                    badge: const StatusBadge.verified(label: 'Verified Sync'),
                    onTap: () => context.go('/finance'),
                  ),
                  MetricCard(
                    label: 'Statutory Health',
                    value: '99.4%',
                    subtitle: '14/15 Filings Complete',
                    icon: Icons.gpp_good_rounded,
                    badge: const StatusBadge.verified(label: 'Optimal'),
                    onTap: () => context.go('/compliance-radar'),
                  ),
                  MetricCard(
                    label: 'Pending Approvals',
                    value: '3 Actions',
                    subtitle: 'Biometric Sign-Off Req',
                    icon: Icons.approval_rounded,
                    badge: const StatusBadge.pending(label: 'Action Req'),
                    onTap: () => context.go('/approvals'),
                  ),
                  MetricCard(
                    label: 'Active Automations',
                    value: '14 Pipelines',
                    subtitle: '99.98% SLA Uptime',
                    icon: Icons.hub_rounded,
                    badge: const StatusBadge.info(label: 'Live Stream'),
                    onTap: () => context.go('/creation-studio'),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Operational Actions', style: CentriaTypography.headlineSm),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CentriaButton.secondary(
                    label: 'Export Board Deck',
                    icon: Icons.picture_as_pdf_outlined,
                    onPressed: () => CentriaFeedback.showAction(context, title: 'Q4 Board Deck PDF Generated'),
                  ),
                  const SizedBox(width: 8),
                  CentriaButton(
                    label: 'Run Full Audit Scan',
                    icon: Icons.smart_toy_outlined,
                    onPressed: () => CentriaFeedback.showAction(context, title: 'Autonomous Enclave Audit Complete (Zero Discrepancies)'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          CentriaCard(
            padding: const EdgeInsets.all(0),
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildAuditLogTile(
                  'Merkle Block #1,048,592 Locked',
                  'Vesting allocation & share register updated',
                  '12m ago',
                  Icons.lock_clock_outlined,
                  CentriaColors.primary900,
                  () => context.go('/merkle-proof'),
                ),
                const Divider(),
                _buildAuditLogTile(
                  'Forward Collar #FWD-882 Staged',
                  '£1,200,000 GBP/EUR hedged at strike 1.1740',
                  '1h ago',
                  Icons.currency_exchange_rounded,
                  CentriaColors.pendingFg,
                  () => context.go('/treasury'),
                ),
                const Divider(),
                _buildAuditLogTile(
                  'Delaware Subsidiary Annual Franchise Tax Filed',
                  'Acme US Inc. confirmation #DE-9821419',
                  '3h ago',
                  Icons.verified_rounded,
                  CentriaColors.verifiedFg,
                  () => context.go('/legal-entities'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogTile(String title, String subtitle, String time, IconData icon, Color iconColor, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: CentriaColors.surfaceInset,
          borderRadius: CentriaRadii.componentRadius,
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(title, style: CentriaTypography.labelMd.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: CentriaTypography.bodySm),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(time, style: CentriaTypography.dataMono.copyWith(color: CentriaColors.textMuted)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18, color: CentriaColors.textMuted),
        ],
      ),
      onTap: onTap,
    );
  }
}

/// 2. My Day Screen
class MyDayScreen extends StatefulWidget {
  const MyDayScreen({super.key});

  @override
  State<MyDayScreen> createState() => _MyDayScreenState();
}

class _MyDayScreenState extends State<MyDayScreen> {
  @override
  Widget build(BuildContext context) {
    final demoData = CentriaDemoData.instance;

    return ListenableBuilder(
      listenable: demoData,
      builder: (context, _) {
        final pendingTasks = demoData.tasks.where((t) => t.status != 'Completed').toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Good morning, ${demoData.currentUser}', style: CentriaTypography.headlineLg),
                        const SizedBox(height: 4),
                        Text(
                          '${demoData.currentRole} · 4 Focus Items for Sovereign Review Today',
                          style: CentriaTypography.bodySm,
                        ),
                      ],
                    ),
                  ),
                  CentriaButton.secondary(
                    label: 'Undo (8s)',
                    icon: Icons.undo_rounded,
                    onPressed: () => CentriaFeedback.showAction(context, title: 'Last action reverted cleanly'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              AIProposalCard(
                title: 'Cognitive Triage Recommendation',
                description:
                    '3 pending statutory signatures detected before 17:00 London close. Executing the CT600 and Forward Collar now frees €1.2M in capital reserves.',
                confidence: '96% conf',
                onAccept: () => CentriaFeedback.showAction(context, title: 'Auto-Triage batch staging initialized'),
                onReject: () => CentriaFeedback.showAction(context, title: 'Triage recommendation dismissed'),
              ),
              const SizedBox(height: 24),

              Text('Today\'s Priority Stream', style: CentriaTypography.headlineSm),
              const SizedBox(height: 12),

              if (pendingTasks.isEmpty)
                CentriaCard(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Icon(Icons.done_all_rounded, size: 48, color: CentriaColors.verifiedFg),
                          const SizedBox(height: 12),
                          Text('All Daily Focus Items Completed', style: CentriaTypography.headlineSm),
                          const SizedBox(height: 4),
                          Text('Your sovereign governance requirements are fully satisfied.', style: CentriaTypography.bodySm),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...pendingTasks.map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CentriaCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: CentriaColors.surfaceInset,
                                borderRadius: CentriaRadii.componentRadius,
                              ),
                              child: const Icon(Icons.assignment_outlined, size: 20, color: CentriaColors.primary900),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(t.id, style: CentriaTypography.dataMonoBold.copyWith(color: CentriaColors.textMuted)),
                                      const SizedBox(width: 8),
                                      if (t.priority == 'CRITICAL')
                                        const StatusBadge.critical(label: 'CRITICAL')
                                      else
                                        const StatusBadge.pending(label: 'HIGH'),
                                      const Spacer(),
                                      Text('Due: ${t.dueDate}', style: CentriaTypography.labelSm.copyWith(color: CentriaColors.textMuted)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(t.title, style: CentriaTypography.labelMd.copyWith(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(t.subtitle, style: CentriaTypography.bodySm),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      CentriaButton(
                                        label: 'Quick Approve / Sign',
                                        icon: Icons.fingerprint_rounded,
                                        onPressed: () {
                                          demoData.completeTask(t.id);
                                          CentriaFeedback.showAction(context, title: 'Item ${t.id} Approved & Completed');
                                        },
                                      ),
                                      CentriaButton.secondary(
                                        label: 'Inspect Workpapers',
                                        icon: Icons.description_outlined,
                                        onPressed: () => CentriaFeedback.showAction(context, title: 'Workpaper viewer opened for ${t.id}'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
            ],
          ),
        );
      },
    );
  }
}

/// 3. Tasks & Projects Screen
class TasksProjectsScreen extends StatefulWidget {
  const TasksProjectsScreen({super.key});

  @override
  State<TasksProjectsScreen> createState() => _TasksProjectsScreenState();
}

class _TasksProjectsScreenState extends State<TasksProjectsScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final demoData = CentriaDemoData.instance;

    return ListenableBuilder(
      listenable: demoData,
      builder: (context, _) {
        final filtered = demoData.tasks.where((t) {
          if (_filter == 'All') return true;
          if (_filter == 'Pending') return t.status != 'Completed';
          if (_filter == 'Completed') return t.status == 'Completed';
          return true;
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tasks & Projects', style: CentriaTypography.headlineLg),
                        const SizedBox(height: 4),
                        Text('Operational Governance, Delegations & Statutory Milestones', style: CentriaTypography.bodySm),
                      ],
                    ),
                  ),
                  CentriaButton(
                    label: '+ New Task',
                    icon: Icons.add_rounded,
                    onPressed: () => CentriaFeedback.showAction(context, title: 'Task Creator Dialog Opened'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Filter Chips
              Row(
                children: ['All', 'Pending', 'Completed'].map((f) {
                  final isSel = _filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f),
                      selected: isSel,
                      selectedColor: CentriaColors.primary50,
                      labelStyle: CentriaTypography.labelSm.copyWith(
                        color: isSel ? CentriaColors.primary900 : CentriaColors.textSecondary,
                        fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                      ),
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              ...filtered.map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: CentriaCard(
                      child: Row(
                        children: [
                          Checkbox(
                            value: t.status == 'Completed',
                            activeColor: CentriaColors.primary900,
                            onChanged: (val) {
                              if (val == true) {
                                demoData.completeTask(t.id);
                                CentriaFeedback.showAction(context, title: 'Task ${t.id} marked completed');
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(t.id, style: CentriaTypography.dataMonoBold),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        t.title,
                                        style: CentriaTypography.labelMd.copyWith(fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    StatusBadge(
                                      label: t.status,
                                      variant: t.status == 'Completed'
                                          ? CentriaBadgeVariant.verified
                                          : CentriaBadgeVariant.pending,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(t.subtitle, style: CentriaTypography.bodySm),
                                const SizedBox(height: 4),
                                Text('Assignee: ${t.assignee} · Due: ${t.dueDate}',
                                    style: CentriaTypography.labelSm.copyWith(color: CentriaColors.textMuted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}

/// 4. Approvals Hub Screen
class ApprovalsHubScreen extends StatefulWidget {
  const ApprovalsHubScreen({super.key});

  @override
  State<ApprovalsHubScreen> createState() => _ApprovalsHubScreenState();
}

class _ApprovalsHubScreenState extends State<ApprovalsHubScreen> {
  String _activeTab = 'Pending';

  @override
  Widget build(BuildContext context) {
    final demoData = CentriaDemoData.instance;

    return ListenableBuilder(
      listenable: demoData,
      builder: (context, _) {
        final pendingCount = demoData.approvals.where((a) => a.status == 'Pending').length;
        final executedCount = demoData.approvals.where((a) => a.status == 'Executed').length;

        final items = demoData.approvals.where((a) {
          if (_activeTab == 'Pending') return a.status == 'Pending';
          if (_activeTab == 'Executed') return a.status == 'Executed';
          return true;
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Approvals Hub', style: CentriaTypography.headlineLg),
                        const SizedBox(height: 4),
                        Text('Biometric Statutory Authorizations, Enclave Signatures & Treasury Ratifications',
                            style: CentriaTypography.bodySm),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tabs
              Row(
                children: [
                  _tabItem('Pending ($pendingCount)', 'Pending'),
                  const SizedBox(width: 8),
                  _tabItem('Executed ($executedCount)', 'Executed'),
                ],
              ),
              const SizedBox(height: 16),

              if (items.isEmpty)
                CentriaCard(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text('No approvals in this state.', style: CentriaTypography.bodyMd),
                    ),
                  ),
                )
              else
                ...items.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CentriaCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(a.id, style: CentriaTypography.dataMonoBold),
                                const SizedBox(width: 8),
                                StatusBadge.info(label: a.category),
                                const Spacer(),
                                StatusBadge(
                                  label: a.status,
                                  variant: a.status == 'Executed'
                                      ? CentriaBadgeVariant.verified
                                      : CentriaBadgeVariant.pending,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(a.title, style: CentriaTypography.headlineSm),
                            const SizedBox(height: 4),
                            Text('Impact: ${a.amountOrImpact} · Requested by: ${a.requestedBy} · ${a.date}',
                                style: CentriaTypography.bodySm),
                            const SizedBox(height: 16),
                            if (a.status == 'Pending')
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  CentriaButton(
                                    label: 'Simulate Biometric Sign-Off',
                                    icon: Icons.fingerprint_rounded,
                                    onPressed: () {
                                      CentriaFeedback.showBiometricConfirmationDialog(
                                        context,
                                        title: 'Ratify ${a.id}',
                                        actionLabel: '${a.title} Approved & Recorded',
                                        consequenceText:
                                            'This action writes an immutable signature hash into block #1,048,593.',
                                        onConfirm: () {
                                          demoData.updateApprovalStatus(a.id, 'Executed');
                                        },
                                      );
                                    },
                                  ),
                                  CentriaButton.secondary(
                                    label: 'Reject / Request Changes',
                                    onPressed: () {
                                      demoData.updateApprovalStatus(a.id, 'Rejected');
                                      CentriaFeedback.showAction(context, title: 'Item ${a.id} rejected');
                                    },
                                  ),
                                ],
                              )
                            else
                              const Row(
                                children: [
                                  Icon(Icons.verified_rounded, size: 16, color: CentriaColors.verifiedFg),
                                  SizedBox(width: 6),
                                  Text('Ratified by Sarah Jenkins (Enclave Verified TouchID)',
                                      style: TextStyle(color: CentriaColors.verifiedFg, fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                          ],
                        ),
                      ),
                    )),
            ],
          ),
        );
      },
    );
  }

  Widget _tabItem(String label, String tabKey) {
    final isSel = _activeTab == tabKey;
    return InkWell(
      onTap: () => setState(() => _activeTab = tabKey),
      borderRadius: CentriaRadii.componentRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? CentriaColors.primary900 : CentriaColors.surfaceInset,
          borderRadius: CentriaRadii.componentRadius,
        ),
        child: Text(
          label,
          style: CentriaTypography.labelSm.copyWith(
            color: isSel ? Colors.white : CentriaColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// 5. Inbox & Notifications Screen
class InboxNotificationsScreen extends StatefulWidget {
  const InboxNotificationsScreen({super.key});

  @override
  State<InboxNotificationsScreen> createState() => _InboxNotificationsScreenState();
}

class _InboxNotificationsScreenState extends State<InboxNotificationsScreen> {
  final List<Map<String, String>> _notifications = [
    {
      'title': 'CRITICAL: mTLS Ingestion Certificate Expiring in 72h',
      'category': 'Security',
      'time': '10m ago',
      'body': 'Production banking webhook endpoint certificate rotation is required.',
      'unread': 'true',
    },
    {
      'title': 'HMRC Corporation Tax Return Staged by PwC',
      'category': 'Statutory',
      'time': '45m ago',
      'body': 'CT600 draft ready for director review in Audit & Statutory Tax Console.',
      'unread': 'true',
    },
    {
      'title': 'EUR/GBP Hedging Trigger: Volatility Exceeded 1.8%',
      'category': 'Treasury',
      'time': '2h ago',
      'body': 'Cognitive Treasury copilot generated Forward Collar #FWD-882.',
      'unread': 'false',
    },
    {
      'title': 'KVK Amsterdam Annual Subsidiary Pack Staged',
      'category': 'Legal',
      'time': 'Yesterday',
      'body': 'Acme EU Technologies B.V. Dutch registry documentation updated.',
      'unread': 'false',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Inbox & Triage', style: CentriaTypography.headlineLg),
                    const SizedBox(height: 4),
                    Text('Statutory Notices, Automated Enclave Alerts & AI Intelligence Signals', style: CentriaTypography.bodySm),
                  ],
                ),
              ),
              CentriaButton.secondary(
                label: 'Read All',
                icon: Icons.done_all_rounded,
                onPressed: () {
                  setState(() {
                    for (var n in _notifications) {
                      n['unread'] = 'false';
                    }
                  });
                  CentriaFeedback.showAction(context, title: 'All notifications marked as read');
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          ..._notifications.map((n) {
            final isUnread = n['unread'] == 'true';
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CentriaCard(
                backgroundColor: isUnread ? CentriaColors.primary50 : CentriaColors.surfaceCard,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isUnread ? Icons.mark_email_unread_rounded : Icons.mark_email_read_outlined,
                      color: isUnread ? CentriaColors.primary900 : CentriaColors.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              StatusBadge.info(label: n['category']!),
                              const Spacer(),
                              Text(n['time']!, style: CentriaTypography.dataMono.copyWith(color: CentriaColors.textMuted)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(n['title']!, style: CentriaTypography.labelMd.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(n['body']!, style: CentriaTypography.bodySm),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
