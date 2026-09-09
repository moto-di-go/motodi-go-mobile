import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motodi_go_mobile/core/widgets/guest_action_blocker.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_buttons.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/cubit/profile_cubit.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/widgets/profile_widgets.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_destination_history_store.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_location_source.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_models.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_remote_datasource.dart';
import 'package:motodi_go_mobile/features/urban/presentation/urban_ride_cubit.dart';
import 'package:motodi_go_mobile/features/urban/presentation/urban_ride_state.dart';
import 'package:motodi_go_mobile/features/urban/presentation/widgets/urban_bottom_sheet.dart';
import 'package:motodi_go_mobile/features/urban/presentation/widgets/urban_destination_view.dart';
import 'package:motodi_go_mobile/features/urban/presentation/widgets/urban_driver_sheets.dart';
import 'package:motodi_go_mobile/features/urban/presentation/widgets/urban_traffic_sheets.dart';
import 'package:motodi_go_mobile/features/urban/presentation/widgets/urban_trip_sheets.dart';
import 'package:motodi_go_mobile/features/urban/presentation/widgets/urban_vector_map.dart';
import 'package:motodi_go_mobile/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UrbanRidePage extends StatelessWidget {
  const UrbanRidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UrbanRideCubit(
        remote: UrbanRemoteDataSource(getIt<ChopperClient>()),
        history: UrbanDestinationHistoryStore(getIt<SharedPreferences>()),
        location: GeolocatorLocationSource(),
      )..bootstrap(),
      child: const _UrbanRideView(),
    );
  }
}

class _UrbanRideView extends StatefulWidget {
  const _UrbanRideView();

  @override
  State<_UrbanRideView> createState() => _UrbanRideViewState();
}

class _UrbanRideViewState extends State<_UrbanRideView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UrbanRideCubit, UrbanRideState>(
      builder: (context, state) {
        final cubit = context.read<UrbanRideCubit>();
        if (state.step == UrbanRideStep.destination) {
          return UrbanDestinationView(state: state, cubit: cubit);
        }
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              Positioned.fill(
                child: UrbanVectorMap(state: state, cubit: cubit),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: _HomeHeader(
                    state: state,
                    onMenu: () {
                      if (!guardGuestAction(context)) return;
                      _showMenu(context);
                    },
                    onBack: cubit.back,
                    onProfile: () {
                      if (!guardGuestAction(context)) return;
                      _showProfileSwitcher(context);
                    },
                  ),
                ),
              ),
              if (state.step == UrbanRideStep.home)
                SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 78, 16, 0),
                      child: _SearchPill(onTap: cubit.openDestination),
                    ),
                  ),
                ),
              if (state.step == UrbanRideStep.pickDestination)
                SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 78, 16, 0),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Text(
                            'Touchez la carte pour poser la destination'.tr(context),
                            style: urbanText(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: 16,
                bottom: _sheetOpen(state) ? 360 : 118,
                child: Column(
                  children: [
                    _MapFab(icon: Icons.my_location_rounded, onTap: cubit.recenter),
                    const SizedBox(height: 10),
                    _MapFab(icon: Icons.layers_outlined, onTap: cubit.openLayers),
                  ],
                ),
              ),
              if (state.layerVisibility.congestion ||
                  state.layerVisibility.roadwork ||
                  state.layerVisibility.damagedRoad ||
                  state.layerVisibility.alternative ||
                  state.layerVisibility.avoidZones)
                Positioned(
                  left: 16,
                  bottom: _sheetOpen(state) ? 360 : 118,
                  child: UrbanLegendCard(
                    expanded: state.legendExpanded,
                    onToggle: cubit.toggleLegend,
                  ),
                ),
              if (state.locationError != null && state.step == UrbanRideStep.home)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24,
                  child: Material(
                    color: const Color(0xFFFFF3C9),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        state.locationError!.tr(context),
                        style: urbanText(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF8B6509),
                        ),
                      ),
                    ),
                  ),
                ),
              if (_sheetOpen(state))
                Align(alignment: Alignment.bottomCenter, child: _stepSheet(context, state, cubit)),
            ],
          ),
        );
      },
    );
  }

  bool _sheetOpen(UrbanRideState state) {
    return switch (state.step) {
      UrbanRideStep.home || UrbanRideStep.destination => false,
      _ => true,
    };
  }

  Widget _stepSheet(BuildContext context, UrbanRideState state, UrbanRideCubit cubit) {
    return switch (state.step) {
      UrbanRideStep.calculating => UrbanCalculatingSheet(state: state),
      UrbanRideStep.tripSummary => UrbanTripSummarySheet(state: state, cubit: cubit),
      UrbanRideStep.priceDetail => UrbanPriceDetailSheet(state: state, cubit: cubit),
      UrbanRideStep.searching => UrbanSearchingSheet(),
      UrbanRideStep.results => UrbanResultsSheet(state: state, cubit: cubit),
      UrbanRideStep.filters => UrbanFiltersSheet(state: state, cubit: cubit),
      UrbanRideStep.empty => UrbanEmptySheet(
        cubit: cubit,
        error: state.apiError?.tr(context),
        onIntercity: () => context.go(RouteConstants.intercity),
      ),
      UrbanRideStep.driverDetail => UrbanDriverDetailSheet(state: state, cubit: cubit),
      UrbanRideStep.confirm => UrbanConfirmSheet(state: state, cubit: cubit),
      UrbanRideStep.confirmed => UrbanConfirmedSheet(cubit: cubit),
      UrbanRideStep.layers => UrbanLayersSheet(state: state, cubit: cubit),
      UrbanRideStep.incident => UrbanIncidentSheet(state: state, cubit: cubit),
      UrbanRideStep.compareRoutes => UrbanCompareSheet(state: state, cubit: cubit),
      UrbanRideStep.routeOptions => UrbanRouteOptionsSheet(state: state, cubit: cubit),
      UrbanRideStep.pickDestination => UrbanBottomSheet(
        child: UrbanPrimaryButton(
          label: 'Valider cette destination'.tr(context),
          onPressed: state.destination == null ? null : () {
            if (!guardGuestAction(context)) return;
            cubit.confirmPickedDestination();
          },
        ),
      ),
      _ => const SizedBox.shrink(),
    };
  }

  void _showMenu(BuildContext context) {
    final session = context.read<SessionCubit>().state;
    final hasDriver =
        session.session?.profiles.any(
          (profile) =>
              profile.type == ProfileType.mototaxi ||
              profile.type == ProfileType.transporter ||
              profile.type == ProfileType.agency,
        ) ??
        false;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return UrbanBottomSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.swap_horiz_rounded),
                title: Text(
                  'Changer de profil'.tr(context),
                  style: urbanText(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showProfileSwitcher(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline_rounded),
                title: Text(
                  'Mon profil'.tr(context),
                  style: urbanText(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.go(RouteConstants.profile);
                },
              ),
              if (hasDriver)
                ListTile(
                  leading: const Icon(Icons.two_wheeler_rounded),
                  title: Text(
                    'Disponibilité conducteur'.tr(context),
                    style: urbanText(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.push(RouteConstants.driverAvailability);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                title: Text(
                  'Se déconnecter'.tr(context),
                  style: urbanText(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.error,
                  ),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showLogoutSheet(context);
                },
              ),
            ],
          ),
        );
      },
    );
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
              return UrbanBottomSheet(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.profileSwitcherTitle,
                      style: urbanText(fontSize: 26, fontWeight: FontWeight.w800),
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

  void _showLogoutSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return UrbanBottomSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Se déconnecter ?'.tr(context),
                style: urbanText(fontSize: 24, fontWeight: FontWeight.w800),
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
}

class _HomeHeader extends StatelessWidget {
  final UrbanRideState state;
  final VoidCallback onMenu;
  final VoidCallback onBack;
  final VoidCallback onProfile;

  const _HomeHeader({
    required this.state,
    required this.onMenu,
    required this.onBack,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    final type = context.watch<SessionCubit>().state.activeProfile?.type ?? ProfileType.passenger;
    final showBack = state.step != UrbanRideStep.home;
    return Row(
      children: [
        _RoundIcon(
          icon: showBack ? Icons.arrow_back_rounded : Icons.menu_rounded,
          onTap: showBack ? onBack : onMenu,
        ),
        const Spacer(),
        GestureDetector(
          onTap: onProfile,
          child: CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFDFF5E8),
            child: ProfileTypeIcon(type: type, color: AppColors.primary, size: 22),
          ),
        ),
      ],
    );
  }
}

class _SearchPill extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [BoxShadow(color: Color(0x1A101512), blurRadius: 16)],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Text(
              'Où allez-vous ?'.tr(context),
              style: urbanText(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapFab({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 48, height: 48, child: Icon(icon, color: AppColors.textPrimary)),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 48, height: 48, child: Icon(icon, color: AppColors.textPrimary)),
      ),
    );
  }
}
