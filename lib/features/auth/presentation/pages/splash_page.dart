import 'package:flutter/material.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/motodi_logo.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFBFCF8),
      body: SafeArea(
        child: Column(
          children: [
            Spacer(flex: 5),
            Center(child: MotodiLogo(size: 92, showText: true)),
            Spacer(flex: 4),
            _Dots(),
            SizedBox(height: 26),
            Text(
              'Vérification de la session...',
              style: TextStyle(color: Color(0xFF9AA59C), fontSize: 18, fontWeight: FontWeight.w800),
            ),
            Spacer(),
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
