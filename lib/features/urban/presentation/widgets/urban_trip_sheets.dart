import 'package:flutter/material.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/intercity_formatters.dart';
import 'package:motodi_go_mobile/features/urban/presentation/urban_ride_cubit.dart';
import 'package:motodi_go_mobile/features/urban/presentation/urban_ride_state.dart';
import 'package:motodi_go_mobile/features/urban/presentation/widgets/urban_bottom_sheet.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';

class UrbanCalculatingSheet extends StatelessWidget {
  final UrbanRideState state;

  UrbanCalculatingSheet({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return UrbanBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 18),
          Text(
            "Calcul de l'itinéraire...".tr(context),
            style: urbanText(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            '${state.originLabel.tr(context)} → ${state.destinationLabel.tr(context)}',
            textAlign: TextAlign.center,
            style: urbanText(fontSize: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class UrbanTripSummarySheet extends StatelessWidget {
  final UrbanRideState state;
  final UrbanRideCubit cubit;

  UrbanTripSummarySheet({super.key, required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return UrbanBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.routeOptionsDemo) UrbanDemoBanner(),
          Row(
            children: [
              _StatCard(
                label: 'DISTANCE'.tr(context),
                value: '${state.selectedDistance.toStringAsFixed(1)} km',
              ),
              const SizedBox(width: 8),
              _StatCard(label: 'DURÉE'.tr(context), value: '${state.selectedDuration} min'),
              const SizedBox(width: 8),
              _StatCard(label: 'PRIX'.tr(context), value: formatPriceF(state.selectedAmount)),
            ],
          ),
          const SizedBox(height: 14),
          UrbanTextLink(label: 'Voir le détail du prix'.tr(context), onTap: cubit.openPriceDetail),
          const SizedBox(height: 8),
          UrbanTextLink(label: 'Comparer les itinéraires'.tr(context), onTap: () => cubit.openRouteOptions()),
          const SizedBox(height: 16),
          UrbanPrimaryButton(label: 'Rechercher un mototaxi'.tr(context), onPressed: cubit.searchMototaxis),
        ],
      ),
    );
  }
}

class UrbanPriceDetailSheet extends StatelessWidget {
  final UrbanRideState state;
  final UrbanRideCubit cubit;

  UrbanPriceDetailSheet({super.key, required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final breakdown = cubit.breakdownForSelection();
    return UrbanBottomSheet(
      maxHeight: MediaQuery.sizeOf(context).height * 0.72,
      child: ListView(
        shrinkWrap: true,
        children: [
          Text(
            'Détail du prix standardisé'.tr(context),
            style: urbanText(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Tarif réglementé, sans négociation. Le montant affiché est celui appliqué à la course.'.tr(context),
            style: urbanText(fontSize: 14, color: AppColors.textSecondary, height: 1.35),
          ),
          if (breakdown.isDemo)
            Padding(padding: const EdgeInsets.only(top: 12), child: UrbanDemoBanner()),
          const SizedBox(height: 16),
          _PriceLine(label: 'Base'.tr(context), value: formatPriceF(breakdown.base)),
          _PriceLine(
            label: Localizations.localeOf(context).languageCode == 'en'
                ? 'Distance (${breakdown.distanceKm.toStringAsFixed(1)} km × ${formatPriceF(breakdown.pricePerKm)})'
                : 'Distance (${breakdown.distanceKm.toStringAsFixed(1)} km × ${formatPriceF(breakdown.pricePerKm)})',
            value: formatPriceF(breakdown.distanceAmount),
          ),
          _PriceLine(
            label: 'Coefficient nuit'.tr(context),
            value: '× ${breakdown.nightCoefficient.toStringAsFixed(2)}',
          ),
          _PriceLine(
            label: 'Coefficient météo'.tr(context),
            value: '× ${breakdown.weatherCoefficient.toStringAsFixed(2)}',
          ),
          _PriceLine(label: 'Arrondi'.tr(context), value: formatPriceF(breakdown.rounding)),
          Divider(height: 28),
          _PriceLine(label: 'Total'.tr(context), value: formatPriceF(breakdown.total), emphasize: true),
          const SizedBox(height: 18),
          UrbanPrimaryButton(label: 'Rechercher un mototaxi'.tr(context), onPressed: cubit.searchMototaxis),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7F2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: urbanText(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF9CA7A0),
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 6),
            Text(value, style: urbanText(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _PriceLine({required this.label, required this.value, this.emphasize = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: urbanText(
                fontSize: emphasize ? 17 : 15,
                fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
                color: emphasize ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: urbanText(
              fontSize: emphasize ? 18 : 15,
              fontWeight: FontWeight.w800,
              color: emphasize ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
