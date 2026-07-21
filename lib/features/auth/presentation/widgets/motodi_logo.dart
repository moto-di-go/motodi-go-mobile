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
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.22),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Icon(Icons.pedal_bike_rounded, color: Colors.white, size: size * 0.52),
        ),
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
