import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/l10n/app_locale_controller.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_buttons.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = AppLocaleController.of(context);
    final langCode = localeController.locale?.languageCode ?? Localizations.localeOf(context).languageCode;
    final isFr = langCode != 'en';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F2ED),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LangChip(
                        label: 'FR',
                        selected: isFr,
                        onTap: () => localeController.setLocale(const Locale('fr')),
                      ),
                      _LangChip(
                        label: 'EN',
                        selected: !isFr,
                        onTap: () => localeController.setLocale(const Locale('en')),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 60),
              Container(
                height: 214,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F8F2),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: const Color(0xFFD8E7DC)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/onboarding-mototaxi-city.png',
                      fit: BoxFit.cover,
                      alignment: const Alignment(0.0, 0.15),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x14000000), Color(0x99000000)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              Text(
                'Trouvez un mototaxi\nfiable, en quelques\nsecondes'.tr(context),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1.13,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Des conducteurs proches de vous et un prix standardisé, à Yaoundé et partout au Cameroun.'.tr(
                  context,
                ),
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: const Color(0xFF5B6760), height: 1.45),
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  for (var i = 0; i < 3; i++)
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD6DEDA),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 28),
              PrimaryAuthButton(
                label: 'Continuer'.tr(context),
                onPressed: () async {
                  await context.read<SessionCubit>().completeOnboarding();
                  if (context.mounted) context.go(RouteConstants.welcome);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF68736B),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
