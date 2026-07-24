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

class MotodigoCniGreenIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoCniGreenIcon({
    super.key,
    this.size = 30,
    this.color = const Color(0xFF16A34A),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _CniGreenPainter(color),
    );
  }
}

class MotodigoPictureGreenIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoPictureGreenIcon({
    super.key,
    this.size = 30,
    this.color = const Color(0xFF16A34A),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _PictureGreenPainter(color),
    );
  }
}

class MotodigoAlertRedIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoAlertRedIcon({
    super.key,
    this.size = 30,
    this.color = const Color(0xFFB42318),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _AlertRedPainter(color),
    );
  }
}

class MotodigoUploadWhiteIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoUploadWhiteIcon({
    super.key,
    this.size = 24,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _UploadWhitePainter(color),
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

class _CniGreenPainter extends CustomPainter {
  final Color color;

  const _CniGreenPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 20, 20, (canvas) {
      final paint = _strokePaint(color, 1.66667);
      canvas.drawPath(
        Path()
          ..moveTo(16.667, 4.16675)
          ..lineTo(3.33366, 4.16675)
          ..cubicTo(2.41318, 4.16675, 1.66699, 4.91294, 1.66699, 5.83341)
          ..lineTo(1.66699, 14.1667)
          ..cubicTo(1.66699, 15.0872, 2.41318, 15.8334, 3.33366, 15.8334)
          ..lineTo(16.667, 15.8334)
          ..cubicTo(17.5875, 15.8334, 18.3337, 15.0872, 18.3337, 14.1667)
          ..lineTo(18.3337, 5.83341)
          ..cubicTo(18.3337, 4.91294, 17.5875, 4.16675, 16.667, 4.16675),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(5, 12.4999)
          ..lineTo(8.33333, 12.4999)
          ..moveTo(11.6667, 8.33325)
          ..lineTo(15, 8.33325)
          ..moveTo(11.6667, 11.6666)
          ..lineTo(15, 11.6666),
        paint,
      );
      canvas.drawCircle(const Offset(6.66667, 9.16667), 1.66667, paint);
    });
  }

  @override
  bool shouldRepaint(covariant _CniGreenPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _PictureGreenPainter extends CustomPainter {
  final Color color;

  const _PictureGreenPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 20, 20, (canvas) {
      final paint = _strokePaint(color, 1.66667);
      canvas.drawPath(
        Path()
          ..moveTo(15.8333, 2.5)
          ..lineTo(4.16667, 2.5)
          ..cubicTo(3.24619, 2.5, 2.5, 3.24619, 2.5, 4.16667)
          ..lineTo(2.5, 15.8333)
          ..cubicTo(2.5, 16.7538, 3.24619, 17.5, 4.16667, 17.5)
          ..lineTo(15.8333, 17.5)
          ..cubicTo(16.7538, 17.5, 17.5, 16.7538, 17.5, 15.8333)
          ..lineTo(17.5, 4.16667)
          ..cubicTo(17.5, 3.24619, 16.7538, 2.5, 15.8333, 2.5),
        paint,
      );
      canvas.drawCircle(const Offset(7.49967, 7.49992), 1.66667, paint);
      canvas.drawPath(
        Path()
          ..moveTo(17.5, 12.5001)
          ..lineTo(14.925, 9.92508)
          ..cubicTo(14.6127, 9.61467, 14.1903, 9.44043, 13.75, 9.44043)
          ..cubicTo(13.3097, 9.44043, 12.8873, 9.61467, 12.575, 9.92508)
          ..lineTo(5, 17.5001),
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _PictureGreenPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _AlertRedPainter extends CustomPainter {
  final Color color;

  const _AlertRedPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 20, 20, (canvas) {
      final paint = _strokePaint(color, 1.66667);
      canvas.drawPath(
        Path()
          ..moveTo(18.108, 15.0001)
          ..lineTo(11.4414, 3.33344)
          ..cubicTo(11.296, 3.07694, 11.0852, 2.8636, 10.8305, 2.71516)
          ..cubicTo(10.5757, 2.56673, 10.2862, 2.48853, 9.99136, 2.48853)
          ..cubicTo(9.69654, 2.48853, 9.40699, 2.56673, 9.15226, 2.71516)
          ..cubicTo(8.89753, 2.8636, 8.68673, 3.07694, 8.54136, 3.33344)
          ..lineTo(1.8747, 15.0001)
          ..cubicTo(1.72777, 15.2546, 1.65072, 15.5434, 1.65137, 15.8372)
          ..cubicTo(1.65202, 16.131, 1.73035, 16.4195, 1.8784, 16.6733)
          ..cubicTo(2.02646, 16.9271, 2.23899, 17.1373, 2.49444, 17.2825)
          ..cubicTo(2.7499, 17.4277, 3.0392, 17.5027, 3.33303, 17.5001)
          ..lineTo(16.6664, 17.5001)
          ..cubicTo(16.9588, 17.4998, 17.246, 17.4226, 17.4991, 17.2762)
          ..cubicTo(17.7522, 17.1298, 17.9624, 16.9193, 18.1085, 16.666)
          ..cubicTo(18.2545, 16.4127, 18.3314, 16.1254, 18.3313, 15.833)
          ..cubicTo(18.3312, 15.5406, 18.2542, 15.2533, 18.108, 15.0001),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(10, 7.5)
          ..lineTo(10, 10.8333),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(10, 14.1667)
          ..lineTo(10.0083, 14.1667),
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _AlertRedPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _UploadWhitePainter extends CustomPainter {
  final Color color;

  const _UploadWhitePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 18, 18, (canvas) {
      final paint = _strokePaint(color, 1.5);
      canvas.drawPath(
        Path()
          ..moveTo(15.75, 11.25)
          ..lineTo(15.75, 14.25)
          ..cubicTo(15.75, 14.6478, 15.592, 15.0294, 15.3107, 15.3107)
          ..cubicTo(15.0294, 15.592, 14.6478, 15.75, 14.25, 15.75)
          ..lineTo(3.75, 15.75)
          ..cubicTo(3.35218, 15.75, 2.97064, 15.592, 2.68934, 15.3107)
          ..cubicTo(2.40804, 15.0294, 2.25, 14.6478, 2.25, 14.25)
          ..lineTo(2.25, 11.25),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(12.75, 6)
          ..lineTo(9, 2.25)
          ..lineTo(5.25, 6),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(9, 2.25)
          ..lineTo(9, 11.25),
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _UploadWhitePainter oldDelegate) =>
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
