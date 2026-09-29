import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'omnibar_dialog.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onOpenDrawer;

  const AppHeader({
    super.key,
    required this.title,
    this.onOpenDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 1100;
    final isTablet = width > 750;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppTheme.darkBg,
        border: Border(bottom: BorderSide(color: AppTheme.darkBorder)),
      ),
      child: Row(
        children: [
          if (width <= 900)
            IconButton(
              icon: const Icon(Icons.menu, color: AppTheme.textPrimary),
              onPressed: onOpenDrawer,
            ),
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Cloud Status Chips (Neon DB, S3, Gemini)
          if (isDesktop) ...[
            _buildStatusChip('Neon DB', Icons.storage, AppTheme.success),
            const SizedBox(width: 8),
            _buildStatusChip('Neon S3 Vault', Icons.cloud_done, AppTheme.accent),
            const SizedBox(width: 8),
            _buildStatusChip('Gemini AI', Icons.auto_awesome, AppTheme.primary),
            const SizedBox(width: 12),
          ],
          const Spacer(),
          // ⌘K Search trigger
          InkWell(
            onTap: () => OmnibarDialog.show(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search, size: 16, color: AppTheme.textMuted),
                  if (isTablet) ...[
                    const SizedBox(width: 6),
                    const Text(
                      'Search...',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ],
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.darkBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('⌘K', style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
