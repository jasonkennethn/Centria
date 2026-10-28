import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../theme/typography.dart';

class CentriaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isSecondary;
  final bool isCognitive;
  final bool isCritical;
  final bool isLoading;

  const CentriaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.isSecondary = false,
    this.isCognitive = false,
    this.isCritical = false,
    this.isLoading = false,
  });

  const CentriaButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  })  : isPrimary = false,
        isSecondary = true,
        isCognitive = false,
        isCritical = false;

  const CentriaButton.cognitive({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  })  : isPrimary = false,
        isSecondary = false,
        isCognitive = true,
        isCritical = false;

  const CentriaButton.critical({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  })  : isPrimary = false,
        isSecondary = false,
        isCognitive = false,
        isCritical = true;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    if (isCritical) {
      bg = CentriaColors.criticalFg;
      fg = Colors.white;
    } else if (isCognitive) {
      bg = CentriaColors.cognitiveDeep;
      fg = Colors.white;
    } else if (isSecondary) {
      bg = CentriaColors.surfaceCard;
      fg = CentriaColors.textPrimary;
      border = const BorderSide(color: CentriaColors.structuralStroke);
    } else {
      bg = CentriaColors.primary900;
      fg = Colors.white;
    }

    return SizedBox(
      height: 42,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          shape: RoundedRectangleBorder(
            borderRadius: CentriaRadii.componentRadius,
            side: border,
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16, color: fg),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: CentriaTypography.labelMd.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
