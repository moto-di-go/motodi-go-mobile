import 'package:flutter/material.dart';

class MotodigoHomeGreenIcon extends StatelessWidget {
  final double size;

  const MotodigoHomeGreenIcon({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _HomePainter(Color(0xFF16A34A)),
    );
  }
}

class MotodigoHomeGrayIcon extends StatelessWidget {
  final double size;

  const MotodigoHomeGrayIcon({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _HomePainter(Color(0xFF98A29A)),
    );
  }
}

class MotodigoTrajetGrayIcon extends StatelessWidget {
  final double size;

  const MotodigoTrajetGrayIcon({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _TrajetPainter(Color(0xFF9AA49B)),
    );
  }
}

class MotodigoTrajetGreenIcon extends StatelessWidget {
  final double size;

  const MotodigoTrajetGreenIcon({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _TrajetPainter(Color(0xFF16A34A)),
    );
  }
}

class MotodigoWalletGrayIcon extends StatelessWidget {
  final double size;

  const MotodigoWalletGrayIcon({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _WalletPainter(Color(0xFF9AA49B)),
    );
  }
}

class MotodigoWalletGreenIcon extends StatelessWidget {
  final double size;

  const MotodigoWalletGreenIcon({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _WalletPainter(Color(0xFF16A34A)),
    );
  }
}

class MotodigoNotifGrayIcon extends StatelessWidget {
  final double size;

  const MotodigoNotifGrayIcon({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _NotifPainter(Color(0xFF9AA49B)),
    );
  }
}

class MotodigoNotifGreenIcon extends StatelessWidget {
  final double size;

  const MotodigoNotifGreenIcon({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _NotifPainter(Color(0xFF16A34A)),
    );
  }
}

class MotodigoProfileGrayIcon extends StatelessWidget {
  final double size;

  const MotodigoProfileGrayIcon({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _ProfilePainter(Color(0xFF9AA49B)),
    );
  }
}

class MotodigoProfileGreenIcon extends StatelessWidget {
  final double size;

  const MotodigoProfileGreenIcon({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _ProfilePainter(Color(0xFF16A34A)),
    );
  }
}

class _HomePainter extends CustomPainter {
  final Color color;

  const _HomePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 22, 22, (canvas) {
      final paint = _strokePaint(color, 1.83333);
      canvas.drawPath(
        Path()
          ..moveTo(2.75, 8.24992)
          ..lineTo(11, 1.83325)
          ..lineTo(19.25, 8.24992)
          ..lineTo(19.25, 18.3333)
          ..cubicTo(19.25, 18.8195, 19.0568, 19.2858, 18.713, 19.6296)
          ..cubicTo(18.3692, 19.9734, 17.9029, 20.1666, 17.4167, 20.1666)
          ..lineTo(4.58333, 20.1666)
          ..cubicTo(4.0971, 20.1666, 3.63079, 19.9734, 3.28697, 19.6296)
          ..cubicTo(2.94315, 19.2858, 2.75, 18.8195, 2.75, 18.3333)
          ..lineTo(2.75, 8.24992),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(8.25, 20.1667)
          ..lineTo(8.25, 11)
          ..lineTo(13.75, 11)
          ..lineTo(13.75, 20.1667),
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _HomePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _TrajetPainter extends CustomPainter {
  final Color color;

  const _TrajetPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 22, 22, (canvas) {
      final paint = _strokePaint(color, 1.83333);
      canvas.drawCircle(const Offset(5.5, 17.4167), 2.75, paint);
      canvas.drawPath(
        Path()
          ..moveTo(8.25, 17.4166)
          ..lineTo(16.0417, 17.4166)
          ..cubicTo(16.8926, 17.4166, 17.7086, 17.0786, 18.3103, 16.4769)
          ..cubicTo(18.912, 15.8752, 19.25, 15.0592, 19.25, 14.2083)
          ..cubicTo(19.25, 13.3573, 18.912, 12.5413, 18.3103, 11.9396)
          ..cubicTo(17.7086, 11.3379, 16.8926, 10.9999, 16.0417, 10.9999)
          ..lineTo(5.95833, 10.9999)
          ..cubicTo(5.10743, 10.9999, 4.29138, 10.6619, 3.6897, 10.0602)
          ..cubicTo(3.08802, 9.45854, 2.75, 8.64249, 2.75, 7.79159)
          ..cubicTo(2.75, 6.94068, 3.08802, 6.12463, 3.6897, 5.52295)
          ..cubicTo(4.29138, 4.92127, 5.10743, 4.58325, 5.95833, 4.58325)
          ..lineTo(13.75, 4.58325),
        paint,
      );
      canvas.drawCircle(const Offset(16.5, 4.58325), 2.75, paint);
    });
  }

  @override
  bool shouldRepaint(covariant _TrajetPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _WalletPainter extends CustomPainter {
  final Color color;

  const _WalletPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 22, 22, (canvas) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawPath(
        Path()
          ..moveTo(18.7091, 9.03835)
          ..cubicTo(18.6557, 9.03587, 18.6022, 9.03496, 18.5487, 9.0356)
          ..lineTo(16.3166, 9.0356)
          ..cubicTo(14.4906, 9.0356, 12.9268, 10.4848, 12.9268, 12.375)
          ..cubicTo(12.9268, 14.2652, 14.4906, 15.7144, 16.3175, 15.7144)
          ..lineTo(18.5478, 15.7144)
          ..cubicTo(18.604, 15.715, 18.6575, 15.7138, 18.7082, 15.7108)
          ..cubicTo(19.085, 15.6863, 19.44, 15.5259, 19.7074, 15.2593)
          ..cubicTo(19.9748, 14.9928, 20.1364, 14.6382, 20.162, 14.2615)
          ..cubicTo(20.1657, 14.2074, 20.1657, 14.1497, 20.1657, 14.0965)
          ..lineTo(20.1657, 10.6535)
          ..cubicTo(20.1657, 10.6003, 20.1657, 10.5426, 20.162, 10.4885)
          ..cubicTo(20.1364, 10.112, 19.975, 9.75751, 19.7078, 9.49097)
          ..cubicTo(19.4406, 9.22443, 19.0857, 9.06393, 18.7091, 9.03927)
          ..moveTo(16.1213, 13.266)
          ..cubicTo(16.5916, 13.266, 16.9738, 12.8682, 16.9738, 12.3759)
          ..cubicTo(16.9738, 11.8837, 16.5916, 11.4858, 16.1213, 11.4858)
          ..cubicTo(15.6511, 11.4858, 15.2698, 11.8837, 15.2698, 12.3759)
          ..cubicTo(15.2698, 12.8682, 15.6502, 13.266, 16.1213, 13.266),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(18.5475, 17.0499)
          ..cubicTo(18.5782, 17.0488, 18.6088, 17.055, 18.6366, 17.0679)
          ..cubicTo(18.6645, 17.0808, 18.689, 17.1, 18.7081, 17.1241)
          ..cubicTo(18.7272, 17.1482, 18.7404, 17.1764, 18.7465, 17.2065)
          ..cubicTo(18.7527, 17.2366, 18.7517, 17.2678, 18.7437, 17.2974)
          ..cubicTo(18.5658, 17.9318, 18.2844, 18.4726, 17.8325, 18.9273)
          ..cubicTo(17.1716, 19.5937, 16.3328, 19.8898, 15.297, 20.03)
          ..cubicTo(14.2905, 20.1666, 13.0053, 20.1666, 11.381, 20.1666)
          ..lineTo(9.51376, 20.1666)
          ..cubicTo(7.89034, 20.1666, 6.60426, 20.1666, 5.59776, 20.03)
          ..cubicTo(4.56192, 19.8898, 3.72317, 19.5937, 3.06226, 18.9273)
          ..cubicTo(2.40134, 18.2627, 2.10801, 17.4166, 1.96867, 16.3734)
          ..cubicTo(1.83301, 15.3578, 1.83301, 14.0616, 1.83301, 12.4253)
          ..lineTo(1.83301, 12.3245)
          ..cubicTo(1.83301, 10.6883, 1.83301, 9.39117, 1.96867, 8.37734)
          ..cubicTo(2.10801, 7.33325, 2.40134, 6.48992, 3.06134, 5.82167)
          ..cubicTo(3.72226, 5.15617, 4.56101, 4.85917, 5.59684, 4.71984)
          ..cubicTo(6.60426, 4.58325, 7.89034, 4.58325, 9.51376, 4.58325)
          ..lineTo(11.381, 4.58325)
          ..cubicTo(13.0044, 4.58325, 14.2905, 4.58325, 15.297, 4.71984)
          ..cubicTo(16.3328, 4.86009, 17.1716, 5.15617, 17.8325, 5.82167)
          ..cubicTo(18.2844, 6.27725, 18.5658, 6.81808, 18.7437, 7.45333)
          ..cubicTo(18.7516, 7.48293, 18.7524, 7.51396, 18.7462, 7.54394)
          ..cubicTo(18.7399, 7.57392, 18.7267, 7.60202, 18.7076, 7.62599)
          ..cubicTo(18.6886, 7.64996, 18.6642, 7.66913, 18.6364, 7.68197)
          ..cubicTo(18.6085, 7.6948, 18.5781, 7.70095, 18.5475, 7.69992)
          ..lineTo(16.3173, 7.69992)
          ..cubicTo(13.8111, 7.69992, 11.6028, 9.6955, 11.6028, 12.3749)
          ..cubicTo(11.6028, 15.0543, 13.812, 17.0499, 16.3182, 17.0499)
          ..lineTo(18.5475, 17.0499)
          ..moveTo(5.14584, 8.14542)
          ..cubicTo(5.05857, 8.14578, 4.97222, 8.16333, 4.89172, 8.19706)
          ..cubicTo(4.81123, 8.23079, 4.73817, 8.28005, 4.67671, 8.34201)
          ..cubicTo(4.61526, 8.40398, 4.56661, 8.47745, 4.53354, 8.55822)
          ..cubicTo(4.50048, 8.63899, 4.48365, 8.72548, 4.48401, 8.81275)
          ..cubicTo(4.48401, 9.18217, 4.78009, 9.481, 5.14584, 9.481)
          ..lineTo(8.68051, 9.481)
          ..cubicTo(9.04718, 9.481, 9.34326, 9.18217, 9.34326, 8.81275)
          ..cubicTo(9.34375, 8.63641, 9.27422, 8.46708, 9.14996, 8.34196)
          ..cubicTo(9.0257, 8.21683, 8.85685, 8.14615, 8.68051, 8.14542)
          ..lineTo(5.14584, 8.14542),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(7.12891, 3.68866)
          ..lineTo(8.92374, 2.36591)
          ..cubicTo(9.39216, 2.01979, 9.95923, 1.83301, 10.5417, 1.83301)
          ..cubicTo(11.1241, 1.83301, 11.6912, 2.01979, 12.1596, 2.36591)
          ..lineTo(13.9645, 3.69599)
          ..cubicTo(13.2092, 3.66666, 12.3658, 3.66666, 11.4427, 3.66666)
          ..lineTo(9.45357, 3.66666)
          ..cubicTo(8.60841, 3.66666, 7.83199, 3.66666, 7.12891, 3.68866),
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _WalletPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _NotifPainter extends CustomPainter {
  final Color color;

  const _NotifPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 22, 22, (canvas) {
      final paint = _strokePaint(color, 1.83333);
      canvas.drawPath(
        Path()
          ..moveTo(5.5, 7.33325)
          ..cubicTo(5.5, 5.87456, 6.07946, 4.47561, 7.11091, 3.44416)
          ..cubicTo(8.14236, 2.41271, 9.54131, 1.83325, 11, 1.83325)
          ..cubicTo(12.4587, 1.83325, 13.8576, 2.41271, 14.8891, 3.44416)
          ..cubicTo(15.9205, 4.47561, 16.5, 5.87456, 16.5, 7.33325)
          ..cubicTo(16.5, 13.7499, 19.25, 15.5833, 19.25, 15.5833)
          ..lineTo(2.75, 15.5833)
          ..cubicTo(2.75, 15.5833, 5.5, 13.7499, 5.5, 7.33325),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(9.44141, 19.25)
          ..cubicTo(9.59484, 19.5291, 9.8204, 19.7618, 10.0945, 19.9239)
          ..cubicTo(10.3686, 20.086, 10.6813, 20.1716, 10.9997, 20.1716)
          ..cubicTo(11.3182, 20.1716, 11.6308, 20.086, 11.905, 19.9239)
          ..cubicTo(12.1791, 19.7618, 12.4046, 19.5291, 12.5581, 19.25),
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _NotifPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _ProfilePainter extends CustomPainter {
  final Color color;

  const _ProfilePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 22, 22, (canvas) {
      final paint = _strokePaint(color, 1.83333);
      canvas.drawPath(
        Path()
          ..moveTo(17.4163, 19.25)
          ..lineTo(17.4163, 17.4167)
          ..cubicTo(17.4163, 16.4442, 17.03, 15.5116, 16.3424, 14.8239)
          ..cubicTo(15.6548, 14.1363, 14.7221, 13.75, 13.7497, 13.75)
          ..lineTo(8.24967, 13.75)
          ..cubicTo(7.27721, 13.75, 6.34458, 14.1363, 5.65695, 14.8239)
          ..cubicTo(4.96932, 15.5116, 4.58301, 16.4442, 4.58301, 17.4167)
          ..lineTo(4.58301, 19.25),
        paint,
      );
      canvas.drawCircle(const Offset(10.9997, 6.41667), 3.66667, paint);
    });
  }

  @override
  bool shouldRepaint(covariant _ProfilePainter oldDelegate) =>
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
