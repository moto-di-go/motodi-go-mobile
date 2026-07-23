import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_buttons.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/cubit/profile_cubit.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/widgets/profile_widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) {
        final active = state.activeProfile;
        final type = active?.type ?? ProfileType.passenger;
        final status = active?.validationStatus ?? ValidationStatus.validated;
        final isLocked =
            type != ProfileType.passenger &&
            status != ValidationStatus.validated;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              children: [
                Row(
                  children: [
                    _SquareIconButton(
                      icon: Icons.menu_rounded,
                      onTap: () => _showLogoutSheet(context),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w900,
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
                    ),
                    _SquareIconButton(
                      icon: Icons.notifications_none_rounded,
                      onTap: () {},
                      badge: true,
                    ),
                    const SizedBox(width: 14),
                    InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () => _showProfileSwitcher(context),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: const Color(0xFFDFF5E8),
                        child: Icon(
                          profileIcon(type),
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 34),
                if (isLocked)
                  _PendingValidationCard(type: type, status: status),
                if (!isLocked) _PassengerReadyCard(type: type),
                const SizedBox(height: 38),
                Text(
                  type == ProfileType.passenger
                      ? 'FONCTIONS PASSAGER'
                      : 'FONCTIONS CONDUCTEUR',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF9CA7A0),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 18),
                if (type == ProfileType.passenger) ...[
                  const _FeatureTile(
                    icon: Icons.search_rounded,
                    title: 'Trouver un mototaxi',
                    subtitle: 'Recherche disponible',
                    locked: false,
                  ),
                  const _FeatureTile(
                    icon: Icons.route_outlined,
                    title: 'Préparer un trajet',
                    subtitle: 'Prix standardisé',
                    locked: false,
                  ),
                ] else ...[
                  _FeatureTile(
                    icon: Icons.tune_rounded,
                    title: 'Passer en ligne',
                    subtitle: isLocked
                        ? 'Disponible après validation'
                        : 'Disponible maintenant',
                    locked: isLocked,
                  ),
                  _FeatureTile(
                    icon: Icons.bookmark_border_rounded,
                    title: 'Publier une annonce',
                    subtitle: isLocked
                        ? 'Disponible après validation'
                        : 'Créer une offre',
                    locked: isLocked,
                  ),
                  _FeatureTile(
                    icon: Icons.my_location_rounded,
                    title: 'Partager ma position',
                    subtitle: isLocked
                        ? 'Disponible après validation'
                        : 'GPS conducteur',
                    locked: isLocked,
                  ),
                ],
              ],
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: 0,
            onDestinationSelected: (index) {
              if (index == 4) _showLogoutSheet(context);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Accueil',
              ),
              NavigationDestination(
                icon: Icon(Icons.route_outlined),
                label: 'Trajets',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                label: 'Wallet',
              ),
              NavigationDestination(
                icon: Icon(Icons.notifications_none_rounded),
                label: 'Notifs',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                label: 'Profil',
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProfileSwitcher(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BlocProvider(
          create: (_) => getIt<ProfileCubit>()..loadProfiles(),
          child: BlocConsumer<ProfileCubit, ProfileState>(
            listener: (context, state) async {
              if (state.isSaved) {
                await sheetContext
                    .read<SessionCubit>()
                    .refreshAfterProfileChange();
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
              }
            },
            builder: (context, state) {
              return _BottomSheetFrame(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 54,
                        height: 7,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDE3DA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Changer de profil',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Un profil actif à la fois.',
                      style: TextStyle(
                        color: Color(0xFF8E9A91),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (state.status == ProfileStatus.loading)
                      const Center(child: CircularProgressIndicator())
                    else
                      for (final profile in state.profiles) ...[
                        ProfileChoiceCard(
                          type: profile.type,
                          profile: profile,
                          selected: profile.active,
                          showAction: !profile.active,
                          onTap: () {
                            if (profile.validationStatus ==
                                ValidationStatus.suspended) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Ce profil est suspendu.'),
                                ),
                              );
                              return;
                            }
                            if (!profile.active) {
                              context.read<ProfileCubit>().activateProfile(
                                profile.id,
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                      ],
                    SecondaryAuthButton(
                      label: 'Ajouter un profil',
                      icon: Icons.add_rounded,
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        sheetContext.go(RouteConstants.profileSelection);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showLogoutSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _BottomSheetFrame(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 44,
                backgroundColor: Color(0xFFFBE3E5),
                child: Icon(
                  Icons.logout_rounded,
                  size: 42,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 26),
              Text(
                'Se déconnecter ?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Vous devrez saisir à nouveau votre numéro et votre mot de passe pour vous reconnecter.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF5B6760),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 34),
              PrimaryAuthButton(
                label: 'Se déconnecter',
                backgroundColor: AppColors.error,
                onPressed: () async {
                  Navigator.of(sheetContext).pop();
                  await context.read<SessionCubit>().logout();
                  if (context.mounted) context.go(RouteConstants.login);
                },
              ),
              const SizedBox(height: 14),
              SecondaryAuthButton(
                label: 'Annuler',
                onPressed: () => Navigator.of(sheetContext).pop(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PendingValidationCard extends StatelessWidget {
  final ProfileType type;
  final ValidationStatus status;

  const _PendingValidationCard({required this.type, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3C9),
        border: Border.all(color: const Color(0xFFF3D77B)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7DD7A),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: Color(0xFF9B6B0B),
                  size: 36,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profil en attente de validation',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 8),
                    StatusBadge(status: status),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Prochaine étape : fournir vos documents pour activer vos fonctions conducteur.',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF8B6509),
              height: 1.42,
            ),
          ),
          const SizedBox(height: 24),
          PrimaryAuthButton(
            label: 'Voir mes documents',
            leadingIcon: Icons.description_outlined,
            backgroundColor: AppColors.textPrimary,
            onPressed: () => context.go(RouteConstants.kycDocuments),
          ),
        ],
      ),
    );
  }
}

class _PassengerReadyCard extends StatelessWidget {
  final ProfileType type;

  const _PassengerReadyCard({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFAF3),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: const Color(0xFFDDF5E6),
            child: Icon(profileIcon(type), color: AppColors.primary, size: 34),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${profileLabel(type)} actif',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Vous pouvez utiliser les fonctions disponibles.',
                  style: TextStyle(
                    color: Color(0xFF5B6760),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool locked;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    final color = locked ? const Color(0xFFA8B0AA) : AppColors.textPrimary;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7ECE6)),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F2ED),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: const Color(0xFF9AA49D)),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFFA8B0AA),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (locked)
            const Icon(Icons.lock_outline_rounded, color: Color(0xFFA8B0AA)),
        ],
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;

  const _SquareIconButton({
    required this.icon,
    required this.onTap,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F2ED),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 30),
          ),
          if (badge)
            const Positioned(
              right: 8,
              top: 8,
              child: CircleAvatar(radius: 5, backgroundColor: AppColors.error),
            ),
        ],
      ),
    );
  }
}

class _BottomSheetFrame extends StatelessWidget {
  final Widget child;

  const _BottomSheetFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: child,
      ),
    );
  }
}
