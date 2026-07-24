import 'package:flutter/material.dart';

class MotodigoPendingYellowIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoPendingYellowIcon({
    super.key,
    this.size = 30,
    this.color = const Color(0xFF8A6410),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _PendingYellowPainter(color),
    );
  }
}

class MotodigoFileLeftGrayIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoFileLeftGrayIcon({
    super.key,
    this.size = 30,
    this.color = const Color(0xFFB6BEB6),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _FileLeftGrayPainter(color),
    );
  }
}

class _PendingYellowPainter extends CustomPainter {
  final Color color;

  const _PendingYellowPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 22, 22, (canvas) {
      final paint = _strokePaint(color, 1.83333);
      canvas.drawCircle(const Offset(10.9997, 10.9999), 9.16667, paint);
      canvas.drawPath(
        Path()
          ..moveTo(11, 5.5)
          ..lineTo(11, 11)
          ..lineTo(14.6667, 12.8333),
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _PendingYellowPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _FileLeftGrayPainter extends CustomPainter {
  final Color color;

  const _FileLeftGrayPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 22, 22, (canvas) {
      final paint = _strokePaint(color, 1.83333);
      canvas.drawPath(
        Path()
          ..moveTo(13.7503, 1.83325)
          ..lineTo(5.50033, 1.83325)
          ..cubicTo(5.0141, 1.83325, 4.54778, 2.02641, 4.20396, 2.37022)
          ..cubicTo(3.86015, 2.71404, 3.66699, 3.18036, 3.66699, 3.66659)
          ..lineTo(3.66699, 18.3333)
          ..cubicTo(3.66699, 18.8195, 3.86015, 19.2858, 4.20396, 19.6296)
          ..cubicTo(4.54778, 19.9734, 5.0141, 20.1666, 5.50033, 20.1666)
          ..lineTo(16.5003, 20.1666)
          ..cubicTo(16.9866, 20.1666, 17.4529, 19.9734, 17.7967, 19.6296)
          ..cubicTo(18.1405, 19.2858, 18.3337, 18.8195, 18.3337, 18.3333)
          ..lineTo(18.3337, 6.41659)
          ..lineTo(13.7503, 1.83325),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(12.833, 1.83325)
          ..lineTo(12.833, 6.41659)
          ..lineTo(17.4163, 6.41659),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(14.6663, 11.9167)
          ..lineTo(7.33301, 11.9167)
          ..moveTo(14.6663, 15.5833)
          ..lineTo(7.33301, 15.5833)
          ..moveTo(9.16634, 8.25)
          ..lineTo(7.33301, 8.25),
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _FileLeftGrayPainter oldDelegate) =>
      oldDelegate.color != color;
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
