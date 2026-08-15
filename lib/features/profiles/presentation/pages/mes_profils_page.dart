import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/user_profile.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/cubit/profile_cubit.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/widgets/profile_widgets.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/widgets/settings_figma_icons.dart';

TextStyle _mineText({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w400,
  Color color = const Color(0xFF101512),
  double? height,
}) {
  return GoogleFonts.outfit(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
  );
}

class MesProfilsPage extends StatelessWidget {
  const MesProfilsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..loadProfiles(),
      child: const _MesProfilsView(),
    );
  }
}

class _MesProfilsView extends StatelessWidget {
  const _MesProfilsView();

  int _blockedActionsCount(UserProfile profile) {
    if (!profile.requiresValidation || profile.isValidated) return 0;
    return switch (profile.type) {
      ProfileType.mototaxi || ProfileType.transporter => 3,
      ProfileType.passenger => 1,
      _ => 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) async {
            if (state.isSaved) {
              await context.read<SessionCubit>().refreshAfterProfileChange();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profil activé')),
                );
              }
            } else if (state.status == ProfileStatus.failure && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          },
          builder: (context, state) {
            final profiles = state.profiles.where((p) => p.canBeShownInMobile).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 24, 8),
                  child: Row(
                    children: [
                      _BackButton(onTap: () => context.pop()),
                      const SizedBox(width: 10),
                      Text(
                        'Mes profils',
                        style: _mineText(fontSize: 28, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: state.status == ProfileStatus.loading && profiles.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                          children: [
                            for (final profile in profiles) ...[
                              ProfileChoiceCard(
                                type: profile.type,
                                profile: profile,
                                selected: profile.active,
                                showAction: !profile.active,
                                compact: true,
                                showStatusDot: false,
                                footer: _blockedBanner(profile),
                                onTap: () {
                                  if (profile.validationStatus == ValidationStatus.suspended) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Ce profil est suspendu.')),
                                    );
                                    return;
                                  }
                                  if (!profile.active) {
                                    context.read<ProfileCubit>().activateProfile(profile.id);
                                  }
                                },
                              ),
                              const SizedBox(height: 14),
                            ],
                          ],
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  child: ElevatedButton(
                    onPressed: () => context.push(RouteConstants.profileSelection),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    child: Text(
                      '+ Ajouter un profil',
                      style: _mineText(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget? _blockedBanner(UserProfile profile) {
    final count = _blockedActionsCount(profile);
    if (count == 0) return null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3C9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const MotodigoSettingsLockIcon(size: 16, color: Color(0xFF8A6A00)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$count action${count > 1 ? 's' : ''} bloquée${count > 1 ? 's' : ''} — validation requise',
              style: _mineText(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF8A6A00),
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xFFF1F1EA),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF101512)),
      ),
    );
  }
}
