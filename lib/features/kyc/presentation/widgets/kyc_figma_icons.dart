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
    return CustomPaint(size: Size.square(size), painter: _PendingYellowPainter(color));
  }
}

class MotodigoFileLeftGrayIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoFileLeftGrayIcon({super.key, this.size = 30, this.color = const Color(0xFFB6BEB6)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _FileLeftGrayPainter(color));
  }
}

class MotodigoCniGreenIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoCniGreenIcon({super.key, this.size = 30, this.color = const Color(0xFF16A34A)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _CniGreenPainter(color));
  }
}

class MotodigoPictureGreenIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoPictureGreenIcon({super.key, this.size = 30, this.color = const Color(0xFF16A34A)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _PicturePainter(color));
  }
}

class MotodigoPictureGrayIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoPictureGrayIcon({super.key, this.size = 30, this.color = const Color(0xFFB6BEB6)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _PicturePainter(color));
  }
}

class MotodigoAlertRedIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoAlertRedIcon({super.key, this.size = 30, this.color = const Color(0xFFB42318)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _AlertRedPainter(color));
  }
}

class MotodigoUploadWhiteIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoUploadWhiteIcon({super.key, this.size = 24, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _UploadWhitePainter(color));
  }
}

class MotodigoUploadGreenIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoUploadGreenIcon({super.key, this.size = 46, this.color = const Color(0xFF16A34A)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _UploadGreenPainter(color));
  }
}

class MotodigoCameraGreenIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoCameraGreenIcon({super.key, this.size = 30, this.color = const Color(0xFF16A34A)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _CameraGreenPainter(color));
  }
}

class MotodigoFolderVerificationIcon extends StatelessWidget {
  final double size;

  const MotodigoFolderVerificationIcon({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: const _FolderVerificationPainter());
  }
}

class MotodigoFolderCheckedWhiteIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoFolderCheckedWhiteIcon({super.key, this.size = 22, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _FolderCheckedWhitePainter(color));
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
  bool shouldRepaint(covariant _PendingYellowPainter oldDelegate) => oldDelegate.color != color;
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
  bool shouldRepaint(covariant _FileLeftGrayPainter oldDelegate) => oldDelegate.color != color;
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
  bool shouldRepaint(covariant _CniGreenPainter oldDelegate) => oldDelegate.color != color;
}

class _PicturePainter extends CustomPainter {
  final Color color;

  const _PicturePainter(this.color);

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
  bool shouldRepaint(covariant _PicturePainter oldDelegate) => oldDelegate.color != color;
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
  bool shouldRepaint(covariant _AlertRedPainter oldDelegate) => oldDelegate.color != color;
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
  bool shouldRepaint(covariant _UploadWhitePainter oldDelegate) => oldDelegate.color != color;
}

class _UploadGreenPainter extends CustomPainter {
  final Color color;

  const _UploadGreenPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 46, 46, (canvas) {
      final paint = _strokePaint(color, 3.83333);
      canvas.drawPath(
        Path()
          ..moveTo(40.25, 28.75)
          ..lineTo(40.25, 36.4167)
          ..cubicTo(40.25, 37.4333, 39.8461, 38.4084, 39.1272, 39.1272)
          ..cubicTo(38.4084, 39.8461, 37.4333, 40.25, 36.4167, 40.25)
          ..lineTo(9.58333, 40.25)
          ..cubicTo(8.56667, 40.25, 7.59165, 39.8461, 6.87276, 39.1272)
          ..cubicTo(6.15387, 38.4084, 5.75, 37.4333, 5.75, 36.4167)
          ..lineTo(5.75, 28.75),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(32.5837, 15.3333)
          ..lineTo(23.0003, 5.75)
          ..lineTo(13.417, 15.3333),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(23, 5.75)
          ..lineTo(23, 28.75),
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _UploadGreenPainter oldDelegate) => oldDelegate.color != color;
}

class _CameraGreenPainter extends CustomPainter {
  final Color color;

  const _CameraGreenPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 22, 22, (canvas) {
      final paint = _strokePaint(color, 1.83333);
      canvas.drawPath(
        Path()
          ..moveTo(13.2913, 3.66675)
          ..lineTo(8.70801, 3.66675)
          ..lineTo(6.41634, 6.41675)
          ..lineTo(3.66634, 6.41675)
          ..cubicTo(3.18011, 6.41675, 2.7138, 6.6099, 2.36998, 6.95372)
          ..cubicTo(2.02616, 7.29754, 1.83301, 7.76385, 1.83301, 8.25008)
          ..lineTo(1.83301, 16.5001)
          ..cubicTo(1.83301, 16.9863, 2.02616, 17.4526, 2.36998, 17.7964)
          ..cubicTo(2.7138, 18.1403, 3.18011, 18.3334, 3.66634, 18.3334)
          ..lineTo(18.333, 18.3334)
          ..cubicTo(18.8192, 18.3334, 19.2856, 18.1403, 19.6294, 17.7964)
          ..cubicTo(19.9732, 17.4526, 20.1663, 16.9863, 20.1663, 16.5001)
          ..lineTo(20.1663, 8.25008)
          ..cubicTo(20.1663, 7.76385, 19.9732, 7.29754, 19.6294, 6.95372)
          ..cubicTo(19.2856, 6.6099, 18.8192, 6.41675, 18.333, 6.41675)
          ..lineTo(15.583, 6.41675)
          ..lineTo(13.2913, 3.66675),
        paint,
      );
      canvas.drawCircle(const Offset(11, 11.9167), 2.75, paint);
    });
  }

  @override
  bool shouldRepaint(covariant _CameraGreenPainter oldDelegate) => oldDelegate.color != color;
}

class _FolderVerificationPainter extends CustomPainter {
  const _FolderVerificationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 28, 28, (canvas) {
      canvas.drawCircle(
        const Offset(14, 14),
        14,
        Paint()
          ..color = const Color(0xFFFDF2CD)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        const Offset(14, 14),
        12,
        Paint()
          ..color = const Color(0xFFF5C518)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
      final center = Paint()
        ..color = const Color(0xFFF5C518)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(9.5, 9.5, 9, 9), const Radius.circular(4.5)),
        center,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _FolderVerificationPainter oldDelegate) => false;
}

class _FolderCheckedWhitePainter extends CustomPainter {
  final Color color;

  const _FolderCheckedWhitePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 22, 22, (canvas) {
      final paint = _strokePaint(color, 1.83333);
      canvas.drawPath(
        Path()
          ..moveTo(18.3337, 11.9168)
          ..cubicTo(18.3337, 16.5001, 15.1253, 18.7918, 11.312, 20.1209)
          ..cubicTo(11.1123, 20.1886, 10.8954, 20.1853, 10.6978, 20.1118)
          ..cubicTo(6.87533, 18.7918, 3.66699, 16.5001, 3.66699, 11.9168)
          ..lineTo(3.66699, 5.50009)
          ..cubicTo(3.66699, 5.25697, 3.76357, 5.02381, 3.93548, 4.85191)
          ..cubicTo(4.10739, 4.68, 4.34054, 4.58342, 4.58366, 4.58342)
          ..cubicTo(6.41699, 4.58342, 8.70866, 3.48342, 10.3037, 2.09009)
          ..cubicTo(10.4979, 1.92417, 10.7449, 1.83301, 11.0003, 1.83301)
          ..cubicTo(11.2558, 1.83301, 11.5028, 1.92417, 11.697, 2.09009)
          ..cubicTo(13.3012, 3.49259, 15.5837, 4.58342, 17.417, 4.58342)
          ..cubicTo(17.6601, 4.58342, 17.8933, 4.68, 18.0652, 4.85191)
          ..cubicTo(18.2371, 5.02381, 18.3337, 5.25697, 18.3337, 5.50009)
          ..lineTo(18.3337, 11.9168),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(8.25, 11.0001)
          ..lineTo(10.0833, 12.8334)
          ..lineTo(13.75, 9.16675),
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _FolderCheckedWhitePainter oldDelegate) =>
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
