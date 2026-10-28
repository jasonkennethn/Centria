import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/design_tokens.dart';
import '../core/theme/typography.dart';
import '../core/layout/breakpoints.dart';
import '../core/components/demo_mode_banner.dart';
import '../core/utils/feedback.dart';
import '../data/demo_data.dart';

class NavDestinationItem {
  final String route;
  final String label;
  final IconData icon;
  final String category;

  const NavDestinationItem({
    required this.route,
    required this.label,
    required this.icon,
    required this.category,
  });
}

const List<NavDestinationItem> allNavigationItems = [
  // Primary
  NavDestinationItem(route: '/overview', label: 'Overview', icon: Icons.dashboard_outlined, category: 'Core Cockpit'),
  NavDestinationItem(route: '/my-day', label: 'My Day', icon: Icons.wb_sunny_outlined, category: 'Core Cockpit'),
  NavDestinationItem(route: '/tasks', label: 'Tasks & Projects', icon: Icons.check_box_outlined, category: 'Core Cockpit'),
  NavDestinationItem(route: '/approvals', label: 'Approvals Hub', icon: Icons.approval_outlined, category: 'Core Cockpit'),
  NavDestinationItem(route: '/inbox', label: 'Inbox & Triage', icon: Icons.inbox_outlined, category: 'Core Cockpit'),

  // Commercial & Operations
  NavDestinationItem(route: '/finance', label: 'Financial Control', icon: Icons.account_balance_wallet_outlined, category: 'Commercial & Capital'),
  NavDestinationItem(route: '/expenses', label: 'Expense & Cards', icon: Icons.credit_card_outlined, category: 'Commercial & Capital'),
  NavDestinationItem(route: '/treasury', label: 'Treasury & FX', icon: Icons.currency_exchange_outlined, category: 'Commercial & Capital'),
  NavDestinationItem(route: '/people', label: 'People & Access', icon: Icons.badge_outlined, category: 'Commercial & Capital'),
  NavDestinationItem(route: '/creation-studio', label: 'Creation Studio', icon: Icons.auto_awesome_mosaic_outlined, category: 'Commercial & Capital'),

  // Sovereign Governance & Legal
  NavDestinationItem(route: '/compliance-radar', label: 'Compliance Radar', icon: Icons.radar_outlined, category: 'Sovereign Governance'),
  NavDestinationItem(route: '/security-compliance', label: 'Security Registry', icon: Icons.gpp_good_outlined, category: 'Sovereign Governance'),
  NavDestinationItem(route: '/audit-trail', label: 'Audit Forensics', icon: Icons.fingerprint_outlined, category: 'Sovereign Governance'),
  NavDestinationItem(route: '/tax-console', label: 'Statutory Tax', icon: Icons.receipt_long_outlined, category: 'Sovereign Governance'),
  NavDestinationItem(route: '/cap-table', label: 'Cap Table Equity', icon: Icons.pie_chart_outline_rounded, category: 'Sovereign Governance'),
  NavDestinationItem(route: '/legal-entities', label: 'Legal Entities', icon: Icons.account_tree_outlined, category: 'Sovereign Governance'),
  NavDestinationItem(route: '/board-meeting', label: 'Board Data Room', icon: Icons.meeting_room_outlined, category: 'Sovereign Governance'),
  NavDestinationItem(route: '/investor-relations', label: 'Investor Relations', icon: Icons.campaign_outlined, category: 'Sovereign Governance'),
  NavDestinationItem(route: '/ma-due-diligence', label: 'M&A Diligence', icon: Icons.handshake_outlined, category: 'Sovereign Governance'),
  NavDestinationItem(route: '/crisis-management', label: 'Crisis Console', icon: Icons.emergency_outlined, category: 'Sovereign Governance'),
  NavDestinationItem(route: '/esg-ledger', label: 'ESG Sustainability', icon: Icons.eco_outlined, category: 'Sovereign Governance'),
  NavDestinationItem(route: '/remco-console', label: 'RemCo Exec Comp', icon: Icons.workspace_premium_outlined, category: 'Sovereign Governance'),
  NavDestinationItem(route: '/ip-patents', label: 'IP & Patents', icon: Icons.lightbulb_outlined, category: 'Sovereign Governance'),
  NavDestinationItem(route: '/risk-insurance', label: 'Risk & Insurance', icon: Icons.security_outlined, category: 'Sovereign Governance'),
  NavDestinationItem(route: '/integrations', label: 'Integrations & APIs', icon: Icons.hub_outlined, category: 'Sovereign Governance'),
  NavDestinationItem(route: '/merkle-proof', label: 'Merkle Proof Block', icon: Icons.tag_outlined, category: 'Sovereign Governance'),
];

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final isDesktop = CentriaBreakpoints.isDesktop(context);

    return Scaffold(
      backgroundColor: CentriaColors.canvasBase,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: CentriaColors.surfaceCard,
            border: Border(bottom: BorderSide(color: CentriaColors.structuralStroke)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (!isDesktop)
                    Builder(
                      builder: (scaffoldCtx) => IconButton(
                        icon: const Icon(Icons.menu_rounded, color: CentriaColors.textPrimary),
                        onPressed: () => Scaffold.of(scaffoldCtx).openDrawer(),
                      ),
                    ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: CentriaColors.primary900,
                      borderRadius: CentriaRadii.componentRadius,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'C',
                      style: CentriaTypography.headlineSm.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () => CentriaFeedback.showAction(context, title: 'Switched to Sovereign Tenant #0912481'),
                    borderRadius: CentriaRadii.componentRadius,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    CentriaDemoData.instance.companyName,
                                    style: CentriaTypography.labelMd.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: CentriaColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified_rounded, size: 14, color: CentriaColors.verifiedFg),
                                  const Icon(Icons.arrow_drop_down_rounded, size: 18, color: CentriaColors.textMuted),
                                ],
                              ),
                              Text(
                                '🇮🇳 ${CentriaDemoData.instance.companyJurisdiction}',
                                style: CentriaTypography.labelSm.copyWith(
                                  color: CentriaColors.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Search button
                  IconButton(
                    icon: const Icon(Icons.search_rounded, size: 20, color: CentriaColors.textSecondary),
                    tooltip: 'Global Command Palette (Cmd + K)',
                    onPressed: () => CentriaFeedback.showAction(context, title: 'Command Palette opened'),
                  ),
                  // Quick add
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 20, color: CentriaColors.primary900),
                    tooltip: 'Quick Create Record',
                    onPressed: () => CentriaFeedback.showAction(context, title: 'Quick Create Sheet opened'),
                  ),
                  const SizedBox(width: 8),
                  // User Avatar
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: CentriaColors.primary50,
                    child: Text(
                      'SJ',
                      style: CentriaTypography.labelSm.copyWith(
                        color: CentriaColors.primary900,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      drawer: isDesktop ? null : _buildDrawer(context, currentPath),
      body: Column(
        children: [
          const DemoModeBanner(),
          Expanded(
            child: Row(
              children: [
                if (isDesktop) _buildSidebar(context, currentPath),
                Expanded(
                  child: Container(
                    color: CentriaColors.canvasBase,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : BottomNavigationBar(
              currentIndex: _getBottomNavIndex(currentPath),
              type: BottomNavigationBarType.fixed,
              backgroundColor: CentriaColors.surfaceCard,
              selectedItemColor: CentriaColors.primary900,
              unselectedItemColor: CentriaColors.textMuted,
              selectedFontSize: 11,
              unselectedFontSize: 11,
              onTap: (index) {
                switch (index) {
                  case 0:
                    context.go('/overview');
                    break;
                  case 1:
                    context.go('/my-day');
                    break;
                  case 2:
                    context.go('/tasks');
                    break;
                  case 3:
                    context.go('/approvals');
                    break;
                  case 4:
                    Scaffold.of(context).openDrawer();
                    break;
                }
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Overview'),
                BottomNavigationBarItem(icon: Icon(Icons.wb_sunny_outlined), label: 'My Day'),
                BottomNavigationBarItem(icon: Icon(Icons.check_box_outlined), label: 'Tasks'),
                BottomNavigationBarItem(icon: Icon(Icons.approval_outlined), label: 'Approvals'),
                BottomNavigationBarItem(icon: Icon(Icons.menu_rounded), label: 'More'),
              ],
            ),
    );
  }

  int _getBottomNavIndex(String path) {
    if (path.startsWith('/overview')) return 0;
    if (path.startsWith('/my-day')) return 1;
    if (path.startsWith('/tasks')) return 2;
    if (path.startsWith('/approvals')) return 3;
    return 4;
  }

  Widget _buildSidebar(BuildContext context, String currentPath) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: CentriaColors.canvasSubdued,
        border: Border(right: BorderSide(color: CentriaColors.structuralStroke)),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: _buildNavGroupWidgets(context, currentPath),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, String currentPath) {
    return Drawer(
      backgroundColor: CentriaColors.surfaceCard,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: CentriaColors.primary900,
                      borderRadius: CentriaRadii.componentRadius,
                    ),
                    alignment: Alignment.center,
                    child: const Text('C', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 10),
                  Text('Centria Sovereign OS', style: CentriaTypography.headlineSm),
                ],
              ),
            ),
            const Divider(),
            ..._buildNavGroupWidgets(context, currentPath, closeDrawerOnTap: true),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNavGroupWidgets(BuildContext context, String currentPath, {bool closeDrawerOnTap = false}) {
    final Map<String, List<NavDestinationItem>> grouped = {};
    for (var item in allNavigationItems) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    final List<Widget> widgets = [];
    grouped.forEach((category, items) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Text(
            category.toUpperCase(),
            style: CentriaTypography.labelSm.copyWith(
              color: CentriaColors.textMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
      );

      for (var item in items) {
        final isSelected = currentPath == item.route;
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Material(
              color: isSelected ? CentriaColors.primary50 : Colors.transparent,
              borderRadius: CentriaRadii.componentRadius,
              child: ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: Icon(
                  item.icon,
                  size: 18,
                  color: isSelected ? CentriaColors.primary900 : CentriaColors.textSecondary,
                ),
                title: Text(
                  item.label,
                  style: CentriaTypography.bodySm.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? CentriaColors.primary900 : CentriaColors.textPrimary,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: CentriaRadii.componentRadius,
                ),
                onTap: () {
                  if (closeDrawerOnTap) {
                    Navigator.of(context).pop();
                  }
                  context.go(item.route);
                },
              ),
            ),
          ),
        );
      }
    });

    return widgets;
  }
}
