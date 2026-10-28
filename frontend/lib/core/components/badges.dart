import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../theme/typography.dart';

enum CentriaBadgeVariant {
  verified,
  pending,
  critical,
  info,
  cognitive,
  neutral,
}

class StatusBadge extends StatelessWidget {
  final String label;
  final CentriaBadgeVariant variant;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    this.variant = CentriaBadgeVariant.neutral,
    this.icon,
  });

  const StatusBadge.verified({
    super.key,
    required this.label,
    this.icon = Icons.verified_rounded,
  }) : variant = CentriaBadgeVariant.verified;

  const StatusBadge.pending({
    super.key,
    required this.label,
    this.icon = Icons.pending_rounded,
  }) : variant = CentriaBadgeVariant.pending;

  const StatusBadge.critical({
    super.key,
    required this.label,
    this.icon = Icons.error_rounded,
  }) : variant = CentriaBadgeVariant.critical;

  const StatusBadge.info({
    super.key,
    required this.label,
    this.icon = Icons.info_rounded,
  }) : variant = CentriaBadgeVariant.info;

  const StatusBadge.cognitive({
    super.key,
    required this.label,
    this.icon = Icons.psychology_rounded,
  }) : variant = CentriaBadgeVariant.cognitive;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;

    switch (variant) {
      case CentriaBadgeVariant.verified:
        bg = CentriaColors.verifiedBg;
        fg = CentriaColors.verifiedFg;
        border = CentriaColors.verifiedBorder;
        break;
      case CentriaBadgeVariant.pending:
        bg = CentriaColors.pendingBg;
        fg = CentriaColors.pendingFg;
        border = CentriaColors.pendingBorder;
        break;
      case CentriaBadgeVariant.critical:
        bg = CentriaColors.criticalBg;
        fg = CentriaColors.criticalFg;
        border = CentriaColors.criticalBorder;
        break;
      case CentriaBadgeVariant.info:
        bg = CentriaColors.infoBg;
        fg = CentriaColors.infoFg;
        border = CentriaColors.infoBorder;
        break;
      case CentriaBadgeVariant.cognitive:
        bg = CentriaColors.cognitiveSurface;
        fg = CentriaColors.cognitiveDeep;
        border = CentriaColors.cognitiveBorder;
        break;
      case CentriaBadgeVariant.neutral:
        bg = CentriaColors.surfaceInset;
        fg = CentriaColors.textSecondary;
        border = CentriaColors.structuralStroke;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: CentriaRadii.fullRadius,
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: CentriaTypography.labelSm.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
