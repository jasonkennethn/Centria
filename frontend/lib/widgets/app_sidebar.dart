import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../core/api/api_service.dart';

class AppSidebar extends StatelessWidget {
  final String activeRoute;
  final Function(String route) onNavigate;

  const AppSidebar({
    super.key,
    required this.activeRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: AppTheme.darkCard,
        border: Border(right: BorderSide(color: AppTheme.darkBorder)),
      ),
      child: Column(
        children: [
          // Brand Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.darkBorder)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'C',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Company OS',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(40),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.primary.withAlpha(80)),
                  ),
                  child: const Text('PRO', style: TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              children: [
                _buildSectionHeader('EXECUTIVE COMMAND'),
                _buildNavItem(Icons.dashboard_outlined, 'Executive Cockpit', '/dashboard'),
                _buildNavItem(Icons.auto_awesome, '60s Genesis Wizard', '/genesis', isAi: true),
                _buildNavItem(Icons.psychology_outlined, 'AI Copilot (⌘K)', '/copilot', isAi: true),

                const SizedBox(height: 16),
                _buildSectionHeader('CORE OPERATIONS'),
                _buildNavItem(Icons.people_outline, 'People & HRMS', '/people'),
                _buildNavItem(Icons.account_tree_outlined, 'Workflow Engine', '/workflows'),
                _buildNavItem(Icons.folder_open_outlined, 'Document Vault (S3)', '/documents'),
                _buildNavItem(Icons.view_kanban_outlined, 'Operations & Kanban', '/operations'),

                const SizedBox(height: 16),
                _buildSectionHeader('FINANCE & GOVERNANCE'),
                _buildNavItem(Icons.account_balance_wallet_outlined, 'Finance & Invoicing', '/finance'),
                _buildNavItem(Icons.insights_outlined, 'Predictive Analytics', '/analytics', isAi: true),
                _buildNavItem(Icons.shield_outlined, 'Governance & Audit', '/governance'),
                _buildNavItem(Icons.tune_outlined, 'No-Code Customization', '/customization'),
              ],
            ),
          ),

          // User Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.darkBorder)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primary.withAlpha(60),
                  child: const Text('AD', style: TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Admin Workspace', style: TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                      Text('admin@celarox.com', style: TextStyle(color: AppTheme.textMuted, fontSize: 10), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, size: 16, color: AppTheme.textMuted),
                  tooltip: 'Log out',
                  onPressed: () async {
                    await ApiService().logout();
                    onNavigate('/login');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, String route, {bool isAi = false}) {
    final isSelected = activeRoute == route;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primary.withAlpha(30) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: AppTheme.primary.withAlpha(100)) : null,
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: Icon(
          icon,
          size: 18,
          color: isSelected ? AppTheme.primary : (isAi ? AppTheme.accent : AppTheme.textSecondary),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        trailing: isAi
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withAlpha(30),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('AI', style: TextStyle(color: AppTheme.accent, fontSize: 9, fontWeight: FontWeight.bold)),
              )
            : null,
        onTap: () => onNavigate(route),
      ),
    );
  }
}
