import 'package:flutter/material.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/user_profile.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/widgets/profile_figma_icons.dart';

IconData profileIcon(ProfileType type) {
  return switch (type) {
    ProfileType.passenger => Icons.person_outline_rounded,
    ProfileType.mototaxi => Icons.pedal_bike_rounded,
    ProfileType.transporter => Icons.directions_bus_filled_outlined,
    ProfileType.agency => Icons.apartment_rounded,
    ProfileType.admin => Icons.admin_panel_settings_outlined,
    ProfileType.unknown => Icons.help_outline_rounded,
  };
}

String profileLabel(ProfileType type) {
  return switch (type) {
    ProfileType.passenger => 'Passager',
    ProfileType.mototaxi => 'Mototaxi',
    ProfileType.transporter => 'Transporteur',
    ProfileType.agency => 'Agence',
    ProfileType.admin => 'Admin',
    ProfileType.unknown => 'Profil',
  };
}

String statusLabel(ValidationStatus status, {bool active = false}) {
  if (active && status == ValidationStatus.validated) return 'Accès immédiat';
  return switch (status) {
    ValidationStatus.validated => 'Accès immédiat',
    ValidationStatus.pending => 'Validation requise',
    ValidationStatus.rejected => 'Rejeté',
    ValidationStatus.suspended => 'Suspendu',
    ValidationStatus.draft => 'Brouillon',
    ValidationStatus.unknown => 'Statut inconnu',
  };
}

String compactStatusLabel(ValidationStatus status, {bool active = false}) {
  if (active && status == ValidationStatus.validated) return 'Validé · actif';
  return switch (status) {
    ValidationStatus.validated => 'Validé',
    ValidationStatus.pending => 'En attente',
    ValidationStatus.rejected => 'Rejeté',
    ValidationStatus.suspended => 'Suspendu',
    ValidationStatus.draft => 'Brouillon',
    ValidationStatus.unknown => 'Statut inconnu',
  };
}

Color statusColor(ValidationStatus status) {
  return switch (status) {
    ValidationStatus.validated => AppColors.primary,
    ValidationStatus.pending => const Color(0xFFD39B08),
    ValidationStatus.rejected => const Color(0xFFC62828),
    ValidationStatus.suspended => const Color(0xFF6B7280),
    ValidationStatus.draft => const Color(0xFF6B7280),
    ValidationStatus.unknown => const Color(0xFF6B7280),
  };
}

class ProfileChoiceCard extends StatelessWidget {
  final ProfileType type;
  final UserProfile? profile;
  final bool selected;
  final VoidCallback onTap;
  final bool showAction;
  final bool compact;
  final bool showStatusDot;
  final Widget? footer;

  const ProfileChoiceCard({
    super.key,
    required this.type,
    this.profile,
    required this.selected,
    required this.onTap,
    this.showAction = false,
    this.compact = false,
    this.showStatusDot = true,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final status =
        profile?.validationStatus ?? ValidationStatus.pending;
    final active = profile?.active ?? false;
    final iconColor = selected ? AppColors.primary : const Color(0xFF3C4741);
    final borderRadius = compact ? 18.0 : 24.0;
    final iconSize = compact ? 42.0 : 64.0;
    final iconRadius = compact ? 14.0 : 20.0;
    final contentPadding = compact
        ? const EdgeInsets.all(12)
        : const EdgeInsets.symmetric(horizontal: 20, vertical: 20);

    return Material(
      color: selected ? const Color(0xFFEFFAF3) : Colors.white,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: compact ? 84 : 112),
          padding: contentPadding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE0E5DF),
              width: selected ? (compact ? 2 : 2.5) : 1.3,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFDFF5E8)
                          : const Color(0xFFF1F2ED),
                      borderRadius: BorderRadius.circular(iconRadius),
                    ),
                    child: Center(
                      child: ProfileTypeIcon(
                        type: type,
                        color: iconColor,
                        size: compact ? 24 : 32,
                      ),
                    ),
                  ),
                  SizedBox(width: compact ? 14 : 22),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          profileLabel(type),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: compact ? 21 : 25,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                          ),
                        ),
                        SizedBox(height: compact ? 6 : 8),
                        StatusBadge(
                          status: status,
                          active: active,
                          compact: compact,
                          showDot: showStatusDot,
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    CircleAvatar(
                      radius: compact ? 22 : 24,
                      backgroundColor: AppColors.primary,
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    )
                  else if (showAction)
                    Text(
                      'Utiliser',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontSize: compact ? 19 : null,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  else
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFB7C0B8),
                      size: 38,
                    ),
                ],
              ),
              if (footer != null) ...[
                const SizedBox(height: 12),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileTypeIcon extends StatelessWidget {
  final ProfileType type;
  final Color color;
  final double size;

  const ProfileTypeIcon({
    super.key,
    required this.type,
    required this.color,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      ProfileType.passenger => MotodigoProfilePersonIcon(
        size: size,
        color: color,
      ),
      ProfileType.mototaxi => MotodigoMototaxiIcon(size: size, color: color),
      ProfileType.transporter => MotodigoTransporterIcon(
        size: size,
        color: color,
      ),
      _ => Icon(profileIcon(type), color: color, size: size),
    };
  }
}

class StatusBadge extends StatelessWidget {
  final ValidationStatus status;
  final bool active;
  final bool compact;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.status,
    this.active = false,
    this.compact = false,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: showDot ? 12 : 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            CircleAvatar(radius: 4, backgroundColor: color),
            const SizedBox(width: 8),
          ],
          Text(
            compact
                ? compactStatusLabel(status, active: active)
                : statusLabel(status, active: active),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontSize: compact ? 15 : 16,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}
