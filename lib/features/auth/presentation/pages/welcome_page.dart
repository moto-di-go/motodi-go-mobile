import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_buttons.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/motodi_logo.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      scrollable: false,
      child: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 64),
            const MotodiLogo(size: 86),
            const SizedBox(height: 54),
            Text(
              "Bienvenue sur Moto'di\nGo",
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                height: 1.12,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Créez votre compte ou connectez-vous pour trouver un mototaxi, un trajet ou un transporteur vérifié.',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: const Color(0xFF5B6760), height: 1.5),
            ),
            const Spacer(),
            PrimaryAuthButton(
              label: 'Créer un compte',
              leadingIcon: Icons.phone_outlined,
              onPressed: () => context.go(RouteConstants.register),
            ),
            const SizedBox(height: 16),
            SecondaryAuthButton(
              label: 'Se connecter',
              icon: Icons.lock_outline_rounded,
              onPressed: () => context.go(RouteConstants.login),
            ),
            const SizedBox(height: 28),
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    color: Color(0xFF95A099),
                    fontSize: 16,
                    height: 1.45,
                    fontWeight: FontWeight.w700,
                  ),
                  children: [
                    TextSpan(text: 'En continuant, vous acceptez nos '),
                    TextSpan(
                      text: "Conditions\nd'utilisation",
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900),
                    ),
                    TextSpan(text: ' et notre '),
                    TextSpan(
                      text: 'Politique de confidentialité.',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900),
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
