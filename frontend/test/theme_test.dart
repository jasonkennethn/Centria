import 'package:flutter_test/flutter_test.dart';
import 'package:centria/core/theme/design_tokens.dart';
import 'package:centria/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Theme tokens match Executive Precision specification', () {
    expect(CentriaColors.primary900, const Color(0xFF0C4A45));
    expect(CentriaColors.cognitiveDeep, const Color(0xFF6D28D9));
    expect(CentriaColors.canvasBase, const Color(0xFFFBFBF9));
    expect(CentriaColors.surfaceCard, const Color(0xFFFFFFFF));
    expect(CentriaColors.verifiedFg, const Color(0xFF059669));
    expect(CentriaColors.pendingFg, const Color(0xFFD97706));
    expect(CentriaColors.criticalFg, const Color(0xFFDC2626));

    final theme = CentriaTheme.lightTheme;
    expect(theme.brightness, Brightness.light);
    expect(theme.scaffoldBackgroundColor, CentriaColors.canvasBase);
    expect(theme.colorScheme.primary, CentriaColors.primary900);
  });
}
