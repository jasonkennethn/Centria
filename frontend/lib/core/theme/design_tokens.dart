import 'package:flutter/material.dart';

/// Centria Design Tokens — Executive Precision
/// Authoritative tokens from DESIGN.md
class CentriaColors {
  CentriaColors._();

  // Base Canvases & Card Surfaces
  static const Color canvasBase = Color(0xFFFBFBF9);
  static const Color canvasSubdued = Color(0xFFF8F8F6);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceInset = Color(0xFFF1F5F9);
  static const Color structuralStroke = Color(0xFFE2E8F0);
  static const Color structuralStrokeStrong = Color(0xFFCBD5E1);

  // Text / Content
  static const Color textPrimary = Color(0xFF0D1C2E);
  static const Color textSecondary = Color(0xFF404947);
  static const Color textMuted = Color(0xFF707977);
  static const Color textInverse = Color(0xFFEAF1FF);

  // Primary Enterprise Tone (Authority, Governance, Navigation)
  static const Color primary900 = Color(0xFF0C4A45); // Dominant
  static const Color primary700 = Color(0xFF0F766E); // Interactive / Hover
  static const Color primary500 = Color(0xFF14B8A6); // Accent / Metrics
  static const Color primary50 = Color(0xFFF0FDFA);  // Tint / Highlight

  // Cognitive & Machine Intelligence (AI Layer)
  static const Color cognitiveDeep = Color(0xFF6D28D9);
  static const Color cognitiveInteractive = Color(0xFF7C3AED);
  static const Color cognitiveBorder = Color(0xFFDDD6FE);
  static const Color cognitiveSurface = Color(0xFFF5F3FF);

  // Semantic & Provenance Tokens
  static const Color verifiedFg = Color(0xFF059669);
  static const Color verifiedBg = Color(0xFFECFDF5);
  static const Color verifiedBorder = Color(0xFFA7F3D0);

  static const Color pendingFg = Color(0xFFD97706);
  static const Color pendingBg = Color(0xFFFFFBEB);
  static const Color pendingBorder = Color(0xFFFDE68A);

  static const Color criticalFg = Color(0xFFDC2626);
  static const Color criticalBg = Color(0xFFFEF2F2);
  static const Color criticalBorder = Color(0xFFFECACA);

  static const Color infoFg = Color(0xFF2563EB);
  static const Color infoBg = Color(0xFFEFF6FF);
  static const Color infoBorder = Color(0xFFBFDBFE);
}

class CentriaRadii {
  CentriaRadii._();

  static const double base = 4.0;
  static const double component = 6.0;
  static const double container = 8.0;
  static const double full = 9999.0;

  static const BorderRadius baseRadius = BorderRadius.all(Radius.circular(base));
  static const BorderRadius componentRadius = BorderRadius.all(Radius.circular(component));
  static const BorderRadius containerRadius = BorderRadius.all(Radius.circular(container));
  static const BorderRadius fullRadius = BorderRadius.all(Radius.circular(full));
}

class CentriaSpacing {
  CentriaSpacing._();

  static const double space2xs = 2.0;
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 12.0;
  static const double spaceBase = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;
  static const double space2xl = 48.0;
}
