import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:centria/theme/app_theme.dart';

/// Premium Apple-grade Interactive Card with frosted glass, hairline border,
/// ambient elevation, and smooth hover raise micro-animation.
class HoverCard extends StatefulWidget {
  final Widget child;
  final double radius;
  final double blur;
  final Color? color;
  final Color? borderColor;
  final Color? hoverBorderColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final double liftDistance;

  const HoverCard({
    super.key,
    required this.child,
    this.radius = 24,
    this.blur = 20,
    this.color,
    this.borderColor,
    this.hoverBorderColor,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.liftDistance = 5.0,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final baseBorderColor = widget.borderColor ?? Colors.white.withValues(alpha: 0.85);
    final activeHoverBorderColor = widget.hoverBorderColor ?? AppColors.teal.withValues(alpha: 0.32);
    final currentBorderColor = _isHovered ? activeHoverBorderColor : baseBorderColor;

    final baseBgColor = widget.color ?? Colors.white.withValues(alpha: 0.65);
    final currentBgColor = _isHovered ? Colors.white.withValues(alpha: 0.82) : baseBgColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -widget.liftDistance : 0, 0),
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            boxShadow: [
              // Ambient base shadow
              BoxShadow(
                color: _isHovered
                    ? AppColors.teal.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: _isHovered ? 32 : 18,
                offset: Offset(0, _isHovered ? 12 : 4),
                spreadRadius: _isHovered ? 1 : 0,
              ),
              // Subtle top hairline edge light
              BoxShadow(
                color: Colors.white.withValues(alpha: _isHovered ? 0.7 : 0.4),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.radius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
              child: Container(
                decoration: BoxDecoration(
                  color: currentBgColor,
                  borderRadius: BorderRadius.circular(widget.radius),
                  border: Border.all(
                    color: currentBorderColor,
                    width: _isHovered ? 1.4 : 1.1,
                  ),
                ),
                padding: widget.padding,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
