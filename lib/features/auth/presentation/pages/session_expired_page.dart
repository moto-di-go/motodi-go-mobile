import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_buttons.dart';

class SessionExpiredPage extends StatelessWidget {
  const SessionExpiredPage({super.key});

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
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2C7),
                  borderRadius: BorderRadius.circular(34),
                ),
                child: const Icon(Icons.lock_outline_rounded, color: Color(0xFF9B6B0B), size: 70),
              ),
              const SizedBox(height: 56),
              Text(
                'Votre session a expiré',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 26),
              Text(
                'Pour votre sécurité, veuillez vous reconnecter afin de continuer.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: const Color(0xFF5B6760), height: 1.45),
              ),
              const Spacer(flex: 4),
              PrimaryAuthButton(
                label: 'Se reconnecter',
                onPressed: () async {
                  await context.read<SessionCubit>().changeAccount();
                  if (context.mounted) context.go(RouteConstants.login);
                },
              ),
              const SizedBox(height: 18),
              TextButton(
                onPressed: () async {
                  await context.read<SessionCubit>().changeAccount();
                  if (context.mounted) context.go(RouteConstants.welcome);
                },
                child: const Text(
                  'Changer de compte',
                  style: TextStyle(
                    color: Color(0xFF5B6760),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
