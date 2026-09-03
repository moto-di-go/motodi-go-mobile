import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as ml;
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/widgets/profile_widgets.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_remote_datasource.dart';
import 'package:motodi_go_mobile/features/urban/presentation/driver_availability_cubit.dart';
import 'package:motodi_go_mobile/features/urban/presentation/urban_map_style.dart';
import 'package:motodi_go_mobile/features/urban/presentation/widgets/urban_bottom_sheet.dart';

class DriverAvailabilityPage extends StatelessWidget {
  const DriverAvailabilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DriverAvailabilityCubit(UrbanRemoteDataSource(getIt<ChopperClient>()))..bootstrap(),
      child: const _DriverAvailabilityView(),
    );
  }
}

class _DriverAvailabilityView extends StatelessWidget {
  const _DriverAvailabilityView();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SessionCubit, SessionState>(
          listenWhen: (previous, next) => previous.isAuthenticated && !next.isAuthenticated,
          listener: (context, _) {
            context.read<DriverAvailabilityCubit>().stopSharingOnLogout();
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<SessionCubit, SessionState>(
            builder: (context, session) {
              final profile = session.activeProfile;
              final type = profile?.type ?? ProfileType.mototaxi;
              final kyc = profile?.validationStatus ?? ValidationStatus.pending;
              final locked = kyc != ValidationStatus.validated;

              return BlocBuilder<DriverAvailabilityCubit, DriverAvailabilityState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      _DriverHeader(type: type, kyc: kyc, availability: state.availability),
                      Expanded(
                        child: locked
                            ? _LockedBody(kyc: kyc, type: type)
                            : _ActiveBody(state: state),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DriverHeader extends StatelessWidget {
  final ProfileType type;
  final ValidationStatus kyc;
  final String availability;

  _DriverHeader({required this.type, required this.kyc, required this.availability});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.canPop() ? context.pop() : context.go(RouteConstants.home),
                icon: const Icon(Icons.arrow_back_rounded),
                color: AppColors.textPrimary,
              ),
              Expanded(
                child: Text(
                  'Espace conducteur'.tr(context),
                  style: urbanText(fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF7F8F2), Color(0xFFEAF6EE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.outline),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(profileIcon(type), color: AppColors.primary, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Localizations.localeOf(context).languageCode == 'en'
                            ? '${profileLabel(type)} active'
                            : '${profileLabel(type)} actif',
                        style: urbanText(fontSize: 17, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _StatusPill(
                            label: 'KYC · ${compactStatusLabel(kyc)}',
                            color: statusColor(kyc),
                          ),
                          _AvailabilityPill(availability: availability),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedBody extends StatelessWidget {
  final ValidationStatus kyc;
  final ProfileType type;

  _LockedBody({required this.kyc, required this.type});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3C9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF3D77B)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profil non validé'.tr(context),
                style: urbanText(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                Localizations.localeOf(context).languageCode == 'en'
                    ? 'Your ${profileLabel(type)} profile must be validated (KYC · ${compactStatusLabel(kyc)}) before enabling availability and GPS sharing.'
                    : 'Votre profil ${profileLabel(type)} doit être validé (KYC · ${compactStatusLabel(kyc)}) avant d’activer la disponibilité et le partage GPS.',
                style: urbanText(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF8B6509),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              UrbanPrimaryButton(
                label: 'Voir mes documents'.tr(context),
                onPressed: () => context.push(RouteConstants.kycDocuments),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActiveBody extends StatefulWidget {
  final DriverAvailabilityState state;

  const _ActiveBody({required this.state});

  @override
  State<_ActiveBody> createState() => _ActiveBodyState();
}

class _ActiveBodyState extends State<_ActiveBody> with WidgetsBindingObserver {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<DriverAvailabilityCubit>().refreshHealth();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final cubit = context.read<DriverAvailabilityCubit>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _HealthRow(state: state),
        ),
        if (state.gpsDegraded || state.networkDegraded || state.error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: _DegradedBanners(state: state, cubit: cubit),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: state.isOnline
                ? _OnlinePanel(state: state, lastSentLabel: _lastSentLabel(state.lastSentAt))
                : _OfflinePanel(state: state),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: _BottomActions(state: state, cubit: cubit),
        ),
      ],
    );
  }

  String _lastSentLabel(DateTime? at) {
    if (at == null) return Localizations.localeOf(context).languageCode == 'en' ? 'Never sent' : 'Aucun envoi';
    final seconds = DateTime.now().difference(at).inSeconds.clamp(0, 9999);
    return Localizations.localeOf(context).languageCode == 'en' ? '${seconds}s ago' : 'il y a ${seconds}s';
  }
}

class _HealthRow extends StatelessWidget {
  final DriverAvailabilityState state;

  const _HealthRow({required this.state});

  @override
  Widget build(BuildContext context) {
    final battery = state.batteryLevel;
    return Row(
      children: [
        Expanded(
          child: _HealthChip(
            icon: Icons.gps_fixed_rounded,
            label: 'GPS',
            value: state.gpsOk && state.permission == DriverGpsPermission.granted
                ? 'OK'
                : state.permission == DriverGpsPermission.serviceDisabled
                ? 'OFF'
                : '—',
            ok: state.gpsOk && state.permission == DriverGpsPermission.granted,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _HealthChip(
            icon: Icons.wifi_rounded,
            label: 'Réseau'.tr(context),
            value: state.networkOk ? 'OK' : 'OFF',
            ok: state.networkOk,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _HealthChip(
            icon: Icons.battery_std_rounded,
            label: 'Batterie'.tr(context),
            value: battery == null ? '—' : '$battery%',
            ok: battery == null || !state.batteryLow,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _HealthChip(
            icon: Icons.send_rounded,
            label: 'Envoi'.tr(context),
            value: state.lastSentAt == null
                ? '—'
                : '${DateTime.now().difference(state.lastSentAt!).inSeconds.clamp(0, 999)}s',
            ok: state.sharing && state.lastSentAt != null,
          ),
        ),
      ],
    );
  }
}

class _HealthChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool ok;

  const _HealthChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.ok,
  });

  @override
  Widget build(BuildContext context) {
    final color = ok ? AppColors.primary : AppColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: urbanText(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
            ),
          ),
          Text(
            value,
            style: urbanText(fontSize: 13, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}

class _DegradedBanners extends StatelessWidget {
  final DriverAvailabilityState state;
  final DriverAvailabilityCubit cubit;

  _DegradedBanners({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (state.networkDegraded)
          _Banner(
            color: Color(0xFFFFF3C9),
            border: Color(0xFFF3D77B),
            textColor: Color(0xFF8B6509),
            message: 'Réseau dégradé — la position peut ne pas être envoyée.'.tr(context),
          ),
        if (state.gpsDegraded)
          Padding(
            padding: EdgeInsets.only(top: state.networkDegraded ? 8 : 0),
            child: _Banner(
              color: const Color(0xFFFFE8E8),
              border: const Color(0xFFF5B5B5),
              textColor: const Color(0xFF9B1C1C),
              message: state.permission == DriverGpsPermission.serviceDisabled
                  ? 'GPS désactivé — activez la localisation.'.tr(context)
                  : 'GPS dégradé — vérifiez la permission de localisation.'.tr(context),
              actionLabel: state.permission == DriverGpsPermission.permanentlyDenied
                  ? 'Réglages'.tr(context)
                  : state.permission == DriverGpsPermission.serviceDisabled
                  ? 'Activer GPS'.tr(context)
                  : null,
              onAction: state.permission == DriverGpsPermission.permanentlyDenied
                  ? cubit.openAppSettings
                  : state.permission == DriverGpsPermission.serviceDisabled
                  ? cubit.openLocationSettings
                  : null,
            ),
          ),
        if (state.error != null && !state.gpsDegraded && !state.networkDegraded)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _Banner(
              color: const Color(0xFFFFE8E8),
              border: const Color(0xFFF5B5B5),
              textColor: const Color(0xFF9B1C1C),
              message: state.error!,
              actionLabel: state.permission == DriverGpsPermission.permanentlyDenied
                  ? 'Ouvrir les réglages'.tr(context)
                  : state.permission == DriverGpsPermission.serviceDisabled
                  ? 'Activer le GPS'.tr(context)
                  : null,
              onAction: state.permission == DriverGpsPermission.permanentlyDenied
                  ? cubit.openAppSettings
                  : state.permission == DriverGpsPermission.serviceDisabled
                  ? cubit.openLocationSettings
                  : null,
            ),
          ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  final Color color;
  final Color border;
  final Color textColor;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _Banner({
    required this.color,
    required this.border,
    required this.textColor,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: urbanText(fontSize: 13, fontWeight: FontWeight.w700, color: textColor),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: urbanText(fontSize: 13, fontWeight: FontWeight.w800, color: textColor),
              ),
            ),
        ],
      ),
    );
  }
}

class _OfflinePanel extends StatelessWidget {
  final DriverAvailabilityState state;

  _OfflinePanel({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusPill(label: 'HORS LIGNE'.tr(context), color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            'Vous n’êtes pas visible des passagers'.tr(context),
            style: urbanText(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Passez disponible pour recevoir des courses. Le partage GPS démarre uniquement après votre consentement.'.tr(context),
            style: urbanText(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          if (state.error != null) ...[
            const SizedBox(height: 14),
            Text(
              state.error!,
              style: urbanText(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.error),
            ),
          ],
          const Spacer(),
          const Icon(Icons.visibility_off_outlined, size: 64, color: Color(0xFFDDE3DA)),
        ],
      ),
    );
  }
}

class _OnlinePanel extends StatelessWidget {
  final DriverAvailabilityState state;
  final String lastSentLabel;

  const _OnlinePanel({required this.state, required this.lastSentLabel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _AvailabilityPill(availability: state.availability),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Dernier envoi $lastSentLabel',
                style: urbanText(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        if (state.isOccupied) ...[
          const SizedBox(height: 12),
          _ActiveTripCard(trip: state.activeTrip),
        ],
        const SizedBox(height: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: _DriverMap(center: state.mapCenter, marker: state.lastPosition),
          ),
        ),
      ],
    );
  }
}

class _ActiveTripCard extends StatelessWidget {
  final DriverActiveTripStub? trip;

  const _ActiveTripCard({this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8D29A)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.two_wheeler_rounded, color: Color(0xFF8B6509)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Course en cours'.tr(context),
                  style: urbanText(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  trip == null
                      ? 'Trajet actif — détails à venir'.tr(context)
                      : '${trip!.passengerLabel} → ${trip!.destinationLabel}',
                  style: urbanText(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final DriverAvailabilityState state;
  final DriverAvailabilityCubit cubit;

  _BottomActions({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    if (state.isOnline) {
      return Column(
        children: [
          UrbanPrimaryButton(
            label: 'Passer hors ligne'.tr(context),
            isLoading: state.busy,
            onPressed: state.busy ? null : () => cubit.goOffline(),
          ),
        ],
      );
    }

    return Column(
      children: [
        if (state.permission == DriverGpsPermission.permanentlyDenied) ...[
          UrbanPrimaryButton(label: 'Ouvrir les réglages'.tr(context), onPressed: cubit.openAppSettings),
          const SizedBox(height: 10),
          UrbanTextLink(
            label: 'Réessayer après autorisation'.tr(context),
            onTap: () => _showGpsConsentSheet(context),
          ),
        ] else if (state.permission == DriverGpsPermission.serviceDisabled) ...[
          UrbanPrimaryButton(label: 'Activer le GPS'.tr(context), onPressed: cubit.openLocationSettings),
          const SizedBox(height: 10),
          UrbanTextLink(label: 'Réessayer'.tr(context), onTap: () => _showGpsConsentSheet(context)),
        ] else ...[
          UrbanPrimaryButton(
            label: 'Passer disponible'.tr(context),
            isLoading: state.busy,
            onPressed: state.busy ? null : () => _showGpsConsentSheet(context),
          ),
        ],
      ],
    );
  }
}

Future<void> _showGpsConsentSheet(BuildContext context) async {
  final cubit = context.read<DriverAvailabilityCubit>();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return UrbanBottomSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Consentement GPS'.tr(context), style: urbanText(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text(
              'Pour être visible des passagers, MOTO’DI GO doit accéder à votre position et l’envoyer toutes les 5 secondes tant que vous êtes disponible ou occupé.'.tr(context),
              style: urbanText(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            UrbanPrimaryButton(
              label: 'Autoriser et continuer'.tr(context),
              onPressed: () async {
                Navigator.of(sheetContext).pop();
                await cubit.activateWithConsent();
              },
            ),
            const SizedBox(height: 12),
            Center(
              child: UrbanTextLink(
                label: 'Refuser'.tr(context),
                color: AppColors.textSecondary,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await cubit.refuseGpsConsent();
                },
              ),
            ),
            SizedBox(height: MediaQuery.paddingOf(sheetContext).bottom),
          ],
        ),
      );
    },
  );
}

class _DriverMap extends StatefulWidget {
  final LatLng center;
  final LatLng? marker;

  const _DriverMap({required this.center, this.marker});

  @override
  State<_DriverMap> createState() => _DriverMapState();
}

class _DriverMapState extends State<_DriverMap> {
  ml.MapLibreMapController? _controller;
  bool _styleReady = false;
  LatLng? _lastCenter;
  String _markerKey = '';

  @override
  void didUpdateWidget(covariant _DriverMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncCamera();
    _syncMarker();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFE7EEE6),
      child: ml.MapLibreMap(
        styleString: UrbanMapStyle.url,
        initialCameraPosition: ml.CameraPosition(
          target: ml.LatLng(widget.center.latitude, widget.center.longitude),
          zoom: 15,
        ),
        compassEnabled: false,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
        myLocationEnabled: false,
        onMapCreated: (controller) {
          _controller = controller;
          _lastCenter = widget.center;
        },
        onStyleLoadedCallback: () async {
          _styleReady = true;
          await _syncMarker();
          await _syncCamera(force: true);
        },
      ),
    );
  }

  Future<void> _syncCamera({bool force = false}) async {
    final controller = _controller;
    if (controller == null || !_styleReady) return;
    if (!force && _lastCenter == widget.center) return;
    _lastCenter = widget.center;
    await controller.animateCamera(
      ml.CameraUpdate.newLatLngZoom(ml.LatLng(widget.center.latitude, widget.center.longitude), 15),
    );
  }

  Future<void> _syncMarker() async {
    final controller = _controller;
    if (controller == null || !_styleReady) return;
    final point = widget.marker ?? widget.center;
    final key = '${point.latitude},${point.longitude}';
    if (key == _markerKey) return;
    _markerKey = key;
    await controller.clearCircles();
    await controller.addCircle(
      ml.CircleOptions(
        geometry: ml.LatLng(point.latitude, point.longitude),
        circleRadius: 9,
        circleColor: _hex(AppColors.primary),
        circleStrokeColor: '#FFFFFF',
        circleStrokeWidth: 2.4,
      ),
    );
  }

  String _hex(Color color) {
    final value = color.toARGB32() & 0xFFFFFF;
    return '#${value.toRadixString(16).padLeft(6, '0')}';
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 4, backgroundColor: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: urbanText(fontSize: 12, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityPill extends StatelessWidget {
  final String availability;

  _AvailabilityPill({required this.availability});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (availability) {
      'AVAILABLE' => ('DISPONIBLE'.tr(context), AppColors.primary),
      'OCCUPIED' => ('OCCUPÉ'.tr(context), AppColors.secondary),
      _ => ('HORS LIGNE'.tr(context), AppColors.textTertiary),
    };
    return _StatusPill(label: label, color: color);
  }
}
