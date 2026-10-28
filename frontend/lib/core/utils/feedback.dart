import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../theme/typography.dart';

class CentriaFeedback {
  CentriaFeedback._();

  static void showAction(
    BuildContext context, {
    required String title,
    String? message,
    bool isDemoOnly = true,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: CentriaColors.primary900,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: CentriaRadii.componentRadius,
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: CentriaColors.primary500,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: CentriaTypography.labelMd.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: CentriaTypography.bodySm.copyWith(
                        color: CentriaColors.structuralStroke,
                      ),
                    ),
                  ] else if (isDemoOnly) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Recorded locally in demo state · No external authority notified',
                      style: CentriaTypography.bodySm.copyWith(
                        color: CentriaColors.structuralStroke,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> showBiometricConfirmationDialog(
    BuildContext context, {
    required String title,
    required String actionLabel,
    required String consequenceText,
    required VoidCallback onConfirm,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: CentriaColors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: CentriaRadii.containerRadius,
            side: const BorderSide(color: CentriaColors.structuralStroke),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.fingerprint_rounded,
                color: CentriaColors.primary900,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: CentriaTypography.headlineSm,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                consequenceText,
                style: CentriaTypography.bodyMd,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CentriaColors.surfaceInset,
                  borderRadius: CentriaRadii.componentRadius,
                  border: Border.all(color: CentriaColors.structuralStroke),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 16,
                      color: CentriaColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Demo Mode: Biometric enclave check is simulated locally.',
                        style: CentriaTypography.labelSm.copyWith(
                          color: CentriaColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: CentriaTypography.labelMd.copyWith(
                  color: CentriaColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: CentriaColors.primary900,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: CentriaRadii.componentRadius,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onConfirm();
                showAction(
                  context,
                  title: actionLabel,
                  isDemoOnly: true,
                );
              },
              child: Text(
                'Simulate Biometric Sign-Off',
                style: CentriaTypography.labelMd.copyWith(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
