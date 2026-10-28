import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../theme/typography.dart';
import 'badges.dart';
import 'buttons.dart';

class CentriaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final BorderSide? border;
  final VoidCallback? onTap;

  const CentriaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.backgroundColor,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? CentriaColors.surfaceCard,
        borderRadius: CentriaRadii.containerRadius,
        border: Border.fromBorderSide(
          border ?? const BorderSide(color: CentriaColors.structuralStroke),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.04),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: CentriaRadii.containerRadius,
        child: card,
      );
    }
    return card;
  }
}

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Widget? badge;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.icon,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CentriaCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: CentriaColors.textMuted),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: CentriaTypography.labelSm.copyWith(
                    color: CentriaColors.textMuted,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badge != null) badge!,
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: CentriaTypography.headlineMd.copyWith(
              fontFamily: 'JetBrains Mono',
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: CentriaTypography.bodySm.copyWith(
                color: CentriaColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AIProposalCard extends StatelessWidget {
  final String title;
  final String description;
  final String confidence;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const AIProposalCard({
    super.key,
    required this.title,
    required this.description,
    required this.confidence,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CentriaColors.cognitiveSurface,
        borderRadius: CentriaRadii.containerRadius,
        border: Border.all(color: CentriaColors.cognitiveBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(109, 40, 217, 0.06),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.psychology_rounded,
                    size: 18,
                    color: CentriaColors.cognitiveDeep,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: CentriaTypography.headlineSm.copyWith(
                      color: CentriaColors.cognitiveDeep,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              StatusBadge.cognitive(label: 'AI Proposal [$confidence]'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: CentriaTypography.bodyMd.copyWith(
              color: CentriaColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                CentriaButton.secondary(
                  label: 'Reject Proposal',
                  onPressed: onReject,
                ),
                CentriaButton(
                  label: 'Accept Diff',
                  onPressed: onAccept,
                  icon: Icons.check_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
