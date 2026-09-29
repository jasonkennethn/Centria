import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class DualModeBanner extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onAiAction;
  final String aiButtonLabel;
  final bool isAiLoading;

  const DualModeBanner({
    super.key,
    required this.title,
    required this.description,
    this.onAiAction,
    this.aiButtonLabel = 'Run AI Copilot',
    this.isAiLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withAlpha(25),
            AppTheme.darkCard,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withAlpha(60)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: AppTheme.accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withAlpha(30),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('DUAL-MODE ENABLED', style: TextStyle(color: AppTheme.accent, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          if (onAiAction != null) ...[
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: isAiLoading ? null : onAiAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              icon: isAiLoading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.bolt, size: 16),
              label: Text(aiButtonLabel, style: const TextStyle(fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }
}
