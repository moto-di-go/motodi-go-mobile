import 'package:flutter/material.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/motodi_logo.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 5),
            const Center(child: MotodiLogo(size: 92, showText: true)),
            const Spacer(flex: 4),
            const _Dots(),
            const SizedBox(height: 26),
            Text(
              'Vérification de la session...'.tr(context),
              style: const TextStyle(
                color: Color(0xFF9AA59C),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.symmetric(horizontal: 7),
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
