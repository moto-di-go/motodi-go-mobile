import 'package:flutter/material.dart';

/// Icônes Figma exactes de l'écran hub Profil (SVG → CustomPaint).

class MotodigoHubCheckedGreenIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoHubCheckedGreenIcon({
    super.key,
    this.size = 15,
    this.color = const Color(0xFF16A34A),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _CheckedGreenPainter(color));
  }
}

class MotodigoHubPeopleIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoHubPeopleIcon({super.key, this.size = 20, this.color = const Color(0xFF3C4741)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _PeoplePainter(color));
  }
}

class MotodigoHubSettingsIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoHubSettingsIcon({super.key, this.size = 20, this.color = const Color(0xFF3C4741)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _SettingsPainter(color));
  }
}

class MotodigoHubFolderGrayIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MotodigoHubFolderGrayIcon({
    super.key,
    this.size = 20,
    this.color = const Color(0xFF3C4741),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _FolderGrayPainter(color));
  }
}

class _CheckedGreenPainter extends CustomPainter {
  final Color color;
  const _CheckedGreenPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 15, 15, (canvas) {
      final paint = _strokePaint(color, 1.5);
      canvas.drawPath(
        Path()
          ..moveTo(13.75, 6.92467)
          ..lineTo(13.75, 7.49967)
          ..cubicTo(13.7492, 8.84744, 13.3128, 10.1588, 12.5058, 11.2383)
          ..cubicTo(11.6989, 12.3178, 10.5646, 13.1075, 9.2721, 13.4896)
          ..cubicTo(7.97964, 13.8717, 6.59829, 13.8259, 5.33404, 13.3588)
          ..cubicTo(4.0698, 12.8917, 2.99041, 12.0285, 2.25685, 10.8978)
          ..cubicTo(1.52329, 9.76719, 1.17487, 8.42971, 1.26355, 7.08487)
          ..cubicTo(1.35223, 5.74002, 1.87325, 4.45988, 2.74892, 3.43534)
          ..cubicTo(3.6246, 2.41081, 4.80799, 1.69679, 6.12262, 1.39976)
          ..cubicTo(7.43725, 1.10274, 8.81267, 1.23863, 10.0438, 1.78717),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(5.625, 6.875)
          ..lineTo(7.5, 8.75)
          ..lineTo(13.75, 2.5),
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _CheckedGreenPainter oldDelegate) => oldDelegate.color != color;
}

class _PeoplePainter extends CustomPainter {
  final Color color;
  const _PeoplePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 20, 20, (canvas) {
      final paint = _strokePaint(color, 1.66667);
      canvas.drawPath(
        Path()
          ..moveTo(13.3337, 17.5)
          ..lineTo(13.3337, 15.8333)
          ..cubicTo(13.3337, 14.9493, 12.9825, 14.1014, 12.3573, 13.4763)
          ..cubicTo(11.7322, 12.8512, 10.8844, 12.5, 10.0003, 12.5)
          ..lineTo(5.00033, 12.5)
          ..cubicTo(4.11627, 12.5, 3.26842, 12.8512, 2.6433, 13.4763)
          ..cubicTo(2.01818, 14.1014, 1.66699, 14.9493, 1.66699, 15.8333)
          ..lineTo(1.66699, 17.5),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(7.50033, 9.16667)
          ..cubicTo(9.34127, 9.16667, 10.8337, 7.67428, 10.8337, 5.83333)
          ..cubicTo(10.8337, 3.99238, 9.34127, 2.5, 7.50033, 2.5)
          ..cubicTo(5.65938, 2.5, 4.16699, 3.99238, 4.16699, 5.83333)
          ..cubicTo(4.16699, 7.67428, 5.65938, 9.16667, 7.50033, 9.16667)
          ..close(),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(18.333, 17.5001)
          ..lineTo(18.333, 15.8334)
          ..cubicTo(18.3325, 15.0948, 18.0866, 14.3774, 17.6341, 13.7937)
          ..cubicTo(17.1817, 13.2099, 16.5481, 12.793, 15.833, 12.6084),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(13.333, 2.6084)
          ..cubicTo(14.05, 2.79198, 14.6855, 3.20898, 15.1394, 3.79366)
          ..cubicTo(15.5932, 4.37833, 15.8395, 5.09742, 15.8395, 5.83757)
          ..cubicTo(15.8395, 6.57771, 15.5932, 7.2968, 15.1394, 7.88147)
          ..cubicTo(14.6855, 8.46615, 14.05, 8.88315, 13.333, 9.06673),
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _PeoplePainter oldDelegate) => oldDelegate.color != color;
}

class _SettingsPainter extends CustomPainter {
  final Color color;
  const _SettingsPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 20, 20, (canvas) {
      final paint = _strokePaint(color, 1.66667);
      canvas.drawPath(
        Path()
          ..moveTo(10.1833, 1.66699)
          ..lineTo(9.81667, 1.66699)
          ..cubicTo(9.37464, 1.66699, 8.95072, 1.84259, 8.63816, 2.15515)
          ..cubicTo(8.3256, 2.46771, 8.15, 2.89163, 8.15, 3.33366)
          ..lineTo(8.15, 3.48366)
          ..cubicTo(8.1497, 3.77593, 8.07255, 4.06298, 7.92628, 4.31602)
          ..cubicTo(7.78002, 4.56906, 7.56978, 4.77919, 7.31667, 4.92533)
          ..lineTo(6.95834, 5.13366)
          ..cubicTo(6.70497, 5.27994, 6.41756, 5.35695, 6.125, 5.35695)
          ..cubicTo(5.83244, 5.35695, 5.54503, 5.27994, 5.29167, 5.13366)
          ..lineTo(5.16667, 5.06699)
          ..cubicTo(4.78422, 4.84638, 4.32987, 4.78653, 3.90334, 4.90058)
          ..cubicTo(3.47681, 5.01464, 3.11296, 5.29327, 2.89167, 5.67533)
          ..lineTo(2.70833, 5.99199)
          ..cubicTo(2.48772, 6.37444, 2.42787, 6.82879, 2.54192, 7.25532)
          ..cubicTo(2.65598, 7.68185, 2.93461, 8.0457, 3.31667, 8.26699)
          ..lineTo(3.44167, 8.35033)
          ..cubicTo(3.69356, 8.49575, 3.90302, 8.70457, 4.04921, 8.95602)
          ..cubicTo(4.1954, 9.20747, 4.27325, 9.4928, 4.275, 9.78366)
          ..lineTo(4.275, 10.2087)
          ..cubicTo(4.27617, 10.5023, 4.19971, 10.7911, 4.05337, 11.0457)
          ..cubicTo(3.90703, 11.3004, 3.69601, 11.5118, 3.44167, 11.6587)
          ..lineTo(3.31667, 11.7337)
          ..cubicTo(2.93461, 11.955, 2.65598, 12.3188, 2.54192, 12.7453)
          ..cubicTo(2.42787, 13.1719, 2.48772, 13.6262, 2.70833, 14.0087)
          ..lineTo(2.89167, 14.3253)
          ..cubicTo(3.11296, 14.7074, 3.47681, 14.986, 3.90334, 15.1001)
          ..cubicTo(4.32987, 15.2141, 4.78422, 15.1543, 5.16667, 14.9337)
          ..lineTo(5.29167, 14.867)
          ..cubicTo(5.54503, 14.7207, 5.83244, 14.6437, 6.125, 14.6437)
          ..cubicTo(6.41756, 14.6437, 6.70497, 14.7207, 6.95834, 14.867)
          ..lineTo(7.31667, 15.0753)
          ..cubicTo(7.56978, 15.2215, 7.78002, 15.4316, 7.92628, 15.6846)
          ..cubicTo(8.07255, 15.9377, 8.1497, 16.2247, 8.15, 16.517)
          ..lineTo(8.15, 16.667)
          ..cubicTo(8.15, 17.109, 8.3256, 17.5329, 8.63816, 17.8455)
          ..cubicTo(8.95072, 18.1581, 9.37464, 18.3337, 9.81667, 18.3337)
          ..lineTo(10.1833, 18.3337)
          ..cubicTo(10.6254, 18.3337, 11.0493, 18.1581, 11.3618, 17.8455)
          ..cubicTo(11.6744, 17.5329, 11.85, 17.109, 11.85, 16.667)
          ..lineTo(11.85, 16.517)
          ..cubicTo(11.8503, 16.2247, 11.9275, 15.9377, 12.0737, 15.6846)
          ..cubicTo(12.22, 15.4316, 12.4302, 15.2215, 12.6833, 15.0753)
          ..lineTo(13.0417, 14.867)
          ..cubicTo(13.295, 14.7207, 13.5824, 14.6437, 13.875, 14.6437)
          ..cubicTo(14.1676, 14.6437, 14.455, 14.7207, 14.7083, 14.867)
          ..lineTo(14.8333, 14.9337)
          ..cubicTo(15.2158, 15.1543, 15.6701, 15.2141, 16.0967, 15.1001)
          ..cubicTo(16.5232, 14.986, 16.887, 14.7074, 17.1083, 14.3253)
          ..lineTo(17.2917, 14.0003)
          ..cubicTo(17.5123, 13.6179, 17.5721, 13.1635, 17.4581, 12.737)
          ..cubicTo(17.344, 12.3105, 17.0654, 11.9466, 16.6833, 11.7253)
          ..lineTo(16.5583, 11.6587)
          ..cubicTo(16.304, 11.5118, 16.093, 11.3004, 15.9466, 11.0457)
          ..cubicTo(15.8003, 10.7911, 15.7238, 10.5023, 15.725, 10.2087)
          ..lineTo(15.725, 9.79199)
          ..cubicTo(15.7238, 9.49831, 15.8003, 9.20953, 15.9466, 8.9549)
          ..cubicTo(16.093, 8.70027, 16.304, 8.48883, 16.5583, 8.34199)
          ..lineTo(16.6833, 8.26699)
          ..cubicTo(17.0654, 8.0457, 17.344, 7.68185, 17.4581, 7.25532)
          ..cubicTo(17.5721, 6.82879, 17.5123, 6.37444, 17.2917, 5.99199)
          ..lineTo(17.1083, 5.67533)
          ..cubicTo(16.887, 5.29327, 16.5232, 5.01464, 16.0967, 4.90058)
          ..cubicTo(15.6701, 4.78653, 15.2158, 4.84638, 14.8333, 5.06699)
          ..lineTo(14.7083, 5.13366)
          ..cubicTo(14.455, 5.27994, 14.1676, 5.35695, 13.875, 5.35695)
          ..cubicTo(13.5824, 5.35695, 13.295, 5.27994, 13.0417, 5.13366)
          ..lineTo(12.6833, 4.92533)
          ..cubicTo(12.4302, 4.77919, 12.22, 4.56906, 12.0737, 4.31602)
          ..cubicTo(11.9275, 4.06298, 11.8503, 3.77593, 11.85, 3.48366)
          ..lineTo(11.85, 3.33366)
          ..cubicTo(11.85, 2.89163, 11.6744, 2.46771, 11.3618, 2.15515)
          ..cubicTo(11.0493, 1.84259, 10.6254, 1.66699, 10.1833, 1.66699)
          ..close(),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(10, 12.5)
          ..cubicTo(11.3807, 12.5, 12.5, 11.3807, 12.5, 10)
          ..cubicTo(12.5, 8.61929, 11.3807, 7.5, 10, 7.5)
          ..cubicTo(8.61929, 7.5, 7.5, 8.61929, 7.5, 10)
          ..cubicTo(7.5, 11.3807, 8.61929, 12.5, 10, 12.5)
          ..close(),
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _SettingsPainter oldDelegate) => oldDelegate.color != color;
}

class _FolderGrayPainter extends CustomPainter {
  final Color color;
  const _FolderGrayPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 20, 20, (canvas) {
      final paint = _strokePaint(color, 1.66667);
      canvas.drawPath(
        Path()
          ..moveTo(12.4997, 1.66699)
          ..lineTo(4.99967, 1.66699)
          ..cubicTo(4.55765, 1.66699, 4.13372, 1.84259, 3.82116, 2.15515)
          ..cubicTo(3.5086, 2.46771, 3.33301, 2.89163, 3.33301, 3.33366)
          ..lineTo(3.33301, 16.667)
          ..cubicTo(3.33301, 17.109, 3.5086, 17.5329, 3.82116, 17.8455)
          ..cubicTo(4.13372, 18.1581, 4.55765, 18.3337, 4.99967, 18.3337)
          ..lineTo(14.9997, 18.3337)
          ..cubicTo(15.4417, 18.3337, 15.8656, 18.1581, 16.1782, 17.8455)
          ..cubicTo(16.4907, 17.5329, 16.6663, 17.109, 16.6663, 16.667)
          ..lineTo(16.6663, 5.83366)
          ..lineTo(12.4997, 1.66699)
          ..close(),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(11.667, 1.66699)
          ..lineTo(11.667, 5.83366)
          ..lineTo(15.8337, 5.83366),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(13.3337, 10.8333)
          ..lineTo(6.66699, 10.8333)
          ..moveTo(13.3337, 14.1667)
          ..lineTo(6.66699, 14.1667)
          ..moveTo(8.33366, 7.5)
          ..lineTo(6.66699, 7.5),
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _FolderGrayPainter oldDelegate) => oldDelegate.color != color;
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
  canvas.save();
  canvas.scale(size.width / viewBoxWidth, size.height / viewBoxHeight);
  draw(canvas);
  canvas.restore();
}
