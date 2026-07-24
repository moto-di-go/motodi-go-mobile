import 'package:flutter/material.dart';

class MotodigoProfilePersonIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoProfilePersonIcon({
    super.key,
    this.size = 30,
    this.color = const Color(0xFF16A34A),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _PersonPainter(color));
  }
}

class MotodigoMototaxiIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoMototaxiIcon({
    super.key,
    this.size = 30,
    this.color = const Color(0xFF3C4741),
  });

  const MotodigoMototaxiIcon.green({super.key, this.size = 30})
    : color = const Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _MototaxiPainter(color),
    );
  }
}

class MotodigoTransporterIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoTransporterIcon({
    super.key,
    this.size = 30,
    this.color = const Color(0xFF3C4741),
  });

  const MotodigoTransporterIcon.green({super.key, this.size = 30})
    : color = const Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _TransporterPainter(color),
    );
  }
}

class MotodigoNetworkGrayIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoNetworkGrayIcon({
    super.key,
    this.size = 28,
    this.color = const Color(0xFF8A968C),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _NetworkPainter(color),
    );
  }
}

class _PersonPainter extends CustomPainter {
  final Color color;

  const _PersonPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 23, 23, (canvas) {
      final paint = _strokePaint(color, 1.91667);
      canvas.drawPath(
        Path()
          ..moveTo(18.2087, 20.125)
          ..lineTo(18.2087, 18.2083)
          ..cubicTo(18.2087, 17.1917, 17.8048, 16.2166, 17.0859, 15.4978)
          ..cubicTo(16.367, 14.7789, 15.392, 14.375, 14.3753, 14.375)
          ..lineTo(8.62533, 14.375)
          ..cubicTo(7.60866, 14.375, 6.63364, 14.7789, 5.91475, 15.4978)
          ..cubicTo(5.19586, 16.2166, 4.79199, 17.1917, 4.79199, 18.2083)
          ..lineTo(4.79199, 20.125),
        paint,
      );
      canvas.drawCircle(const Offset(11.5003, 6.70833), 3.83333, paint);
    });
  }

  @override
  bool shouldRepaint(covariant _PersonPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _MototaxiPainter extends CustomPainter {
  final Color color;

  const _MototaxiPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 23, 23, (canvas) {
      final paint = _strokePaint(color, 1.91667);
      canvas.drawCircle(const Offset(17.7292, 16.7709), 3.35417, paint);
      canvas.drawCircle(const Offset(5.27116, 16.7709), 3.35417, paint);
      canvas.drawCircle(const Offset(14.3753, 4.79159), 0.95833, paint);
      canvas.drawPath(
        Path()
          ..moveTo(11.5, 16.7709)
          ..lineTo(11.5, 13.4167)
          ..lineTo(8.625, 10.5417)
          ..lineTo(12.4583, 7.66675)
          ..lineTo(14.375, 10.5417)
          ..lineTo(16.2917, 10.5417),
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _MototaxiPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _TransporterPainter extends CustomPainter {
  final Color color;

  const _TransporterPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 23, 23, (canvas) {
      final paint = _strokePaint(color, 1.91667);
      canvas.drawPath(
        Path()
          ..moveTo(7.66699, 5.75)
          ..lineTo(7.66699, 11.5),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(14.375, 5.75)
          ..lineTo(14.375, 11.5),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(1.91699, 11.5)
          ..lineTo(20.7003, 11.5),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(17.2503, 17.25)
          ..lineTo(20.1253, 17.25)
          ..cubicTo(20.1253, 17.25, 20.6045, 15.6208, 20.892, 14.5667)
          ..cubicTo(20.9878, 14.1833, 21.0837, 13.8, 21.0837, 13.4167)
          ..cubicTo(21.0837, 13.0333, 20.9878, 12.65, 20.892, 12.2667)
          ..lineTo(19.5503, 7.475)
          ..cubicTo(19.2628, 6.51667, 18.3045, 5.75, 17.2503, 5.75)
          ..lineTo(3.83366, 5.75)
          ..cubicTo(3.32533, 5.75, 2.83782, 5.95193, 2.47837, 6.31138)
          ..cubicTo(2.11893, 6.67082, 1.91699, 7.15834, 1.91699, 7.66667)
          ..lineTo(1.91699, 17.25)
          ..lineTo(4.79199, 17.25),
        paint,
      );
      canvas.drawCircle(const Offset(6.70866, 17.2499), 1.91667, paint);
      canvas.drawPath(
        Path()
          ..moveTo(8.625, 17.25)
          ..lineTo(13.4167, 17.25),
        paint,
      );
      canvas.drawCircle(const Offset(15.3337, 17.2499), 1.91667, paint);
    });
  }

  @override
  bool shouldRepaint(covariant _TransporterPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _NetworkPainter extends CustomPainter {
  final Color color;

  const _NetworkPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 18, 18, (canvas) {
      final paint = _strokePaint(color, 1.5);
      canvas.drawCircle(const Offset(9, 9), 7.5, paint);
      canvas.drawPath(
        Path()
          ..moveTo(9.00049, 1.5)
          ..cubicTo(7.15566, 3.56258, 6.13574, 6.23275, 6.13574, 9)
          ..cubicTo(6.13574, 11.7672, 7.15566, 14.4374, 9.00049, 16.5),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(9, 1.5)
          ..cubicTo(10.8448, 3.56258, 11.8647, 6.23275, 11.8647, 9)
          ..cubicTo(11.8647, 11.7672, 10.8448, 14.4374, 9, 16.5),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(1.5, 9)
          ..lineTo(16.5, 9),
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _NetworkPainter oldDelegate) =>
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
