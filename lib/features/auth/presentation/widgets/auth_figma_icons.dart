import 'package:flutter/material.dart';

class MotodigoFlagCmrIcon extends StatelessWidget {
  final double width;
  final double height;

  const MotodigoFlagCmrIcon({super.key, this.width = 28, this.height = 20});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(width, height), painter: _FlagCmrPainter());
  }
}

class MotodigoPersonGrayIcon extends StatelessWidget {
  final double size;

  const MotodigoPersonGrayIcon({super.key, this.size = 26});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _PersonPainter());
  }
}

class MotodigoPasswordGrayIcon extends StatelessWidget {
  final double size;

  const MotodigoPasswordGrayIcon({super.key, this.size = 26});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _LockPainter(Color(0xFF8A968C)),
    );
  }
}

class MotodigoWrongPasswordRedIcon extends StatelessWidget {
  final double size;

  const MotodigoWrongPasswordRedIcon({super.key, this.size = 26});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _LockPainter(Color(0xFFE5484D)),
    );
  }
}

class MotodigoShowPasswordGrayIcon extends StatelessWidget {
  final double size;

  const MotodigoShowPasswordGrayIcon({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _EyePainter());
  }
}

class MotodigoPendingGrayIcon extends StatelessWidget {
  final double size;

  const MotodigoPendingGrayIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _PendingPainter());
  }
}

class MotodigoGpuAcceptedGreenIcon extends StatelessWidget {
  final double size;

  const MotodigoGpuAcceptedGreenIcon({super.key, this.size = 30});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _AcceptedPainter());
  }
}

class _FlagCmrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final outer = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.height * 0.18),
    );
    canvas.save();
    canvas.clipRRect(outer);

    final stripeWidth = size.width / 3;
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = const Color(0xFF178A44);
    canvas.drawRect(Rect.fromLTWH(0, 0, stripeWidth, size.height), paint);
    paint.color = const Color(0xFFE5484D);
    canvas.drawRect(
      Rect.fromLTWH(stripeWidth, 0, stripeWidth, size.height),
      paint,
    );
    paint.color = const Color(0xFFF5C518);
    canvas.drawRect(
      Rect.fromLTWH(stripeWidth * 2, 0, stripeWidth, size.height),
      paint,
    );
    canvas.restore();

    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(outer.deflate(0.5), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PersonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 18, 18, (canvas) {
      final paint = _strokePaint(const Color(0xFF8A968C), 1.5);
      canvas.drawPath(
        Path()
          ..moveTo(14.25, 15.75)
          ..lineTo(14.25, 14.25)
          ..cubicTo(14.25, 13.4544, 13.9339, 12.6913, 13.3713, 12.1287)
          ..cubicTo(12.8087, 11.5661, 12.0456, 11.25, 11.25, 11.25)
          ..lineTo(6.75, 11.25)
          ..cubicTo(5.95435, 11.25, 5.19129, 11.5661, 4.62868, 12.1287)
          ..cubicTo(4.06607, 12.6913, 3.75, 13.4544, 3.75, 14.25)
          ..lineTo(3.75, 15.75),
        paint,
      );
      canvas.drawCircle(const Offset(9, 5.25), 3, paint);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LockPainter extends CustomPainter {
  final Color color;

  const _LockPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 18, 18, (canvas) {
      final paint = _strokePaint(color, 1.5);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(2.25, 8.25, 13.5, 8.25),
          const Radius.circular(1.5),
        ),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(5.25, 8.25)
          ..lineTo(5.25, 5.25)
          ..cubicTo(5.25, 4.25544, 5.64509, 3.30161, 6.34835, 2.59835)
          ..cubicTo(7.05161, 1.89509, 8.00544, 1.5, 9, 1.5)
          ..cubicTo(9.99456, 1.5, 10.9484, 1.89509, 11.6517, 2.59835)
          ..cubicTo(12.3549, 3.30161, 12.75, 4.25544, 12.75, 5.25)
          ..lineTo(12.75, 8.25),
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _LockPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _EyePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 19, 19, (canvas) {
      final paint = _strokePaint(const Color(0xFF8A968C), 1.58333);
      canvas.drawPath(
        Path()
          ..moveTo(1.58301, 9.49992)
          ..cubicTo(1.58301, 9.49992, 3.95801, 3.95825, 9.49967, 3.95825)
          ..cubicTo(15.0413, 3.95825, 17.4163, 9.49992, 17.4163, 9.49992)
          ..cubicTo(17.4163, 9.49992, 15.0413, 15.0416, 9.49967, 15.0416)
          ..cubicTo(3.95801, 15.0416, 1.58301, 9.49992, 1.58301, 9.49992),
        paint,
      );
      canvas.drawCircle(const Offset(9.5, 9.5), 2.375, paint);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PendingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 16, 16, (canvas) {
      final paint = _strokePaint(const Color(0xFF8A968C), 1.33333);
      canvas.drawCircle(const Offset(7.99967, 7.99992), 6.66667, paint);
      canvas.drawPath(
        Path()
          ..moveTo(8, 4)
          ..lineTo(8, 8)
          ..lineTo(10.6667, 9.33333),
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AcceptedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.shortestSide * 0.32),
    );
    canvas.drawRRect(rect, Paint()..color = const Color(0xFF16A34A));

    _drawScaled(canvas, size, 22, 22, (canvas) {
      final paint = _strokePaint(Colors.white, 1.875);
      canvas.drawPath(
        Path()
          ..moveTo(16, 7.25)
          ..lineTo(9.125, 14.125)
          ..lineTo(6, 11),
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Paint _strokePaint(Color color, double width) {
  return Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
}

void _drawScaled(
  Canvas canvas,
  Size size,
  double viewBoxWidth,
  double viewBoxHeight,
  void Function(Canvas canvas) draw,
) {
  final scale = size.shortestSide / viewBoxWidth;
  final dx = (size.width - viewBoxWidth * scale) / 2;
  final dy = (size.height - viewBoxHeight * scale) / 2;
  canvas
    ..save()
    ..translate(dx, dy)
    ..scale(scale);
  draw(canvas);
  canvas.restore();
}
