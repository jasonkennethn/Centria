import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Pure Vector Icons drawn with CustomPainter.
/// Zero font dependencies, zero network calls, 100% reliable across Linux, Windows, macOS, iOS, and Android.
class AppIcons {
  /// Folder with open flap (Projects)
  static Widget folder({double size = 20, Color color = const Color(0xFF176B5D)}) {
    return _paint(size, _FolderPainter(color: color));
  }

  /// Checklist with checkboxes and horizontal bars (Tasks & Issues)
  static Widget checklist({double size = 20, Color color = const Color(0xFF176B5D)}) {
    return _paint(size, _ChecklistPainter(color: color));
  }

  /// Open book with spine and curved pages (Knowledge Base)
  static Widget book({double size = 20, Color color = const Color(0xFF176B5D)}) {
    return _paint(size, _BookPainter(color: color));
  }

  /// Shield badge with centered checkmark (Approval Gates)
  static Widget shieldCheck({double size = 20, Color color = const Color(0xFFA86424)}) {
    return _paint(size, _ShieldCheckPainter(color: color));
  }

  /// 4-point AI sparkles with secondary sparkle (Ground-Truth AI)
  static Widget sparkles({double size = 20, Color color = const Color(0xFF6657A4)}) {
    return _paint(size, _SparklesPainter(color: color));
  }

  /// Shield outline (Trust badges)
  static Widget shield({double size = 16, Color color = const Color(0xFF176B5D)}) {
    return _paint(size, _ShieldPainter(color: color));
  }

  /// Sharp verification checkmark
  static Widget check({double size = 14, Color color = const Color(0xFF176B5D)}) {
    return _paint(size, _CheckPainter(color: color));
  }

  /// Circular badge with checkmark inside
  static Widget checkCircle({double size = 16, Color color = const Color(0xFF377750), bool filled = false}) {
    return _paint(size, _CheckCirclePainter(color: color, filled: filled));
  }

  /// Arrow forward (Right arrow)
  static Widget arrowForward({double size = 16, Color color = Colors.white}) {
    return _paint(size, _ArrowForwardPainter(color: color));
  }

  /// Chevron right (Single angle bracket)
  static Widget chevronRight({double size = 16, Color color = const Color(0xFF182A27)}) {
    return _paint(size, _ChevronRightPainter(color: color));
  }

  /// Close 'X' icon
  static Widget close({double size = 18, Color color = const Color(0xFF182A27)}) {
    return _paint(size, _ClosePainter(color: color));
  }

  /// Password Visibility (Eye open)
  static Widget visibility({double size = 20, Color color = const Color(0xFF586B5E)}) {
    return _paint(size, _VisibilityPainter(color: color));
  }

  /// Password Visibility Off (Eye with diagonal slash)
  static Widget visibilityOff({double size = 20, Color color = const Color(0xFF586B5E)}) {
    return _paint(size, _VisibilityOffPainter(color: color));
  }

  /// Notification Bell
  static Widget bell({double size = 20, Color color = const Color(0xFF182A27)}) {
    return _paint(size, _BellPainter(color: color));
  }

  /// Calendar / My Day
  static Widget calendar({double size = 16, Color color = const Color(0xFF176B5D)}) {
    return _paint(size, _CalendarPainter(color: color));
  }

  /// Bolt / Instant sync
  static Widget bolt({double size = 16, Color color = const Color(0xFF6657A4)}) {
    return _paint(size, _BoltPainter(color: color));
  }

  /// Document outline
  static Widget document({double size = 16, Color color = const Color(0xFF176B5D)}) {
    return _paint(size, _DocumentPainter(color: color));
  }

  /// Padlock outline
  static Widget lock({double size = 16, Color color = const Color(0xFF176B5D)}) {
    return _paint(size, _LockPainter(color: color));
  }

  /// Plus / Add
  static Widget add({double size = 16, Color color = const Color(0xFF176B5D)}) {
    return _paint(size, _AddPainter(color: color));
  }

  /// Minus / Remove
  static Widget remove({double size = 16, Color color = const Color(0xFF176B5D)}) {
    return _paint(size, _RemovePainter(color: color));
  }

  /// Android bugdroid mark
  static Widget android({double size = 16, Color color = const Color(0xFF176B5D)}) {
    return _paint(size, _AndroidPainter(color: color));
  }

  /// Apple mark
  static Widget apple({double size = 16, Color color = const Color(0xFF176B5D)}) {
    return _paint(size, _ApplePainter(color: color));
  }

  /// Arrow downward
  static Widget arrowDown({double size = 16, Color color = Colors.white}) {
    return _paint(size, _ArrowDownPainter(color: color));
  }

  /// Puzzle extension mark
  static Widget extension({double size = 20, Color color = const Color(0xFF176B5D)}) {
    return _paint(size, _ExtensionPainter(color: color));
  }

  static Widget _paint(double size, CustomPainter painter) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: painter),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom Painters (Vector Math normalized to 24x24)
// ---------------------------------------------------------------------------

class _FolderPainter extends CustomPainter {
  final Color color;
  const _FolderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(3, 7)
      ..lineTo(3, 19)
      ..arcToPoint(const Offset(5, 21), radius: const Radius.circular(2))
      ..lineTo(19, 21)
      ..arcToPoint(const Offset(21, 19), radius: const Radius.circular(2))
      ..lineTo(21, 9)
      ..arcToPoint(const Offset(19, 7), radius: const Radius.circular(2))
      ..lineTo(12, 7)
      ..lineTo(10, 5)
      ..lineTo(5, 5)
      ..arcToPoint(const Offset(3, 7), radius: const Radius.circular(2))
      ..close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FolderPainter oldDelegate) => oldDelegate.color != color;
}

class _ChecklistPainter extends CustomPainter {
  final Color color;
  const _ChecklistPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Checkmark 1
    final check1 = Path()
      ..moveTo(3.5, 7.5)
      ..lineTo(5.5, 9.5)
      ..lineTo(9.5, 5.5);
    canvas.drawPath(check1, stroke);

    // Line 1
    canvas.drawLine(const Offset(13, 7.5), const Offset(20.5, 7.5), stroke);

    // Checkmark 2
    final check2 = Path()
      ..moveTo(3.5, 14.5)
      ..lineTo(5.5, 16.5)
      ..lineTo(9.5, 12.5);
    canvas.drawPath(check2, stroke);

    // Line 2
    canvas.drawLine(const Offset(13, 14.5), const Offset(20.5, 14.5), stroke);

    // Bottom line 3
    canvas.drawLine(const Offset(5, 19.5), const Offset(7, 19.5), stroke);
    canvas.drawLine(const Offset(13, 19.5), const Offset(18.5, 19.5), stroke);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ChecklistPainter oldDelegate) => oldDelegate.color != color;
}

class _BookPainter extends CustomPainter {
  final Color color;
  const _BookPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Left Page
    final left = Path()
      ..moveTo(12, 6.5)
      ..cubicTo(10, 5, 6, 5, 3, 6)
      ..lineTo(3, 19)
      ..cubicTo(6, 18, 10, 18, 12, 19.5);
    canvas.drawPath(left, stroke);

    // Right Page
    final right = Path()
      ..moveTo(12, 6.5)
      ..cubicTo(14, 5, 18, 5, 21, 6)
      ..lineTo(21, 19)
      ..cubicTo(18, 18, 14, 18, 12, 19.5);
    canvas.drawPath(right, stroke);

    // Spine
    canvas.drawLine(const Offset(12, 6.5), const Offset(12, 19.5), stroke);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BookPainter oldDelegate) => oldDelegate.color != color;
}

class _ShieldCheckPainter extends CustomPainter {
  final Color color;
  const _ShieldCheckPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Shield contour
    final shield = Path()
      ..moveTo(12, 3)
      ..lineTo(4, 6.5)
      ..lineTo(4, 12.5)
      ..cubicTo(4, 17.5, 7.5, 21, 12, 22)
      ..cubicTo(16.5, 21, 20, 17.5, 20, 12.5)
      ..lineTo(20, 6.5)
      ..close();
    canvas.drawPath(shield, stroke);

    // Check inside shield
    final check = Path()
      ..moveTo(9, 12.5)
      ..lineTo(11, 14.5)
      ..lineTo(15.5, 10);
    canvas.drawPath(check, stroke);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ShieldCheckPainter oldDelegate) => oldDelegate.color != color;
}

class _SparklesPainter extends CustomPainter {
  final Color color;
  const _SparklesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Main 4-point sparkle centered at (10, 12)
    final mainStar = Path();
    mainStar.moveTo(10, 4);
    mainStar.cubicTo(10, 8.5, 11.5, 10, 16, 10);
    mainStar.cubicTo(11.5, 10, 10, 11.5, 10, 16);
    mainStar.cubicTo(10, 11.5, 8.5, 10, 4, 10);
    mainStar.cubicTo(8.5, 10, 10, 8.5, 10, 4);
    mainStar.close();
    canvas.drawPath(mainStar, fill);

    // Secondary mini sparkle at (18, 5)
    final miniStar1 = Path();
    miniStar1.moveTo(18, 2);
    miniStar1.cubicTo(18, 4, 19, 5, 21, 5);
    miniStar1.cubicTo(19, 5, 18, 6, 18, 8);
    miniStar1.cubicTo(18, 6, 17, 5, 15, 5);
    miniStar1.cubicTo(17, 5, 18, 4, 18, 2);
    miniStar1.close();
    canvas.drawPath(miniStar1, fill);

    // Tertiary micro sparkle at (17, 18)
    final miniStar2 = Path();
    miniStar2.moveTo(17, 16);
    miniStar2.cubicTo(17, 17.5, 17.8, 18.5, 19.5, 18.5);
    miniStar2.cubicTo(17.8, 18.5, 17, 19.5, 17, 21);
    miniStar2.cubicTo(17, 19.5, 16.2, 18.5, 14.5, 18.5);
    miniStar2.cubicTo(16.2, 18.5, 17, 17.5, 17, 16);
    miniStar2.close();
    canvas.drawPath(miniStar2, fill);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SparklesPainter oldDelegate) => oldDelegate.color != color;
}

class _ShieldPainter extends CustomPainter {
  final Color color;
  const _ShieldPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final shield = Path()
      ..moveTo(12, 3)
      ..lineTo(4, 6.5)
      ..lineTo(4, 12.5)
      ..cubicTo(4, 17.5, 7.5, 21, 12, 22)
      ..cubicTo(16.5, 21, 20, 17.5, 20, 12.5)
      ..lineTo(20, 6.5)
      ..close();
    canvas.drawPath(shield, stroke);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ShieldPainter oldDelegate) => oldDelegate.color != color;
}

class _CheckPainter extends CustomPainter {
  final Color color;
  const _CheckPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(4.5, 12.5)
      ..lineTo(9.5, 17.5)
      ..lineTo(19.5, 6.5);

    canvas.drawPath(path, stroke);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) => oldDelegate.color != color;
}

class _CheckCirclePainter extends CustomPainter {
  final Color color;
  final bool filled;
  const _CheckCirclePainter({required this.color, this.filled = false});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    if (filled) {
      final fill = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(const Offset(12, 12), 10, fill);

      final check = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path()
        ..moveTo(7.5, 12)
        ..lineTo(10.5, 15)
        ..lineTo(16.5, 9);
      canvas.drawPath(path, check);
    } else {
      final stroke = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawCircle(const Offset(12, 12), 9, stroke);

      final path = Path()
        ..moveTo(8, 12)
        ..lineTo(11, 15)
        ..lineTo(16, 9.5);
      canvas.drawPath(path, stroke);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CheckCirclePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.filled != filled;
}

class _ArrowForwardPainter extends CustomPainter {
  final Color color;
  const _ArrowForwardPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Stem
    canvas.drawLine(const Offset(4, 12), const Offset(19, 12), stroke);

    // Head
    final head = Path()
      ..moveTo(13, 6)
      ..lineTo(19, 12)
      ..lineTo(13, 18);
    canvas.drawPath(head, stroke);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ArrowForwardPainter oldDelegate) => oldDelegate.color != color;
}

class _ChevronRightPainter extends CustomPainter {
  final Color color;
  const _ChevronRightPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(9, 6)
      ..lineTo(15, 12)
      ..lineTo(9, 18);
    canvas.drawPath(path, stroke);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ChevronRightPainter oldDelegate) => oldDelegate.color != color;
}

class _ClosePainter extends CustomPainter {
  final Color color;
  const _ClosePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(5, 5), const Offset(19, 19), stroke);
    canvas.drawLine(const Offset(19, 5), const Offset(5, 19), stroke);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ClosePainter oldDelegate) => oldDelegate.color != color;
}

class _VisibilityPainter extends CustomPainter {
  final Color color;
  const _VisibilityPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Eye outline
    final eye = Path()
      ..moveTo(2, 12)
      ..cubicTo(5, 6, 19, 6, 22, 12)
      ..cubicTo(19, 18, 5, 18, 2, 12)
      ..close();
    canvas.drawPath(eye, stroke);

    // Pupil
    canvas.drawCircle(const Offset(12, 12), 3, stroke);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _VisibilityPainter oldDelegate) => oldDelegate.color != color;
}

class _VisibilityOffPainter extends CustomPainter {
  final Color color;
  const _VisibilityOffPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Eye arc top
    final eyeTop = Path()
      ..moveTo(3.5, 10.5)
      ..cubicTo(6, 6.5, 12, 6, 17, 7.5);
    canvas.drawPath(eyeTop, stroke);

    // Eye arc bottom
    final eyeBottom = Path()
      ..moveTo(7, 16.5)
      ..cubicTo(12, 18, 18, 16.5, 20.5, 13.5);
    canvas.drawPath(eyeBottom, stroke);

    // Pupil arc
    final pupil = Path()
      ..moveTo(10, 10.5)
      ..arcToPoint(const Offset(14, 14.5), radius: const Radius.circular(3));
    canvas.drawPath(pupil, stroke);

    // Diagonal slash
    canvas.drawLine(const Offset(3, 3), const Offset(21, 21), stroke);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _VisibilityOffPainter oldDelegate) => oldDelegate.color != color;
}

class _BellPainter extends CustomPainter {
  final Color color;
  const _BellPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Bell body
    final bell = Path()
      ..moveTo(12, 3)
      ..cubicTo(9.5, 3, 7, 5, 7, 9)
      ..lineTo(7, 14)
      ..lineTo(5, 17)
      ..lineTo(19, 17)
      ..lineTo(17, 14)
      ..lineTo(17, 9)
      ..cubicTo(17, 5, 14.5, 3, 12, 3)
      ..close();
    canvas.drawPath(bell, stroke);

    // Clapper arc
    final clapper = Path()
      ..moveTo(10, 18)
      ..arcToPoint(const Offset(14, 18), radius: const Radius.circular(2.5));
    canvas.drawPath(clapper, stroke);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BellPainter oldDelegate) => oldDelegate.color != color;
}

class _CalendarPainter extends CustomPainter {
  final Color color;
  const _CalendarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Outer rect
    final rect = RRect.fromRectAndRadius(const Rect.fromLTWH(3, 4, 18, 17), const Radius.circular(3));
    canvas.drawRRect(rect, stroke);

    // Header divider line
    canvas.drawLine(const Offset(3, 9.5), const Offset(21, 9.5), stroke);

    // Ring binders
    canvas.drawLine(const Offset(7, 2), const Offset(7, 5), stroke);
    canvas.drawLine(const Offset(17, 2), const Offset(17, 5), stroke);

    // Inner dots
    canvas.drawCircle(const Offset(8, 14), 0.8, Paint()..color = color..style = PaintingStyle.fill);
    canvas.drawCircle(const Offset(12, 14), 0.8, Paint()..color = color..style = PaintingStyle.fill);
    canvas.drawCircle(const Offset(16, 14), 0.8, Paint()..color = color..style = PaintingStyle.fill);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CalendarPainter oldDelegate) => oldDelegate.color != color;
}

class _BoltPainter extends CustomPainter {
  final Color color;
  const _BoltPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path()
      ..moveTo(13, 2)
      ..lineTo(4, 13)
      ..lineTo(11, 13)
      ..lineTo(9, 22)
      ..lineTo(19, 10)
      ..lineTo(12, 10)
      ..close();

    canvas.drawPath(path, fill);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BoltPainter oldDelegate) => oldDelegate.color != color;
}

class _DocumentPainter extends CustomPainter {
  final Color color;
  const _DocumentPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final doc = Path()
      ..moveTo(6, 3)
      ..lineTo(14, 3)
      ..lineTo(19, 8)
      ..lineTo(19, 21)
      ..lineTo(6, 21)
      ..close();
    canvas.drawPath(doc, stroke);

    // Fold flap
    final flap = Path()
      ..moveTo(14, 3)
      ..lineTo(14, 8)
      ..lineTo(19, 8);
    canvas.drawPath(flap, stroke);

    // Lines
    canvas.drawLine(const Offset(9, 13), const Offset(15, 13), stroke);
    canvas.drawLine(const Offset(9, 17), const Offset(13, 17), stroke);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DocumentPainter oldDelegate) => oldDelegate.color != color;
}

class _LockPainter extends CustomPainter {
  final Color color;
  const _LockPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Body
    final body = RRect.fromRectAndRadius(const Rect.fromLTWH(5, 11, 14, 10), const Radius.circular(2.5));
    canvas.drawRRect(body, stroke);

    // Shackle
    final shackle = Path()
      ..moveTo(8, 11)
      ..lineTo(8, 7)
      ..arcToPoint(const Offset(16, 7), radius: const Radius.circular(4))
      ..lineTo(16, 11);
    canvas.drawPath(shackle, stroke);

    // Keyhole
    canvas.drawCircle(const Offset(12, 15), 1.2, Paint()..color = color);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LockPainter oldDelegate) => oldDelegate.color != color;
}

class _AddPainter extends CustomPainter {
  final Color color;
  const _AddPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(12, 5), const Offset(12, 19), stroke);
    canvas.drawLine(const Offset(5, 12), const Offset(19, 12), stroke);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AddPainter oldDelegate) => oldDelegate.color != color;
}

class _RemovePainter extends CustomPainter {
  final Color color;
  const _RemovePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(5, 12), const Offset(19, 12), stroke);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RemovePainter oldDelegate) => oldDelegate.color != color;
}

class _AndroidPainter extends CustomPainter {
  final Color color;
  const _AndroidPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Antennae
    canvas.drawLine(const Offset(7, 7), const Offset(5, 3), stroke);
    canvas.drawLine(const Offset(17, 7), const Offset(19, 3), stroke);

    // Head dome
    const headRect = Rect.fromLTWH(4, 7, 16, 16);
    canvas.drawArc(headRect, math.pi, math.pi, true, fill);

    // Eyes
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(8.5, 11), 1.2, eyePaint);
    canvas.drawCircle(const Offset(15.5, 11), 1.2, eyePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AndroidPainter oldDelegate) => oldDelegate.color != color;
}

class _ApplePainter extends CustomPainter {
  final Color color;
  const _ApplePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Leaf
    final leaf = Path()
      ..moveTo(13.5, 3)
      ..cubicTo(14.5, 3.5, 16, 5.5, 15.5, 7)
      ..cubicTo(14, 7, 12.5, 5.5, 13.5, 3);
    canvas.drawPath(leaf, fill);

    // Apple body with bite on right side
    final body = Path()
      ..moveTo(12, 8.5)
      ..cubicTo(14, 8.5, 15, 9.5, 17, 9.5)
      ..cubicTo(19, 9.5, 20.5, 11, 20.5, 13.5)
      ..cubicTo(20.5, 14.5, 20, 15.5, 19.5, 16.5)
      ..cubicTo(18.5, 18.5, 17, 21, 15, 21)
      ..cubicTo(13.8, 21, 13.2, 20.2, 12, 20.2)
      ..cubicTo(10.8, 20.2, 10.2, 21, 9, 21)
      ..cubicTo(7, 21, 5.5, 18.5, 4.5, 16.5)
      ..cubicTo(3.5, 14.5, 3.5, 11, 5.5, 9.5)
      ..cubicTo(7, 8.5, 8.5, 8.5, 10, 9.5)
      ..cubicTo(11, 8.5, 11.5, 8.5, 12, 8.5)
      ..close();

    canvas.drawPath(body, fill);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ApplePainter oldDelegate) => oldDelegate.color != color;
}

class _ArrowDownPainter extends CustomPainter {
  final Color color;
  const _ArrowDownPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawLine(const Offset(12, 5), const Offset(12, 18), stroke);
    final arrow = Path()
      ..moveTo(7, 13)
      ..lineTo(12, 18)
      ..lineTo(17, 13);
    canvas.drawPath(arrow, stroke);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ArrowDownPainter oldDelegate) => oldDelegate.color != color;
}

class _ExtensionPainter extends CustomPainter {
  final Color color;
  const _ExtensionPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(5, 5)
      ..lineTo(10, 5)
      ..arcToPoint(const Offset(14, 5), radius: const Radius.circular(2.5), clockwise: true)
      ..lineTo(19, 5)
      ..lineTo(19, 10)
      ..arcToPoint(const Offset(19, 14), radius: const Radius.circular(2.5), clockwise: true)
      ..lineTo(19, 19)
      ..lineTo(14, 19)
      ..arcToPoint(const Offset(10, 19), radius: const Radius.circular(2.5), clockwise: false)
      ..lineTo(5, 19)
      ..lineTo(5, 14)
      ..arcToPoint(const Offset(5, 10), radius: const Radius.circular(2.5), clockwise: false)
      ..close();

    canvas.drawPath(path, stroke);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ExtensionPainter oldDelegate) => oldDelegate.color != color;
}

