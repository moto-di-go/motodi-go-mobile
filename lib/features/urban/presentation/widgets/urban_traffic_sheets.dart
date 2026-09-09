import 'package:flutter/material.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_models.dart';
import 'package:motodi_go_mobile/features/urban/presentation/urban_ride_cubit.dart';
import 'package:motodi_go_mobile/features/urban/presentation/urban_ride_state.dart';
import 'package:motodi_go_mobile/features/urban/presentation/widgets/urban_bottom_sheet.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';

String _trFreshness(BuildContext context, String label) {
  final match = RegExp(r'^Mis à jour il y a (\d+) min$').firstMatch(label);
  if (match != null) {
    return 'Mis à jour il y a {minutes} min'.tr(
      context,
      placeholders: {'minutes': match.group(1)!},
    );
  }
  return label.tr(context);
}

class UrbanLayersSheet extends StatelessWidget {
  final UrbanRideState state;
  final UrbanRideCubit cubit;

  UrbanLayersSheet({super.key, required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final draft = state.draftLayerVisibility;
    return UrbanBottomSheet(
      maxHeight: MediaQuery.sizeOf(context).height * 0.72,
      child: ListView(
        shrinkWrap: true,
        children: [
          Text('Couches carte'.tr(context), style: urbanText(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            _trFreshness(context, state.layersFreshness),
            style: urbanText(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          _LayerToggle(
            label: 'Trafic dense'.tr(context),
            value: draft.congestion,
            onChanged: (value) => cubit.updateDraftLayers(draft.copyWith(congestion: value)),
          ),
          _LayerToggle(
            label: 'Travaux'.tr(context),
            value: draft.roadwork,
            onChanged: (value) => cubit.updateDraftLayers(draft.copyWith(roadwork: value)),
          ),
          _LayerToggle(
            label: 'Routes dégradées'.tr(context),
            value: draft.damagedRoad,
            onChanged: (value) => cubit.updateDraftLayers(draft.copyWith(damagedRoad: value)),
          ),
          _LayerToggle(
            label: 'Routes alternatives'.tr(context),
            value: draft.alternative,
            onChanged: (value) => cubit.updateDraftLayers(draft.copyWith(alternative: value)),
          ),
          _LayerToggle(
            label: 'Zones à éviter'.tr(context),
            value: draft.avoidZones,
            onChanged: (value) => cubit.updateDraftLayers(draft.copyWith(avoidZones: value)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: cubit.resetDraftLayers,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: Text('Réinitialiser'.tr(context), style: urbanText(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: UrbanPrimaryButton(label: 'Appliquer'.tr(context), onPressed: cubit.applyLayers),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UrbanLegendCard extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;

  UrbanLegendCard({super.key, required this.expanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Légende'.tr(context), style: urbanText(fontSize: 13, fontWeight: FontWeight.w800)),
                  Icon(expanded ? Icons.expand_less : Icons.expand_more, size: 18),
                ],
              ),
              if (expanded) ...[
                const SizedBox(height: 8),
                _LegendRow(color: Color(0xFFF59E0B), label: 'Congestion'.tr(context)),
                _LegendRow(color: Color(0xFFEF4444), label: 'Bloquée / dégradée'.tr(context)),
                _LegendRow(color: Color(0xFF3B82F6), label: 'Alternative'.tr(context)),
                _LegendRow(color: Color(0xFF9CA3AF), label: 'Données anciennes'.tr(context)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class UrbanIncidentSheet extends StatelessWidget {
  final UrbanRideState state;
  final UrbanRideCubit cubit;

  const UrbanIncidentSheet({super.key, required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final layer = state.selectedIncident;
    if (layer == null) return const SizedBox.shrink();
    return UrbanBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(layer.label, style: urbanText(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _SoftChip(label: layer.severity),
              _SoftChip(label: layer.type),
            ],
          ),
          const SizedBox(height: 12),
          Text(_trFreshness(context, layer.freshnessLabel()), style: urbanText(color: AppColors.textSecondary)),
          if (layer.impact != null && layer.impact!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(layer.impact!, style: urbanText(fontSize: 15)),
          ],
          const SizedBox(height: 16),
          UrbanPrimaryButton(
            label: "Voir l'itinéraire alternatif".tr(context),
            onPressed: cubit.seeAlternativeFromIncident,
          ),
        ],
      ),
    );
  }
}

class UrbanCompareSheet extends StatelessWidget {
  final UrbanRideState state;
  final UrbanRideCubit cubit;

  const UrbanCompareSheet({super.key, required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final main = state.routeOptions.cast<RouteOption?>().firstWhere(
      (option) => option?.kind == RouteOptionKind.recommended,
      orElse: () => state.routeOptions.isEmpty ? null : state.routeOptions.first,
    );
    final alt = state.routeOptions.cast<RouteOption?>().firstWhere(
      (option) => option?.kind == RouteOptionKind.fastest,
      orElse: () => state.routeOptions.length > 1 ? state.routeOptions[1] : null,
    );
    return UrbanBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.routeOptionsDemo) UrbanDemoBanner(),
          if (state.hasTrafficBanner)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3C9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Trafic ou voie dégradée sur l’itinéraire principal.'.tr(context),
                style: urbanText(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF8B6509),
                ),
              ),
            ),
          Row(
            children: [
              if (main != null)
                Expanded(
                  child: _CompareCard(title: 'Principal'.tr(context), option: main),
                ),
              if (main != null && alt != null) const SizedBox(width: 8),
              if (alt != null)
                Expanded(
                  child: _CompareCard(title: 'Alternative'.tr(context), option: alt),
                ),
            ],
          ),
          const SizedBox(height: 14),
          UrbanPrimaryButton(
            label: 'Voir les options'.tr(context),
            onPressed: () => cubit.openRouteOptions(from: UrbanRideStep.compareRoutes),
          ),
        ],
      ),
    );
  }
}

class UrbanRouteOptionsSheet extends StatelessWidget {
  final UrbanRideState state;
  final UrbanRideCubit cubit;

  UrbanRouteOptionsSheet({super.key, required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return UrbanBottomSheet(
      maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      child: ListView(
        shrinkWrap: true,
        children: [
          Text(
            'Choisir un itinéraire'.tr(context),
            style: urbanText(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          if (state.routeOptionsDemo)
            Padding(padding: const EdgeInsets.only(top: 12), child: UrbanDemoBanner()),
          const SizedBox(height: 12),
          for (final option in state.routeOptions) ...[
            _RouteOptionCard(
              option: option,
              selected: option.kind == state.selectedKind,
              onTap: () => cubit.selectRouteOption(option.kind),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _LayerToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _LayerToggle({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: urbanText(fontSize: 16, fontWeight: FontWeight.w700)),
      value: value,
      activeThumbColor: AppColors.primary,
      onChanged: onChanged,
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendRow({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 4,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 8),
          Text(label, style: urbanText(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SoftChip extends StatelessWidget {
  final String label;
  const _SoftChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2ED),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: urbanText(fontSize: 12, fontWeight: FontWeight.w800)),
    );
  }
}

class _CompareCard extends StatelessWidget {
  final String title;
  final RouteOption option;

  const _CompareCard({required this.title, required this.option});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: urbanText(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${option.durationMinutes} min',
            style: urbanText(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          Text(
            '${option.distanceKm.toStringAsFixed(1)} km',
            style: urbanText(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _RouteOptionCard extends StatelessWidget {
  final RouteOption option;
  final bool selected;
  final VoidCallback onTap;

  const _RouteOptionCard({required this.option, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final recommended = option.kind == RouteOptionKind.recommended;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: recommended || selected ? AppColors.primary : AppColors.outline,
            width: recommended || selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    option.label,
                    style: urbanText(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                if (recommended)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDF5E6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Conseillé'.tr(context),
                      style: urbanText(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                if (option.degraded) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3C9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Dégradée'.tr(context),
                      style: urbanText(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF8B6509),
                      ),
                    ),
                  ),
                ],
                if (option.isDemo) ...[
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
            const SizedBox(height: 8),
            Text(
              '${option.durationMinutes} min · ${option.distanceKm.toStringAsFixed(1)} km · ${option.amountFcfa.round()} F',
              style: urbanText(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            UrbanPrimaryButton(label: 'Choisir cet itinéraire'.tr(context), onPressed: onTap),
          ],
        ),
      ),
    );
  }
}
