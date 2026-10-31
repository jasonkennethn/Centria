import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color paper = Color(0xFFF7F8F5);
  static const Color white = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF182A27);
  static const Color ink2 = Color(0xFF243B35);
  static const Color muted = Color(0xFF586B5E);
  static const Color soft = Color(0xFFEFF3EE);
  static const Color line = Color(0xFFDFE6DF);
  static const Color teal = Color(0xFF176B5D);
  static const Color teal2 = Color(0xFF0D5348);
  static const Color pale = Color(0xFFE8F1E9);
  static const Color lime = Color(0xFFD9ED9B);
  static const Color violet = Color(0xFF6657A4);
  static const Color violetPale = Color(0xFFF2EFFA);
  static const Color amber = Color(0xFFA86424);
  static const Color amberPale = Color(0xFFF6ECD9);
  static const Color greenDone = Color(0xFF377750);
  static const Color greenPale = Color(0xFFE4F2E4);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorPale = Color(0xFFFFDAD6);
}

class AppleGlass {
  /// Apple frosted glass container decoration with hairline border & ambient shadow
  static BoxDecoration decoration({
    double radius = 24,
    Color? color,
    Color? borderColor,
    bool glow = false,
  }) {
    return BoxDecoration(
      color: color ?? Colors.white.withValues(alpha: 0.78),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? Colors.white.withValues(alpha: 0.9),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: glow
              ? AppColors.teal.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.04),
          blurRadius: 28,
          offset: const Offset(0, 8),
          spreadRadius: 0,
        ),
      ],
    );
  }

  /// Dark / Ambient glass decoration for pills and floating controls
  static BoxDecoration darkPill({double radius = 999}) {
    return BoxDecoration(
      color: const Color(0xFF162A24).withValues(alpha: 0.88),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.16),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.18),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}

class GlassBox extends StatelessWidget {
  final Widget child;
  final double blur;
  final double radius;
  final Color? color;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const GlassBox({
    super.key,
    required this.child,
    this.blur = 20,
    this.radius = 24,
    this.color,
    this.borderColor,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }
    final container = Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: AppleGlass.decoration(
              radius: radius,
              color: color,
              borderColor: borderColor,
            ),
            child: content,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: container,
      );
    }
    return container;
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.paper,
      colorScheme: const ColorScheme.light(
        primary: AppColors.teal,
        secondary: AppColors.lime,
        surface: AppColors.paper,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.ink,
        onSurface: AppColors.ink,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 56,
          fontWeight: FontWeight.w600,
          letterSpacing: -1.8,
          color: AppColors.ink,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 42,
          fontWeight: FontWeight.w600,
          letterSpacing: -1.4,
          color: AppColors.ink,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: -1.0,
          color: AppColors.ink,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          color: AppColors.ink,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: AppColors.ink,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.muted,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.muted,
          height: 1.5,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.ink),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.82),
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white.withValues(alpha: 0.9)),
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.88),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.teal, width: 1.8),
        ),
        labelStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
