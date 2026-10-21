import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'skeleton.dart';

/// App-wide design constants
class CentriaTheme {
  static const Color bgDark = Color(0xFF090C16);
  static const Color bgMid = Color(0xFF0F1527);
  static const Color bgDeep = Color(0xFF131B33);

  static const Color primaryCyan = Color(0xFF00D2FF);
  static const Color primaryBlue = Color(0xFF0072FF);
  static const Color primaryPurple = Color(0xFF7C4DFF);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF00D2FF), Color(0xFF7C4DFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardBorderGradient = LinearGradient(
    colors: [
      Color(0x33FFFFFF),
      Color(0x0FFFFFFF),
      Color(0x05FFFFFF),
      Color(0x2200D2FF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Dynamic ambient background with Apple-level depth and subtle ambient glow
class CentriaBackground extends StatelessWidget {
  final Widget child;
  const CentriaBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: CentriaTheme.bgDark,
      body: Stack(
        children: [
          // Background base gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CentriaTheme.bgDark,
                  CentriaTheme.bgMid,
                  CentriaTheme.bgDeep,
                ],
              ),
            ),
          ),

          // Top-left ambient cyan glow
          Positioned(
            top: -size.height * 0.15,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00BCD4).withValues(alpha: 0.14),
                    const Color(0xFF00BCD4).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // Bottom-right ambient violet glow
          Positioned(
            bottom: -size.height * 0.15,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7C4DFF).withValues(alpha: 0.16),
                    const Color(0xFF7C4DFF).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // Main child content with SafeArea
          SafeArea(
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Frosted Glassmorphism Card with Hairline Border & Blur
class CentriaGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double maxWidth;

  const CentriaGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth = 440,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: padding ?? const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.14),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                  BoxShadow(
                    color: CentriaTheme.primaryCyan.withValues(alpha: 0.04),
                    blurRadius: 40,
                    spreadRadius: -10,
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// S+ Grade Tactile Button with Apple-smooth spring scale, haptics & skeleton loading
class CentriaButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;

  const CentriaButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
  });

  @override
  State<CentriaButton> createState() => _CentriaButtonState();
}

class _CentriaButtonState extends State<CentriaButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.isLoading || widget.onPressed == null) return;
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails _) {
    if (_isPressed) setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (_isPressed) setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const FormActionSkeleton();
    }

    final isEnabled = widget.onPressed != null;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: isEnabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: widget.isSecondary ? null : CentriaTheme.buttonGradient,
            color: widget.isSecondary
                ? Colors.white.withValues(alpha: 0.08)
                : null,
            borderRadius: BorderRadius.circular(14),
            border: widget.isSecondary
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.20),
                    width: 1.0,
                  )
                : null,
            boxShadow: widget.isSecondary || !isEnabled
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFF00BCD4).withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    color: isEnabled
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Precision Text Input with Cupertino-smooth micro-animations
class CentriaTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final bool readOnly;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final VoidCallback? onEditingComplete;

  const CentriaTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.validator,
    this.onEditingComplete,
  });

  @override
  State<CentriaTextField> createState() => _CentriaTextFieldState();
}

class _CentriaTextFieldState extends State<CentriaTextField> {
  bool _obscured = true;
  bool _isFocused = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: widget.readOnly
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isFocused
              ? CentriaTheme.primaryCyan
              : Colors.white.withValues(alpha: 0.12),
          width: _isFocused ? 1.6 : 1.0,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: CentriaTheme.primaryCyan.withValues(alpha: 0.20),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        readOnly: widget.readOnly,
        obscureText: widget.isPassword && _obscured,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        autofillHints: widget.autofillHints,
        style: TextStyle(
          color: widget.readOnly
              ? Colors.white.withValues(alpha: 0.70)
              : Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        cursorColor: CentriaTheme.primaryCyan,
        onEditingComplete: widget.onEditingComplete,
        validator: widget.validator,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.38),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            widget.prefixIcon,
            color: _isFocused
                ? CentriaTheme.primaryCyan
                : Colors.white.withValues(alpha: 0.50),
            size: 20,
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.white.withValues(alpha: 0.50),
                    size: 20,
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() => _obscured = !_obscured);
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

/// Floating Apple-style SnackBar notification
void showCentriaSnack(
  BuildContext context, {
  required String message,
  bool isError = true,
}) {
  HapticFeedback.mediumImpact();
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 10,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      backgroundColor: isError
          ? const Color(0xFFD32F2F).withValues(alpha: 0.95)
          : const Color(0xFF2E7D32).withValues(alpha: 0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 3200),
    ),
  );
}

/// Dedicated Read-Only / Locked Field with distinct Apple-style locked credential appearance
class CentriaLockedField extends StatelessWidget {
  final String label;
  final String value;
  final IconData prefixIcon;

  const CentriaLockedField({
    super.key,
    required this.label,
    required this.value,
    this.prefixIcon = Icons.email_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.50),
                  letterSpacing: 0.2,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.lock_rounded,
                    size: 12,
                    color: CentriaTheme.primaryCyan.withValues(alpha: 0.70),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Not Editable',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: CentriaTheme.primaryCyan.withValues(alpha: 0.70),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                prefixIcon,
                color: Colors.white.withValues(alpha: 0.40),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 13,
                      color: CentriaTheme.primaryCyan.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

