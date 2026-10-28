import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_tokens.dart';

class CentriaTheme {
  CentriaTheme._();

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: CentriaColors.canvasBase,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: CentriaColors.primary900,
        onPrimary: Colors.white,
        primaryContainer: CentriaColors.primary50,
        onPrimaryContainer: CentriaColors.primary900,
        secondary: CentriaColors.cognitiveDeep,
        onSecondary: Colors.white,
        secondaryContainer: CentriaColors.cognitiveSurface,
        onSecondaryContainer: CentriaColors.cognitiveDeep,
        error: CentriaColors.criticalFg,
        onError: Colors.white,
        surface: CentriaColors.surfaceCard,
        onSurface: CentriaColors.textPrimary,
        outline: CentriaColors.structuralStroke,
        outlineVariant: CentriaColors.structuralStrokeStrong,
      ),
      dividerTheme: const DividerThemeData(
        color: CentriaColors.structuralStroke,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: CentriaColors.surfaceCard,
        foregroundColor: CentriaColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        color: CentriaColors.surfaceCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: CentriaRadii.containerRadius,
          side: const BorderSide(color: CentriaColors.structuralStroke),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CentriaColors.primary900,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: CentriaRadii.componentRadius,
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CentriaColors.textPrimary,
          side: const BorderSide(color: CentriaColors.structuralStroke),
          shape: RoundedRectangleBorder(
            borderRadius: CentriaRadii.componentRadius,
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: CentriaRadii.componentRadius,
          borderSide: const BorderSide(color: CentriaColors.structuralStrokeStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: CentriaRadii.componentRadius,
          borderSide: const BorderSide(color: CentriaColors.structuralStrokeStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: CentriaRadii.componentRadius,
          borderSide: const BorderSide(color: CentriaColors.primary900, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: CentriaRadii.componentRadius,
          borderSide: const BorderSide(color: CentriaColors.criticalFg),
        ),
        labelStyle: GoogleFonts.inter(
          color: CentriaColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.inter(
          color: CentriaColors.textMuted,
          fontSize: 13,
        ),
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.inter(color: CentriaColors.textPrimary),
        displayMedium: GoogleFonts.inter(color: CentriaColors.textPrimary),
        displaySmall: GoogleFonts.inter(color: CentriaColors.textPrimary),
        headlineLarge: GoogleFonts.inter(color: CentriaColors.textPrimary),
        headlineMedium: GoogleFonts.inter(color: CentriaColors.textPrimary),
        headlineSmall: GoogleFonts.inter(color: CentriaColors.textPrimary),
        titleLarge: GoogleFonts.inter(color: CentriaColors.textPrimary),
        titleMedium: GoogleFonts.inter(color: CentriaColors.textPrimary),
        titleSmall: GoogleFonts.inter(color: CentriaColors.textPrimary),
        bodyLarge: GoogleFonts.inter(color: CentriaColors.textPrimary),
        bodyMedium: GoogleFonts.inter(color: CentriaColors.textPrimary),
        bodySmall: GoogleFonts.inter(color: CentriaColors.textSecondary),
        labelLarge: GoogleFonts.inter(color: CentriaColors.textSecondary),
        labelMedium: GoogleFonts.inter(color: CentriaColors.textSecondary),
        labelSmall: GoogleFonts.inter(color: CentriaColors.textSecondary),
      ),
    );
  }
}
