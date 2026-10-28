import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../theme/typography.dart';

class DemoModeBanner extends StatelessWidget {
  const DemoModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: const BoxDecoration(
        color: CentriaColors.pendingBg,
        border: Border(
          bottom: BorderSide(color: CentriaColors.pendingBorder),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shield_outlined,
            size: 14,
            color: CentriaColors.pendingFg,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'DEMO MODE ACTIVE · Sample Sovereign Ledger (Acme Global Ltd) · Actions record state locally without notifying statutory registries.',
              style: CentriaTypography.labelSm.copyWith(
                color: CentriaColors.pendingFg,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
