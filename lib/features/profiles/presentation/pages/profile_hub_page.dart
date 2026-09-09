import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/user_profile.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/cubit/profile_cubit.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/widgets/profile_figma_icons.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/widgets/profile_hub_figma_icons.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/widgets/profile_widgets.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';

TextStyle _hubText({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w400,
  Color color = const Color(0xFF101512),
  double? height,
  double? letterSpacing,
}) {
  return GoogleFonts.outfit(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

String _formatPhone(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  var national = digits;
  if (digits.startsWith('237') && digits.length >= 12) {
    national = digits.substring(3);
  } else if (digits.length > 9) {
    national = digits.substring(digits.length - 9);
  }
  if (national.length != 9) return raw.trim();
  // +237 6 78 90 12 34
  return '+237 ${national[0]} ${national.substring(1, 3)} ${national.substring(3, 5)} '
      '${national.substring(5, 7)} ${national.substring(7)}';
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

String _kycStatusLabel(BuildContext context, ValidationStatus status) {
  return switch (status) {
    ValidationStatus.validated => 'Vérifié'.tr(context),
    ValidationStatus.pending => 'En attente'.tr(context),
    ValidationStatus.rejected => 'Rejeté'.tr(context),
    ValidationStatus.suspended => 'Suspendu'.tr(context),
    ValidationStatus.draft => 'Brouillon'.tr(context),
    ValidationStatus.unknown => 'Inconnu'.tr(context),
  };
}

class ProfileHubPage extends StatelessWidget {
  const ProfileHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..loadProfiles(),
      child: const _ProfileHubView(),
    );
  }
}

class _ProfileHubView extends StatelessWidget {
  const _ProfileHubView();

  @override
  Widget build(BuildContext context) {
    final monProfil = 'Mon profil'.tr(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF6),
      body: SafeArea(
        child: BlocListener<SessionCubit, SessionState>(
          listenWhen: (previous, next) =>
              previous.activeProfile?.id != next.activeProfile?.id ||
              previous.activeProfile?.type != next.activeProfile?.type,
          listener: (context, state) {
            context.read<ProfileCubit>().loadProfiles();
          },
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
              if (active == null) {
                for (final profile in state.profiles) {
                  if (profile.active) {
                    active = profile;
                    break;
                  }
                }
              }

              final rawName = active?.displayName.trim() ?? '';
              final displayName = rawName.isNotEmpty && !_looksLikePhone(rawName)
                  ? rawName
                  : monProfil;
              final phoneRaw = session.session?.phoneNumber ?? session.lastPhoneNumber ?? '';
              final phone = phoneRaw.isNotEmpty ? _formatPhone(phoneRaw) : '';
              // La session est la source de vérité après un switch de profil.
              final type = sessionActive?.type ?? active?.type ?? ProfileType.passenger;
              final status =
                  sessionActive?.validationStatus ??
                  active?.validationStatus ??
                  ValidationStatus.pending;
              final initials = _initialsFrom(
                displayName != monProfil ? displayName : profileLabel(context, type),
              );

              return ListView(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Profil'.tr(context),
                          style: _hubText(fontSize: 34, fontWeight: FontWeight.w800, height: 1.05),
                        ),
                      ),
                      _SettingsButton(onTap: () => context.push(RouteConstants.settings)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _InitialsAvatar(initials: initials),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _hubText(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                              ),
                            ),
                            if (phone.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const MotodigoHubCheckedGreenIcon(size: 15),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      phone,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: _hubText(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF16A34A),
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(child: _ActiveProfileCard(typeLabel: profileLabel(context, type))),
                      const SizedBox(width: 12),
                      Expanded(child: _KycStatusCard(status: status)),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _MenuCard(
                    icon: const MotodigoHubFolderGrayIcon(size: 20),
                    title: 'Documents & validation'.tr(context),
                    onTap: () => context.push(RouteConstants.kyc),
                  ),
                  const SizedBox(height: 10),
                  _MenuCard(
                    icon: const MotodigoHubPeopleIcon(size: 20),
                    title: 'Mes profils'.tr(context),
                    onTap: () => context.push(RouteConstants.profilesMine),
                  ),
                  const SizedBox(height: 10),
                  _MenuCard(
                    icon: const Icon(Icons.history_rounded, size: 22, color: Color(0xFF5B6760)),
                    title: 'Historique des trajets'.tr(context),
                    onTap: () => context.push(RouteConstants.tripsHistory),
                  ),
                  const SizedBox(height: 10),
                  _MenuCard(
                    icon: const Icon(Icons.receipt_long_rounded, size: 22, color: Color(0xFF5B6760)),
                    title: 'Mes reçus'.tr(context),
                    onTap: () => context.push(RouteConstants.receipts),
                  ),
                  const SizedBox(height: 10),
                  _MenuCard(
                    icon: const Icon(Icons.support_agent_rounded, size: 22, color: Color(0xFF5B6760)),
                    title: 'Support'.tr(context),
                    onTap: () => context.push(RouteConstants.support),
                  ),
                  const SizedBox(height: 10),
                  _MenuCard(
                    icon: const Icon(Icons.cloud_off_rounded, size: 22, color: Color(0xFF5B6760)),
                    title: 'Mode hors-ligne'.tr(context),
                    onTap: () => context.push(RouteConstants.offline),
                  ),
                  const SizedBox(height: 10),
                  _MenuCard(
                    icon: const MotodigoHubSettingsIcon(size: 20),
                    title: 'Paramètres'.tr(context),
                    onTap: () => context.push(RouteConstants.settings),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          SnackBar(content: Text('Bientôt disponible'.tr(context))),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF101512),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF101512), width: 1.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      ),
                      child: Text(
                        'Modifier mon profil'.tr(context),
                        style: _hubText(fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SettingsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1EA),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const MotodigoHubSettingsIcon(size: 20, color: Color(0xFF101512)),
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String initials;

  const _InitialsAvatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle),
      child: Text(
        initials,
        style: _hubText(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ActiveProfileCard extends StatelessWidget {
  final String typeLabel;

  const _ActiveProfileCard({required this.typeLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E7DF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profil actif'.tr(context),
            style: _hubText(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF8A968C),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              const MotodigoProfilePersonIcon(size: 18, color: Color(0xFF16A34A)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  typeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _hubText(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KycStatusCard extends StatelessWidget {
  final ValidationStatus status;

  const _KycStatusCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final label = _kycStatusLabel(context, status);
    final color = statusColor(status);
    final isVerified = status == ValidationStatus.validated;

    return Container(
      height: 92,
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E7DF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statut KYC'.tr(context),
            style: _hubText(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF8A968C),
            ),
          ),
          const Spacer(),
          if (isVerified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8EE),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF16A34A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    label,
                    style: _hubText(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _hubText(fontSize: 16, fontWeight: FontWeight.w800, color: color),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final VoidCallback onTap;

  const _MenuCard({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE4E7DF)),
          ),
          child: Row(
            children: [
              SizedBox(width: 28, height: 28, child: Center(child: icon)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(title, style: _hubText(fontSize: 17, fontWeight: FontWeight.w600)),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFC2C8C0), size: 26),
            ],
          ),
        ),
      ),
    );
  }
}
