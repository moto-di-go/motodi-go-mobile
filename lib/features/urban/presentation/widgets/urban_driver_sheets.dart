import 'package:flutter/material.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/intercity_formatters.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_models.dart';
import 'package:motodi_go_mobile/features/urban/presentation/urban_ride_cubit.dart';
import 'package:motodi_go_mobile/features/urban/presentation/urban_ride_state.dart';
import 'package:motodi_go_mobile/features/urban/presentation/widgets/urban_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';

class UrbanSearchingSheet extends StatelessWidget {
  UrbanSearchingSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return UrbanBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recherche des mototaxis…'.tr(context),
            style: urbanText(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          Shimmer.fromColors(
            baseColor: const Color(0xFFE7ECE6),
            highlightColor: const Color(0xFFF7F8F4),
            child: Column(
              children: List.generate(3, (index) {
                return Container(
                  height: 78,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class UrbanResultsSheet extends StatelessWidget {
  final UrbanRideState state;
  final UrbanRideCubit cubit;

  const UrbanResultsSheet({super.key, required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return UrbanBottomSheet(
      maxHeight: MediaQuery.sizeOf(context).height * 0.55,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  Localizations.localeOf(context).languageCode == 'en' ? '${state.drivers.length} mototaxis found' : '${state.drivers.length} mototaxis trouvés',
                  style: urbanText(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              TextButton.icon(
                onPressed: cubit.openFilters,
                icon: const Icon(Icons.tune_rounded, size: 18),
                label: Text(
                  'Filtres'.tr(context),
                  style: urbanText(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          if (state.drivers.any((d) => d.profileIsDemo))
            UrbanDemoBanner(message: 'Fiches conducteur : profils de démonstration'.tr(context)),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.32,
            child: ListView.separated(
              itemCount: state.drivers.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final driver = state.drivers[index];
                final selected = driver.id == state.selectedDriverId;
                return _DriverCard(
                  driver: driver,
                  selected: selected,
                  onTap: () => cubit.selectDriver(driver.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UrbanFiltersSheet extends StatelessWidget {
  final UrbanRideState state;
  final UrbanRideCubit cubit;

  UrbanFiltersSheet({super.key, required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final draft = state.draftFilters;
    return UrbanBottomSheet(
      maxHeight: MediaQuery.sizeOf(context).height * 0.78,
      child: ListView(
        shrinkWrap: true,
        children: [
          Text('Filtres'.tr(context), style: urbanText(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          Text('Rayon de recherche'.tr(context), style: urbanText(fontSize: 15, fontWeight: FontWeight.w800)),
          Slider(
            value: draft.radiusKm.clamp(2, 10),
            min: 2,
            max: 10,
            divisions: 16,
            label: '${draft.radiusKm.toStringAsFixed(1)} km',
            activeColor: AppColors.primary,
            onChanged: (value) => cubit.updateDraftFilters(draft.copyWith(radiusKm: value)),
          ),
          Text(
            '${draft.radiusKm.toStringAsFixed(1)} km',
            style: urbanText(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Text('Note minimale'.tr(context), style: urbanText(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip(
                label: 'Toutes'.tr(context),
                selected: draft.minRating == null,
                onTap: () => cubit.updateDraftFilters(draft.copyWith(minRating: null)),
              ),
              _FilterChip(
                label: '4,0+',
                selected: draft.minRating == 4.0,
                onTap: () => cubit.updateDraftFilters(draft.copyWith(minRating: 4.0)),
              ),
              _FilterChip(
                label: '4,5+',
                selected: draft.minRating == 4.5,
                onTap: () => cubit.updateDraftFilters(draft.copyWith(minRating: 4.5)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Disponibilité immédiate'.tr(context),
              style: urbanText(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            value: draft.immediateOnly,
            activeThumbColor: AppColors.primary,
            onChanged: (value) => cubit.updateDraftFilters(draft.copyWith(immediateOnly: value)),
          ),
          const SizedBox(height: 8),
          Text('Prix maximum'.tr(context), style: urbanText(fontSize: 15, fontWeight: FontWeight.w800)),
          Slider(
            value: (draft.maxPriceFcfa ?? 3000).clamp(400, 5000),
            min: 400,
            max: 5000,
            divisions: 23,
            label: formatPriceF(draft.maxPriceFcfa ?? 3000),
            activeColor: AppColors.primary,
            onChanged: (value) => cubit.updateDraftFilters(draft.copyWith(maxPriceFcfa: value)),
          ),
          Text(
            draft.maxPriceFcfa == null ? 'Aucun plafond'.tr(context) : formatPriceF(draft.maxPriceFcfa!),
            style: urbanText(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          UrbanPrimaryButton(label: 'Appliquer'.tr(context), onPressed: cubit.applyFilters),
        ],
      ),
    );
  }
}

class UrbanEmptySheet extends StatelessWidget {
  final UrbanRideCubit cubit;
  final VoidCallback onIntercity;
  final String? error;

  UrbanEmptySheet({super.key, required this.cubit, required this.onIntercity, this.error});

  @override
  Widget build(BuildContext context) {
    return UrbanBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.two_wheeler_outlined, size: 48, color: Color(0xFF9CA7A0)),
          const SizedBox(height: 12),
          Text(
            'Aucun mototaxi disponible'.tr(context),
            style: urbanText(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: urbanText(fontSize: 13, color: AppColors.error),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Élargissez le rayon ou modifiez la destination pour relancer la recherche.'.tr(context),
            textAlign: TextAlign.center,
            style: urbanText(fontSize: 15, color: AppColors.textSecondary, height: 1.35),
          ),
          const SizedBox(height: 18),
          UrbanPrimaryButton(label: 'Élargir le rayon'.tr(context), onPressed: cubit.widenRadius),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: cubit.openDestination,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            ),
            child: Text(
              'Modifier la destination'.tr(context),
              style: urbanText(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 8),
          UrbanTextLink(label: 'Réessayer'.tr(context), onTap: cubit.searchMototaxis),
          const SizedBox(height: 12),
          UrbanTextLink(label: 'Voir les trajets interurbains'.tr(context), onTap: onIntercity),
        ],
      ),
    );
  }
}

class UrbanDriverDetailSheet extends StatelessWidget {
  final UrbanRideState state;
  final UrbanRideCubit cubit;

  UrbanDriverDetailSheet({super.key, required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final driver = state.selectedDriver;
    if (driver == null) return const SizedBox.shrink();
    return UrbanBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (driver.profileIsDemo)
            UrbanDemoBanner(message: 'Fiche conducteur — données de démonstration'.tr(context)),
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: const Color(0xFFDDF5E6),
                child: Text(
                  driver.initials,
                  style: urbanText(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(driver.name, style: urbanText(fontSize: 22, fontWeight: FontWeight.w800)),
                    Text(
                      Localizations.localeOf(context).languageCode == 'en' ? '${driver.rating.toStringAsFixed(1)} · ${driver.tripCount} trips' : '${driver.rating.toStringAsFixed(1)} · ${driver.tripCount} courses',
                      style: urbanText(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              _AvailabilityBadge(available: driver.isAvailable),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.verified_outlined,
            label: driver.documentsVerified ? 'Documents vérifiés'.tr(context) : 'Documents en cours'.tr(context),
            trailing: driver.cniVerified ? 'CNI' : 'CNI — Démo'.tr(context),
          ),
          _InfoRow(
            icon: Icons.schedule_rounded,
            label: 'ETA',
            trailing: '${driver.etaMinutes} min',
          ),
          _InfoRow(
            icon: Icons.two_wheeler_rounded,
            label: driver.vehicleLabel,
            trailing: driver.plate,
          ),
          _InfoRow(
            icon: Icons.payments_outlined,
            label: 'Prix estimé'.tr(context),
            trailing: formatPriceF(driver.priceFcfa),
          ),
          const SizedBox(height: 16),
          UrbanPrimaryButton(label: 'Choisir ce mototaxi'.tr(context), onPressed: cubit.chooseSelectedDriver),
        ],
      ),
    );
  }
}

class UrbanConfirmSheet extends StatelessWidget {
  final UrbanRideState state;
  final UrbanRideCubit cubit;

  UrbanConfirmSheet({super.key, required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final driver = state.selectedDriver;
    return UrbanBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Confirmer la course'.tr(context), style: urbanText(fontSize: 22, fontWeight: FontWeight.w800)),
          if (state.hasTrafficBanner) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3C9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Trafic dense sur le trajet. Un itinéraire alternatif est disponible.'.tr(context),
                style: urbanText(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF8B6509),
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          _InfoRow(icon: Icons.trip_origin, label: state.originLabel.tr(context), trailing: ''),
          _InfoRow(icon: Icons.place_rounded, label: state.destinationLabel.tr(context), trailing: ''),
          if (driver != null)
            _InfoRow(
              icon: Icons.person_outline,
              label: driver.name,
              trailing: formatPriceF(state.selectedAmount),
            ),
          const SizedBox(height: 8),
          Text(
            'Intégration paiement/backend à venir'.tr(context),
            style: urbanText(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accent),
          ),
          const SizedBox(height: 16),
          UrbanPrimaryButton(label: 'Confirmer ma demande'.tr(context), onPressed: cubit.confirmRide),
        ],
      ),
    );
  }
}

class UrbanConfirmedSheet extends StatelessWidget {
  final UrbanRideCubit cubit;

  UrbanConfirmedSheet({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return UrbanBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Color(0xFFDDF5E6),
            child: Icon(Icons.check_rounded, color: AppColors.primary, size: 34),
          ),
          const SizedBox(height: 14),
          Text('Demande enregistrée'.tr(context), style: urbanText(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            'Intégration paiement/backend à venir. Aucun paiement n’a été débité.'.tr(context),
            textAlign: TextAlign.center,
            style: urbanText(fontSize: 14, color: AppColors.textSecondary, height: 1.35),
          ),
          const SizedBox(height: 18),
          UrbanPrimaryButton(label: 'Retour à l’accueil'.tr(context), onPressed: cubit.resetToHome),
        ],
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  final UrbanDriverCard driver;
  final bool selected;
  final VoidCallback onTap;

  const _DriverCard({required this.driver, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outline,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFDDF5E6),
              child: Text(
                driver.initials,
                style: urbanText(fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          driver.name,
                          style: urbanText(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (driver.profileIsDemo) ...[
                        const SizedBox(width: 6),
                        Text(
                          'Démo'.tr(context),
                          style: urbanText(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    Localizations.localeOf(context).languageCode == 'en'
                    ? '${driver.rating.toStringAsFixed(1)} · ${driver.vehicleLabel} · ${driver.etaMinutes} min · ${driver.isAvailable ? 'Available' : driver.availability}'
                    : '${driver.rating.toStringAsFixed(1)} · ${driver.vehicleLabel} · ${driver.etaMinutes} min · ${driver.isAvailable ? 'Disponible' : driver.availability}',
                    style: urbanText(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Text(
              formatPriceF(driver.priceFcfa),
              style: urbanText(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFFDDF5E6),
      labelStyle: urbanText(
        fontWeight: FontWeight.w800,
        color: selected ? AppColors.primary : AppColors.textPrimary,
      ),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  final bool available;
  _AvailabilityBadge({required this.available});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: available ? const Color(0xFFDDF5E6) : const Color(0xFFF1F2ED),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        available ? 'Disponible'.tr(context) : 'Occupé'.tr(context),
        style: urbanText(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: available ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String trailing;

  const _InfoRow({required this.icon, required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: urbanText(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
          if (trailing.isNotEmpty)
            Text(trailing, style: urbanText(fontSize: 14, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
