import 'package:flutter/material.dart';

class MotodigoNotifShieldWhiteIcon extends StatelessWidget {
  final double size;
  final Color color;
  final Color checkColor;

  const MotodigoNotifShieldWhiteIcon({
    super.key,
    this.size = 22,
    this.color = Colors.white,
    this.checkColor = const Color(0xFF16A34A),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _ShieldCheckPainter(color, checkColor),
    );
  }
}

class MotodigoNotifWarningTriangleIcon extends StatelessWidget {
  final double size;
  final Color color;
  final Color markColor;

  const MotodigoNotifWarningTriangleIcon({
    super.key,
    this.size = 22,
    this.color = const Color(0xFF3C4741),
    this.markColor = const Color(0xFFF5C518),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _WarningTrianglePainter(color, markColor),
    );
  }
}

class MotodigoNotifDocumentIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoNotifDocumentIcon({
    super.key,
    this.size = 22,
    this.color = const Color(0xFF3C4741),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _DocumentPainter(color));
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
  canvas
    ..save()
    ..translate((size.width - vb * scale) / 2, (size.height - vb * scale) / 2)
    ..scale(scale);
  draw(canvas);
  canvas.restore();
}

class _ShieldCheckPainter extends CustomPainter {
  final Color color;
  final Color checkColor;
  _ShieldCheckPainter(this.color, this.checkColor);

  @override
  void paint(Canvas canvas, Size size) {
    _scaled(canvas, size, 24, (canvas) {
      canvas.drawPath(
        Path()
          ..moveTo(12, 3)
          ..lineTo(20, 6.5)
          ..lineTo(20, 12.5)
          ..cubicTo(20, 16.8, 16.8, 20.5, 12, 21.5)
          ..cubicTo(7.2, 20.5, 4, 16.8, 4, 12.5)
          ..lineTo(4, 6.5)
          ..close(),
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        Path()
          ..moveTo(8.8, 12.2)
          ..lineTo(11.1, 14.4)
          ..lineTo(15.6, 9.6),
        _stroke(checkColor, 2.1),
      );
    });
  }

  @override
  bool shouldRepaint(covariant _ShieldCheckPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.checkColor != checkColor;
}

class _WarningTrianglePainter extends CustomPainter {
  final Color color;
  final Color markColor;
  _WarningTrianglePainter(this.color, this.markColor);

  @override
  void paint(Canvas canvas, Size size) {
    _scaled(canvas, size, 24, (canvas) {
      canvas.drawPath(
        Path()
          ..moveTo(12, 4)
          ..lineTo(21.2, 19.8)
          ..lineTo(2.8, 19.8)
          ..close(),
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
      canvas.drawLine(
        const Offset(12, 10),
        const Offset(12, 14.6),
        _stroke(markColor, 2.1),
      );
      canvas.drawCircle(const Offset(12, 17.3), 1.05, Paint()..color = markColor);
    });
  }

  @override
  bool shouldRepaint(covariant _WarningTrianglePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.markColor != markColor;
}

class _DocumentPainter extends CustomPainter {
  final Color color;
  _DocumentPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _scaled(canvas, size, 24, (canvas) {
      final p = _stroke(color, 1.8);
      canvas.drawPath(
        Path()
          ..moveTo(14, 3)
          ..lineTo(7, 3)
          ..cubicTo(6.45, 3, 5.92, 3.22, 5.54, 3.59)
          ..cubicTo(5.16, 3.97, 4.95, 4.47, 4.95, 5)
          ..lineTo(4.95, 19)
          ..cubicTo(4.95, 19.53, 5.16, 20.04, 5.54, 20.41)
          ..cubicTo(5.92, 20.79, 6.45, 21, 7, 21)
          ..lineTo(17, 21)
          ..cubicTo(17.55, 21, 18.08, 20.79, 18.46, 20.41)
          ..cubicTo(18.84, 20.04, 19.05, 19.53, 19.05, 19)
          ..lineTo(19.05, 8)
          ..lineTo(14, 3)
          ..close(),
        p,
      );
      canvas.drawPath(
        Path()
          ..moveTo(14, 3)
          ..lineTo(14, 8)
          ..lineTo(19.05, 8),
        p,
      );
      canvas.drawLine(const Offset(8.2, 12.5), const Offset(15.8, 12.5), p);
      canvas.drawLine(const Offset(8.2, 16), const Offset(15.8, 16), p);
    });
  }

  @override
  bool shouldRepaint(covariant _DocumentPainter oldDelegate) => oldDelegate.color != color;
}
