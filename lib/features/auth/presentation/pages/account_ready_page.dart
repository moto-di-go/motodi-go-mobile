import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_buttons.dart';

class AccountReadyPage extends StatelessWidget {
  const AccountReadyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
          child: Column(
            children: [
              const Spacer(flex: 4),
              Container(
                width: 126,
                height: 126,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.check_rounded, size: 70, color: Colors.white),
                ),
              ),
              const SizedBox(height: 56),
              Text(
                'Votre compte est\nprêt',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Numéro vérifié avec succès.\nChoisissez maintenant le profil que\nvous souhaitez utiliser.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: const Color(0xFF5B6760), height: 1.45),
              ),
              const Spacer(flex: 5),
              PrimaryAuthButton(
                label: 'Choisir mon profil',
                onPressed: () => context.go(RouteConstants.profileSelection),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
