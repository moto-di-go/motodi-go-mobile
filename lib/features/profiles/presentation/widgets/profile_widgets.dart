import 'package:flutter/material.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/user_profile.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';

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
  if (active && status == ValidationStatus.validated) return 'Validé · actif';
  return switch (status) {
    ValidationStatus.validated => 'Accès immédiat',
    ValidationStatus.pending => 'Validation requise',
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

  const ProfileChoiceCard({
    super.key,
    required this.type,
    this.profile,
    required this.selected,
    required this.onTap,
    this.showAction = false,
  });

  @override
  Widget build(BuildContext context) {
    final status =
        profile?.validationStatus ??
        (type == ProfileType.passenger ? ValidationStatus.validated : ValidationStatus.pending);
    final active = profile?.active ?? false;
    final borderColor = selected ? AppColors.primary : const Color(0xFFE0E5DF);
    final backgroundColor = selected ? const Color(0xFFEFFAF3) : Colors.white;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 94),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: selected ? 2.5 : 1.3),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFDDF5E6) : const Color(0xFFF1F2ED),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  profileIcon(type),
                  color: selected ? AppColors.primary : const Color(0xFF46524A),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      profileLabel(type),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    StatusBadge(status: status, active: active),
                  ],
                ),
              ),
              if (selected)
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.check_rounded, color: Colors.white),
                )
              else if (showAction)
                Text(
                  'Utiliser',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                )
              else
                const Icon(Icons.chevron_right_rounded, color: Color(0xFFB7C0B8), size: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final ValidationStatus status;
  final bool active;

  const StatusBadge({super.key, required this.status, this.active = false});

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 4, backgroundColor: color),
          const SizedBox(width: 8),
          Text(
            statusLabel(status, active: active),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
