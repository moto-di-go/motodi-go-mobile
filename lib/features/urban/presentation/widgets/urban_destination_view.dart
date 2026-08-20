import 'package:flutter/material.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_geo.dart';
import 'package:motodi_go_mobile/features/urban/presentation/urban_ride_cubit.dart';
import 'package:motodi_go_mobile/features/urban/presentation/urban_ride_state.dart';
import 'package:motodi_go_mobile/features/urban/presentation/widgets/urban_bottom_sheet.dart';

class UrbanDestinationView extends StatefulWidget {
  final UrbanRideState state;
  final UrbanRideCubit cubit;

  const UrbanDestinationView({super.key, required this.state, required this.cubit});

  @override
  State<UrbanDestinationView> createState() => _UrbanDestinationViewState();
}

class _UrbanDestinationViewState extends State<UrbanDestinationView> {
  late final TextEditingController _controller;

  UrbanRideState get state => widget.state;
  UrbanRideCubit get cubit => widget.cubit;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.destinationQuery);
  }

  @override
  void didUpdateWidget(covariant UrbanDestinationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.destinationQuery != widget.state.destinationQuery &&
        _controller.text != widget.state.destinationQuery) {
      _controller.text = widget.state.destinationQuery;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final origin = state.origin ?? state.userPosition ?? kYaoundeCenter;
    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: cubit.back,
                    icon: const Icon(Icons.arrow_back_rounded, size: 26),
                  ),
                  Text(
                    'Destination',
                    style: urbanText(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const _Dot(color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.originLabel,
                            style: urbanText(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 6, top: 6, bottom: 6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          height: 18,
                          child: VerticalDivider(color: Color(0xFFDDE3DA), thickness: 2),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.place_rounded, color: AppColors.error, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            onChanged: cubit.updateDestinationQuery,
                            decoration: InputDecoration(
                              hintText: 'Où allez-vous ?',
                              hintStyle: urbanText(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textTertiary,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: urbanText(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (state.destinationQuery.isNotEmpty)
                          IconButton(
                            onPressed: cubit.clearDestinationQuery,
                            icon: const Icon(Icons.close_rounded, size: 20),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (state.history.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: state.history.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final entry = state.history[index];
                    return ActionChip(
                      avatar: const Icon(Icons.schedule_rounded, size: 16, color: AppColors.textSecondary),
                      label: Text(entry.label, style: urbanText(fontSize: 13, fontWeight: FontWeight.w700)),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.outline),
                      onPressed: () => cubit.selectHistory(entry),
                    );
                  },
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
              child: Row(
                children: [
                  Text(
                    state.destinationQuery.trim().isEmpty ? 'QUARTIERS POPULAIRES' : 'RÉSULTATS',
                    style: urbanText(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF9CA7A0),
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (state.visiblePlacesDemo) ...[
                    const SizedBox(width: 8),
                    Text('Démo', style: urbanText(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.accent)),
                  ],
                ],
              ),
            ),
            if (state.visiblePlacesDemo)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: UrbanDemoBanner(message: 'Quartiers Yaoundé — données de démonstration'),
              ),
            Expanded(
              child: state.geocoding && state.visiblePlaces.isEmpty
                  ? ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      itemCount: 3,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) => const _PlaceSkeleton(),
                    )
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                itemCount: state.visiblePlaces.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final place = state.visiblePlaces[index];
                  final km = place.distanceKm ?? haversineKm(origin, place.point);
                  final minutes = estimateUrbanMinutes(km);
                  final subtitle = place.subtitle?.trim().isNotEmpty == true
                      ? '${place.subtitle} · ${km.toStringAsFixed(1)} km'
                      : '${km.toStringAsFixed(1)} km · ~$minutes min';
                  return ListTile(
                    onTap: () => cubit.selectPopularPlace(place),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    tileColor: Colors.white,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFEFFAF3),
                      child: Icon(Icons.location_on_outlined, color: AppColors.primary),
                    ),
                    title: Text(place.label, style: urbanText(fontSize: 16, fontWeight: FontWeight.w800)),
                    subtitle: Text(
                      subtitle,
                      style: urbanText(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA7A0)),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: UrbanPrimaryButton(
                label: 'Choisir sur la carte',
                onPressed: cubit.startPickDestination,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _PlaceSkeleton extends StatelessWidget {
  const _PlaceSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: Color(0xFFE8EDE8), shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 12, width: 160, color: const Color(0xFFE8EDE8)),
                const SizedBox(height: 8),
                Container(height: 10, width: 110, color: const Color(0xFFF1F4F1)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
