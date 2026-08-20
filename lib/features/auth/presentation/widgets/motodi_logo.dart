import 'package:flutter/material.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';

class MotodiLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const MotodiLogo({super.key, this.size = 96, this.showText = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: size, height: size, child: const MotodiSplashIcon()),
        if (showText) ...[
          const SizedBox(height: 28),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
              children: const [
                TextSpan(text: "Moto'di Go"),
                TextSpan(
                  text: '.',
                  style: TextStyle(color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class MotodiSplashIcon extends StatelessWidget {
  const MotodiSplashIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _MotodiSplashIconPainter());
  }
}

class _MotodiSplashIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 130;
    final dx = (size.width - 130 * scale) / 2;
    final dy = (size.height - 130 * scale) / 2;
    canvas
      ..save()
      ..translate(dx, dy)
      ..scale(scale);

    final iconPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(22, 8, 86, 86), const Radius.circular(26)),
      );
    final shadowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawPath(iconPath.shift(const Offset(0, 14)), shadowPaint);

    final greenPaint = Paint()..color = AppColors.primary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(22, 8, 86, 86), const Radius.circular(26)),
      greenPaint,
    );

    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawCircle(const Offset(78, 62), 7, stroke);
    canvas.drawCircle(const Offset(52, 62), 7, stroke);
    canvas.drawCircle(const Offset(71, 37), 2, stroke);
    canvas.drawPath(
      Path()
        ..moveTo(65, 62)
        ..lineTo(65, 55)
        ..lineTo(59, 49)
        ..lineTo(67, 43)
        ..lineTo(71, 49)
        ..lineTo(75, 49),
      stroke,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
