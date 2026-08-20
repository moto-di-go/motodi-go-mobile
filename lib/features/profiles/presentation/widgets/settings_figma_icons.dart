import 'package:flutter/material.dart';

/// Icônes Figma line-art de l'écran Paramètres.

class MotodigoSettingsGlobeIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoSettingsGlobeIcon({
    super.key,
    this.size = 22,
    this.color = const Color(0xFF3C4741),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _GlobePainter(color));
  }
}

class MotodigoSettingsBellIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoSettingsBellIcon({super.key, this.size = 22, this.color = const Color(0xFF3C4741)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _BellPainter(color));
  }
}

class MotodigoSettingsCrosshairIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoSettingsCrosshairIcon({
    super.key,
    this.size = 22,
    this.color = const Color(0xFF3C4741),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _CrosshairPainter(color));
  }
}

class MotodigoSettingsShieldIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoSettingsShieldIcon({
    super.key,
    this.size = 22,
    this.color = const Color(0xFF3C4741),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _ShieldPainter(color));
  }
}

class MotodigoSettingsLockIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoSettingsLockIcon({super.key, this.size = 22, this.color = const Color(0xFF3C4741)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _LockPainter(color));
  }
}

class MotodigoSettingsLogoutIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoSettingsLogoutIcon({
    super.key,
    this.size = 22,
    this.color = const Color(0xFFDC2626),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _LogoutPainter(color));
  }
}

Paint _stroke(Color color, double width) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

void _scaled(Canvas canvas, Size size, double vb, void Function(Canvas) draw) {
  final scale = size.shortestSide / vb;
  final dx = (size.width - vb * scale) / 2;
  final dy = (size.height - vb * scale) / 2;
  canvas
    ..save()
    ..translate(dx, dy)
    ..scale(scale);
  draw(canvas);
  canvas.restore();
}

class _GlobePainter extends CustomPainter {
  final Color color;
  _GlobePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _scaled(canvas, size, 24, (canvas) {
      final p = _stroke(color, 1.75);
      canvas.drawCircle(const Offset(12, 12), 9, p);
      canvas.drawPath(
        Path()
          ..moveTo(3, 12)
          ..lineTo(21, 12),
        p,
      );
      canvas.drawPath(
        Path()
          ..moveTo(12, 3)
          ..cubicTo(14.5, 5.5, 16, 8.5, 16, 12)
          ..cubicTo(16, 15.5, 14.5, 18.5, 12, 21)
          ..cubicTo(9.5, 18.5, 8, 15.5, 8, 12)
          ..cubicTo(8, 8.5, 9.5, 5.5, 12, 3)
          ..close(),
        p,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _GlobePainter oldDelegate) => oldDelegate.color != color;
}

class _BellPainter extends CustomPainter {
  final Color color;
  _BellPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _scaled(canvas, size, 24, (canvas) {
      final p = _stroke(color, 1.75);
      canvas.drawPath(
        Path()
          ..moveTo(6, 9)
          ..cubicTo(6, 5.686, 8.686, 3, 12, 3)
          ..cubicTo(15.314, 3, 18, 5.686, 18, 9)
          ..lineTo(18, 13)
          ..lineTo(20, 16)
          ..lineTo(4, 16)
          ..lineTo(6, 13)
          ..close(),
        p,
      );
      canvas.drawPath(
        Path()
          ..moveTo(10, 16)
          ..cubicTo(10, 17.105, 10.895, 18, 12, 18)
          ..cubicTo(13.105, 18, 14, 17.105, 14, 16),
        p,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _BellPainter oldDelegate) => oldDelegate.color != color;
}

class _CrosshairPainter extends CustomPainter {
  final Color color;
  _CrosshairPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _scaled(canvas, size, 24, (canvas) {
      final p = _stroke(color, 1.75);
      canvas.drawCircle(const Offset(12, 12), 7, p);
      canvas.drawCircle(const Offset(12, 12), 2.2, p);
      canvas.drawLine(const Offset(12, 2), const Offset(12, 6), p);
      canvas.drawLine(const Offset(12, 18), const Offset(12, 22), p);
      canvas.drawLine(const Offset(2, 12), const Offset(6, 12), p);
      canvas.drawLine(const Offset(18, 12), const Offset(22, 12), p);
    });
  }

  @override
  bool shouldRepaint(covariant _CrosshairPainter oldDelegate) => oldDelegate.color != color;
}

class _ShieldPainter extends CustomPainter {
  final Color color;
  _ShieldPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _scaled(canvas, size, 24, (canvas) {
      final p = _stroke(color, 1.75);
      canvas.drawPath(
        Path()
          ..moveTo(12, 3)
          ..lineTo(20, 6.5)
          ..lineTo(20, 12.5)
          ..cubicTo(20, 16.8, 16.8, 20.5, 12, 21.5)
          ..cubicTo(7.2, 20.5, 4, 16.8, 4, 12.5)
          ..lineTo(4, 6.5)
          ..close(),
        p,
      );
      canvas.drawPath(
        Path()
          ..moveTo(9, 12)
          ..lineTo(11, 14)
          ..lineTo(15.5, 9.5),
        p,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _ShieldPainter oldDelegate) => oldDelegate.color != color;
}

class _LockPainter extends CustomPainter {
  final Color color;
  _LockPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _scaled(canvas, size, 24, (canvas) {
      final p = _stroke(color, 1.75);
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(5, 11, 14, 10), const Radius.circular(2.5)),
        p,
      );
      canvas.drawPath(
        Path()
          ..moveTo(8, 11)
          ..lineTo(8, 8)
          ..cubicTo(8, 5.79, 9.79, 4, 12, 4)
          ..cubicTo(14.21, 4, 16, 5.79, 16, 8)
          ..lineTo(16, 11),
        p,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _LockPainter oldDelegate) => oldDelegate.color != color;
}

class _LogoutPainter extends CustomPainter {
  final Color color;
  _LogoutPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _scaled(canvas, size, 24, (canvas) {
      final p = _stroke(color, 1.85);
      canvas.drawPath(
        Path()
          ..moveTo(9, 21)
          ..lineTo(5, 21)
          ..cubicTo(4.47, 21, 3.96, 20.79, 3.59, 20.41)
          ..cubicTo(3.21, 20.04, 3, 19.53, 3, 19)
          ..lineTo(3, 5)
          ..cubicTo(3, 4.47, 3.21, 3.96, 3.59, 3.59)
          ..cubicTo(3.96, 3.21, 4.47, 3, 5, 3)
          ..lineTo(9, 3),
        p,
      );
      canvas.drawPath(
        Path()
          ..moveTo(16, 17)
          ..lineTo(21, 12)
          ..lineTo(16, 7),
        p,
      );
      canvas.drawLine(const Offset(21, 12), const Offset(9, 12), p);
    });
  }

  @override
  bool shouldRepaint(covariant _LogoutPainter oldDelegate) => oldDelegate.color != color;
}
