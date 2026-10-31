import 'package:flutter/material.dart';

/// Official Brand Vector Icons rendered with CustomPainter for 100% cross-platform
/// reliability (Linux, Windows, macOS, Android, iOS) without any external font or network dependency.
class BrandIcons {
  /// Official GitHub Octocat Mark
  static Widget github({double size = 20, Color? color}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GitHubPainter(color: color ?? const Color(0xFF24292F)),
      ),
    );
  }

  /// NeonDB Official Tri-Prism Mark
  static Widget neonDb({double size = 20}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _NeonDbPainter(),
      ),
    );
  }

  /// Cloud Object Storage (S3 / Bucket) Mark
  static Widget cloudStorage({double size = 20, Color? color}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CloudStoragePainter(color: color ?? const Color(0xFFE25A24)),
      ),
    );
  }

  /// Brevo Email & Automation Mark
  static Widget brevo({double size = 20, Color? color}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BrevoPainter(color: color ?? const Color(0xFF0052FF)),
      ),
    );
  }
}

class _GitHubPainter extends CustomPainter {
  final Color color;
  const _GitHubPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Official GitHub Octocat SVG Path (0 0 24 24)
    final path = Path();
    path.moveTo(12.0, 2.0);
    path.cubicTo(6.477, 2.0, 2.0, 6.484, 2.0, 12.017);
    path.cubicTo(2.0, 16.442, 4.865, 20.197, 8.839, 21.521);
    path.cubicTo(9.339, 21.613, 9.521, 21.304, 9.521, 21.038);
    path.cubicTo(9.521, 20.801, 9.513, 20.17, 9.508, 19.335);
    path.cubicTo(6.726, 19.94, 6.139, 17.992, 6.139, 17.992);
    path.cubicTo(5.685, 16.834, 5.029, 16.526, 5.029, 16.526);
    path.cubicTo(4.121, 15.906, 5.098, 15.918, 5.098, 15.918);
    path.cubicTo(6.101, 15.988, 6.628, 16.95, 6.628, 16.95);
    path.cubicTo(7.52, 18.48, 8.969, 18.038, 9.538, 17.782);
    path.cubicTo(9.63, 17.135, 9.888, 16.694, 10.174, 16.444);
    path.cubicTo(7.954, 16.191, 5.619, 15.331, 5.619, 11.493);
    path.cubicTo(5.619, 10.4, 6.009, 9.505, 6.648, 8.805);
    path.cubicTo(6.545, 8.552, 6.202, 7.533, 6.746, 6.155);
    path.cubicTo(6.746, 6.155, 7.586, 5.885, 9.496, 7.181);
    path.cubicTo(10.294, 6.959, 11.144, 6.848, 11.994, 6.844);
    path.cubicTo(12.844, 6.848, 13.694, 6.959, 14.492, 7.181);
    path.cubicTo(16.402, 5.885, 17.242, 6.155, 17.242, 6.155);
    path.cubicTo(17.786, 7.533, 17.443, 8.552, 17.34, 8.805);
    path.cubicTo(17.98, 9.505, 18.368, 10.4, 18.368, 11.493);
    path.cubicTo(18.368, 15.341, 16.029, 16.188, 13.803, 16.436);
    path.cubicTo(14.162, 16.745, 14.481, 17.356, 14.481, 18.291);
    path.cubicTo(14.481, 19.629, 14.469, 20.71, 14.469, 21.038);
    path.cubicTo(14.469, 21.306, 14.649, 21.618, 15.157, 21.52);
    path.cubicTo(19.129, 20.194, 21.992, 16.44, 21.992, 12.017);
    path.cubicTo(21.992, 6.484, 17.515, 2.0, 12.0, 2.0);
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GitHubPainter oldDelegate) => oldDelegate.color != color;
}

class _NeonDbPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final neonPaint = Paint()
      ..color = const Color(0xFF00E599)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final darkPaint = Paint()
      ..color = const Color(0xFF0D382A)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Outer Neon Triangle Slash
    final path1 = Path();
    path1.moveTo(4, 20);
    path1.lineTo(12, 4);
    path1.lineTo(20, 20);
    path1.close();
    canvas.drawPath(path1, darkPaint);

    final path2 = Path();
    path2.moveTo(8, 19);
    path2.lineTo(12, 8);
    path2.lineTo(16, 19);
    path2.close();
    canvas.drawPath(path2, neonPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CloudStoragePainter extends CustomPainter {
  final Color color;
  const _CloudStoragePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // S3 Cloud Cylinder Mark
    final path = Path();
    path.addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(3, 4, 18, 16), const Radius.circular(5)));
    canvas.drawPath(path, paint);

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(6, 9), const Offset(18, 9), linePaint);
    canvas.drawLine(const Offset(6, 14), const Offset(18, 14), linePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CloudStoragePainter oldDelegate) => oldDelegate.color != color;
}

class _BrevoPainter extends CustomPainter {
  final Color color;
  const _BrevoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Rounded Envelope / Messenger badge
    final path = Path();
    path.addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(3, 5, 18, 14), const Radius.circular(4)));
    canvas.drawPath(path, paint);

    final flapPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final flap = Path();
    flap.moveTo(5, 7);
    flap.lineTo(12, 12);
    flap.lineTo(19, 7);
    canvas.drawPath(flap, flapPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BrevoPainter oldDelegate) => oldDelegate.color != color;
}
