import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_buttons.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/user_profile.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/cubit/profile_cubit.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/widgets/profile_hub_figma_icons.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/widgets/profile_widgets.dart';
import 'package:motodi_go_mobile/l10n/app_localizations.dart';

TextStyle _drawerText({
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

String _initialsFrom(String name) {
  final letterParts = name
      .trim()
      .split(RegExp(r'\s+'))
      .map((part) => part.replaceAll(RegExp(r'[^A-Za-zÀ-ÿ]'), ''))
      .where((part) => part.isNotEmpty)
      .toList();
  if (letterParts.isEmpty) return '?';
  return letterParts.take(2).map((p) => p[0].toUpperCase()).join();
}

bool _looksLikePhone(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  return digits.length >= 8 && !RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(value);
}

String _statusLabel(BuildContext context, ValidationStatus status) {
  return switch (status) {
    ValidationStatus.validated => 'vérifié'.tr(context),
    ValidationStatus.pending => 'en attente'.tr(context),
    ValidationStatus.rejected => 'rejeté'.tr(context),
    ValidationStatus.suspended => 'suspendu'.tr(context),
    ValidationStatus.draft => 'brouillon'.tr(context),
    ValidationStatus.unknown => 'inconnu'.tr(context),
  };
}

/// Ouvre le drawer latéral d'accueil (burger menu).
Future<void> showHomeSideDrawer(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Menu',
    barrierColor: Colors.black.withValues(alpha: 0.35),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: Colors.transparent,
          child: HomeSideDrawer(
            onClose: () => Navigator.of(dialogContext).pop(),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(curved),
        child: child,
      );
    },
  );
}

class HomeSideDrawer extends StatelessWidget {
  final VoidCallback onClose;

  const HomeSideDrawer({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width * 0.86;
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..loadProfiles(),
      child: SizedBox(
        width: width.clamp(280, 360),
        height: double.infinity,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
          ),
          child: SafeArea(
            child: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                final session = context.watch<SessionCubit>().state;
                final sessionActive = session.activeProfile;

                UserProfile? active;
                if (sessionActive != null) {
                  for (final profile in state.profiles) {
                    if (profile.id == sessionActive.id) {
                      active = profile;
                      break;
                    }
                  }
                }
                active ??= state.profiles.where((p) => p.active).firstOrNull;

                final rawName = active?.displayName.trim() ?? '';
                final fallback = 'Mon profil'.tr(context);
                final displayName = rawName.isNotEmpty && !_looksLikePhone(rawName)
                    ? rawName
                    : fallback;
                final type = sessionActive?.type ?? active?.type ?? ProfileType.passenger;
                final status =
                    sessionActive?.validationStatus ??
                    active?.validationStatus ??
                    ValidationStatus.pending;
                final typeLabel = profileLabel(context, type);
                final initials = _initialsFrom(
                  displayName != fallback ? displayName : typeLabel,
                );
                final verifiedLine = '$typeLabel · ${_statusLabel(context, status)}';

                return Padding(
                  padding: const EdgeInsets.fromLTRB(22, 12, 18, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              initials,
                              style: _drawerText(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _drawerText(fontSize: 20, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const MotodigoHubCheckedGreenIcon(size: 15),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        verifiedLine,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: _drawerText(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF16A34A),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: onClose,
                            child: const SizedBox(
                              width: 40,
                              height: 40,
                              child: Icon(Icons.close_rounded, color: Color(0xFF5B6760)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _ChangeProfileCard(
                        onTap: () {
                          onClose();
                          _showProfileSwitcher(context);
                        },
                      ),
                      const SizedBox(height: 18),
                      _DrawerMenuTile(
                        icon: const MotodigoHubFolderGrayIcon(size: 20),
                        title: 'Documents & validation'.tr(context),
                        onTap: () {
                          onClose();
                          context.push(RouteConstants.kyc);
                        },
                      ),
                      const Divider(height: 1, color: Color(0xFFE8EBE4)),
                      _DrawerMenuTile(
                        icon: const MotodigoHubSettingsIcon(size: 20),
                        title: 'Paramètres'.tr(context),
                        onTap: () {
                          onClose();
                          context.push(RouteConstants.settings);
                        },
                      ),
                      const Divider(height: 1, color: Color(0xFFE8EBE4)),
                      _DrawerMenuTile(
                        icon: const Icon(Icons.info_outline_rounded, size: 22, color: Color(0xFF5B6760)),
                        title: 'Aide & support'.tr(context),
                        onTap: () {
                          onClose();
                          context.push(RouteConstants.support);
                        },
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            onClose();
                            _showLogoutConfirm(context);
                          },
                          icon: const Icon(Icons.logout_rounded, color: Color(0xFFC62828), size: 22),
                          label: Text(
                            'Se déconnecter'.tr(context),
                            style: _drawerText(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFC62828),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ChangeProfileCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ChangeProfileCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE8F8EE),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            children: [
              const MotodigoHubPeopleIcon(size: 22, color: Color(0xFF16A34A)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Changer de profil actif'.tr(context),
                      style: _drawerText(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F5132),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Passager, Mototaxi...'.tr(context),
                      style: _drawerText(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF16A34A), size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerMenuTile extends StatelessWidget {
  final Widget icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: icon,
      title: Text(
        title,
        style: _drawerText(fontSize: 17, fontWeight: FontWeight.w700),
      ),
      onTap: onTap,
    );
  }
}

void _showProfileSwitcher(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
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
              await sheetContext.read<SessionCubit>().refreshAfterProfileChange();
              if (sheetContext.mounted) Navigator.of(sheetContext).pop();
            }
          },
          builder: (context, state) {
            return Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.profileSwitcherTitle,
                    style: _drawerText(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  if (state.status == ProfileStatus.loading)
                    const Center(child: CircularProgressIndicator())
                  else
                    for (final profile in state.profiles) ...[
                      ProfileChoiceCard(
                        type: profile.type,
                        profile: profile,
                        selected: profile.active,
                        showAction: !profile.active,
                        compact: true,
                        onTap: () {
                          if (profile.validationStatus == ValidationStatus.suspended) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Ce profil est suspendu.'.tr(context))),
                            );
                            return;
                          }
                          if (!profile.active) {
                            context.read<ProfileCubit>().activateProfile(profile.id);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

void _showLogoutConfirm(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Se déconnecter ?'.tr(context),
              style: _drawerText(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            PrimaryAuthButton(
              label: 'Se déconnecter'.tr(context),
              backgroundColor: AppColors.error,
              onPressed: () async {
                Navigator.of(sheetContext).pop();
                await context.read<SessionCubit>().logout();
                if (context.mounted) context.go(RouteConstants.login);
              },
            ),
            const SizedBox(height: 10),
            SecondaryAuthButton(
              label: 'Annuler'.tr(context),
              onPressed: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      );
    },
  );
}
