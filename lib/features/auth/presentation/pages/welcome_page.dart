import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/motodi_logo.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      padding: const EdgeInsets.fromLTRB(22, 30, 22, 26),
      scrollable: false,
      child: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MotodiLogo(size: 128),
            const SizedBox(height: 0),
            Text(
              "Bienvenue sur Moto'di Go",
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Créez votre compte ou connectez-vous pour trouver un mototaxi, un trajet ou un transporteur vérifié.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF54615A),
                fontSize: 20,
                fontWeight: FontWeight.w500,
                height: 1.55,
              ),
            ),
            const Spacer(),
            _WelcomeActionButton(
              label: 'Créer un compte',
              icon: const _PhoneIcon(),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              onPressed: () => context.go(RouteConstants.register),
            ),
            const SizedBox(height: 11),
            _WelcomeActionButton(
              label: 'Se connecter',
              icon: const _LockIcon(),
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textPrimary,
              borderColor: const Color(0xFFDEE2DA),
              elevation: 0,
              onPressed: () => context.go(RouteConstants.login),
            ),
            const SizedBox(height: 18),
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    color: Color(0xFF8A968C),
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(text: 'En continuant, vous acceptez nos '),
                    TextSpan(
                      text: "Conditions\nd'utilisation",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(text: ' et notre '),
                    TextSpan(
                      text: 'Politique de confidentialité.',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeActionButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final double elevation;
  final VoidCallback onPressed;

  const _WelcomeActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    this.borderColor,
    this.elevation = 10,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 72,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: elevation,
          shadowColor: backgroundColor.withValues(alpha: 0.34),
          padding: const EdgeInsets.symmetric(horizontal: 34),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: BorderSide(color: borderColor ?? Colors.transparent),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 24, height: 24, child: icon),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneIcon extends StatelessWidget {
  const _PhoneIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _PhoneIconPainter());
  }
}

class _PhoneIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 19;
    final dx = (size.width - 19 * scale) / 2;
    final dy = (size.height - 19 * scale) / 2;
    canvas
      ..save()
      ..translate(dx, dy)
      ..scale(scale);

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(17.4166, 13.395)
      ..lineTo(17.4166, 15.77)
      ..cubicTo(17.4175, 15.9905, 17.3724, 16.2087, 17.284, 16.4107)
      ..cubicTo(17.1957, 16.6127, 17.0662, 16.7941, 16.9037, 16.9431)
      ..cubicTo(16.7412, 17.0922, 16.5494, 17.2057, 16.3406, 17.2763)
      ..cubicTo(16.1317, 17.3469, 15.9104, 17.3732, 15.6908, 17.3533)
      ..cubicTo(13.2547, 17.0886, 10.9147, 16.2562, 8.85872, 14.9229)
      ..cubicTo(6.94591, 13.7074, 5.32419, 12.0857, 4.10872, 10.1729)
      ..cubicTo(2.77078, 8.10762, 1.93816, 5.7562, 1.6783, 3.30916)
      ..cubicTo(1.65852, 3.09024, 1.68454, 2.8696, 1.7547, 2.66128)
      ..cubicTo(1.82486, 2.45297, 1.93763, 2.26154, 2.08582, 2.0992)
      ..cubicTo(2.23402, 1.93685, 2.4144, 1.80714, 2.61547, 1.71833)
      ..cubicTo(2.81654, 1.62951, 3.0339, 1.58354, 3.25372, 1.58333)
      ..lineTo(5.62872, 1.58333)
      ..cubicTo(6.01292, 1.57955, 6.38539, 1.7156, 6.6767, 1.96613)
      ..cubicTo(6.96801, 2.21665, 7.15828, 2.56456, 7.21205, 2.945)
      ..cubicTo(7.31497, 3.705, 7.49705, 4.44916, 7.76622, 5.16958)
      ..cubicTo(7.87273, 5.45294, 7.89578, 5.76089, 7.83264, 6.05694)
      ..cubicTo(7.7695, 6.353, 7.62282, 6.62475, 7.40997, 6.84)
      ..lineTo(6.40455, 7.84541)
      ..cubicTo(7.53153, 9.82739, 9.17258, 11.4684, 11.1546, 12.5954)
      ..lineTo(12.16, 11.59)
      ..cubicTo(12.3752, 11.3771, 12.647, 11.2305, 12.943, 11.1673)
      ..cubicTo(13.2391, 11.1042, 13.547, 11.1272, 13.8304, 11.2337)
      ..cubicTo(14.5508, 11.5029, 15.295, 11.685, 16.055, 11.7879)
      ..cubicTo(16.4395, 11.8422, 16.7907, 12.0359, 17.0418, 12.3322)
      ..cubicTo(17.2929, 12.6285, 17.4263, 13.0067, 17.4166, 13.395);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LockIcon extends StatelessWidget {
  const _LockIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _LockIconPainter());
  }
}

class _LockIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 19;
    final dx = (size.width - 19 * scale) / 2;
    final dy = (size.height - 19 * scale) / 2;
    canvas
      ..save()
      ..translate(dx, dy)
      ..scale(scale);

    final paint = Paint()
      ..color = AppColors.textPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(2.375, 8.70825, 14.25, 8.70835),
        const Radius.circular(1.58333),
      ),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(5.54199, 8.70825)
        ..lineTo(5.54199, 5.54159)
        ..cubicTo(5.54199, 3.355, 7.3137, 1.58325, 9.50033, 1.58325)
        ..cubicTo(11.687, 1.58325, 13.4587, 3.355, 13.4587, 5.54159)
        ..lineTo(13.4587, 8.70825),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
