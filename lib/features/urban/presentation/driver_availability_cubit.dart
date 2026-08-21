import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:motodi_go_mobile/features/auth/data/models/api_error_model.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_geo.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_remote_datasource.dart';

enum DriverGpsPermission { unknown, granted, denied, permanentlyDenied, serviceDisabled }

class DriverActiveTripStub extends Equatable {
  final String id;
  final String passengerLabel;
  final String destinationLabel;

  const DriverActiveTripStub({
    required this.id,
    required this.passengerLabel,
    required this.destinationLabel,
  });

  @override
  List<Object?> get props => [id, passengerLabel, destinationLabel];
}

class DriverAvailabilityState extends Equatable {
  final String availability;
  final bool gpsConsent;
  final bool sharing;
  final bool gpsOk;
  final bool networkOk;
  final int? batteryLevel;
  final bool batteryLow;
  final DriverGpsPermission permission;
  final bool locationServiceEnabled;
  final bool busy;
  final String? error;
  final String? errorCode;
  final DateTime? lastSentAt;
  final LatLng? lastPosition;
  final DriverActiveTripStub? activeTrip;

  const DriverAvailabilityState({
    this.availability = 'OFFLINE',
    this.gpsConsent = false,
    this.sharing = false,
    this.gpsOk = false,
    this.networkOk = true,
    this.batteryLevel,
    this.batteryLow = false,
    this.permission = DriverGpsPermission.unknown,
    this.locationServiceEnabled = true,
    this.busy = false,
    this.error,
    this.errorCode,
    this.lastSentAt,
    this.lastPosition,
    this.activeTrip,
  });

  bool get isOffline => availability == 'OFFLINE';
  bool get isAvailable => availability == 'AVAILABLE';
  bool get isOccupied => availability == 'OCCUPIED';
  bool get isOnline => isAvailable || isOccupied;
  bool get gpsDegraded => isOnline && (!gpsOk || permission != DriverGpsPermission.granted);
  bool get networkDegraded => isOnline && !networkOk;

  LatLng get mapCenter => lastPosition ?? kYaoundeCenter;

  DriverAvailabilityState copyWith({
    String? availability,
    bool? gpsConsent,
    bool? sharing,
    bool? gpsOk,
    bool? networkOk,
    Object? batteryLevel = _unset,
    bool? batteryLow,
    DriverGpsPermission? permission,
    bool? locationServiceEnabled,
    bool? busy,
    Object? error = _unset,
    Object? errorCode = _unset,
    Object? lastSentAt = _unset,
    Object? lastPosition = _unset,
    Object? activeTrip = _unset,
  }) {
    return DriverAvailabilityState(
      availability: availability ?? this.availability,
      gpsConsent: gpsConsent ?? this.gpsConsent,
      sharing: sharing ?? this.sharing,
      gpsOk: gpsOk ?? this.gpsOk,
      networkOk: networkOk ?? this.networkOk,
      batteryLevel: identical(batteryLevel, _unset) ? this.batteryLevel : batteryLevel as int?,
      batteryLow: batteryLow ?? this.batteryLow,
      permission: permission ?? this.permission,
      locationServiceEnabled: locationServiceEnabled ?? this.locationServiceEnabled,
      busy: busy ?? this.busy,
      error: identical(error, _unset) ? this.error : error as String?,
      errorCode: identical(errorCode, _unset) ? this.errorCode : errorCode as String?,
      lastSentAt: identical(lastSentAt, _unset) ? this.lastSentAt : lastSentAt as DateTime?,
      lastPosition: identical(lastPosition, _unset) ? this.lastPosition : lastPosition as LatLng?,
      activeTrip: identical(activeTrip, _unset)
          ? this.activeTrip
          : activeTrip as DriverActiveTripStub?,
    );
  }

  @override
  List<Object?> get props => [
    availability,
    gpsConsent,
    sharing,
    gpsOk,
    networkOk,
    batteryLevel,
    batteryLow,
    permission,
    locationServiceEnabled,
    busy,
    error,
    errorCode,
    lastSentAt,
    lastPosition,
    activeTrip,
  ];
}

const Object _unset = Object();

class DriverAvailabilityCubit extends Cubit<DriverAvailabilityState> {
  final UrbanRemoteDataSource _remote;
  final Battery _battery;
  final Connectivity _connectivity;

  Timer? _timer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  StreamSubscription<BatteryState>? _batterySub;

  DriverAvailabilityCubit(this._remote, {Battery? battery, Connectivity? connectivity})
    : _battery = battery ?? Battery(),
      _connectivity = connectivity ?? Connectivity(),
      super(const DriverAvailabilityState());

  Future<void> bootstrap() async {
    await refreshHealth();
    _connectivitySub?.cancel();
    _connectivitySub = _connectivity.onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      emit(state.copyWith(networkOk: online));
    });
    try {
      _batterySub?.cancel();
      _batterySub = _battery.onBatteryStateChanged.listen((_) => unawaited(_refreshBattery()));
    } catch (_) {
      // Platform may not support battery stream.
    }
  }

  Future<void> refreshHealth() async {
    await Future.wait([_refreshNetwork(), _refreshBattery(), refreshPermissionStatus()]);
  }

  Future<DriverGpsPermission> refreshPermissionStatus() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(
        state.copyWith(
          locationServiceEnabled: false,
          permission: DriverGpsPermission.serviceDisabled,
          gpsOk: false,
        ),
      );
      return DriverGpsPermission.serviceDisabled;
    }

    final permission = await Geolocator.checkPermission();
    final mapped = _mapPermission(permission);
    emit(
      state.copyWith(
        locationServiceEnabled: true,
        permission: mapped,
        gpsOk: mapped == DriverGpsPermission.granted,
      ),
    );
    return mapped;
  }

  /// After consent sheet: verify GPS service + permission, then go AVAILABLE.
  Future<void> activateWithConsent() async {
    if (state.busy) return;
    emit(state.copyWith(busy: true, error: null, errorCode: null, gpsConsent: true));

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(
        state.copyWith(
          busy: false,
          locationServiceEnabled: false,
          permission: DriverGpsPermission.serviceDisabled,
          gpsOk: false,
          error: 'Le GPS est désactivé. Activez la localisation pour passer disponible.',
        ),
      );
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    final mapped = _mapPermission(permission);
    emit(
      state.copyWith(
        locationServiceEnabled: true,
        permission: mapped,
        gpsOk: mapped == DriverGpsPermission.granted,
      ),
    );

    if (mapped == DriverGpsPermission.denied) {
      emit(
        state.copyWith(
          busy: false,
          error: 'Permission GPS refusée. Autorisez la localisation pour être visible.',
        ),
      );
      return;
    }
    if (mapped == DriverGpsPermission.permanentlyDenied) {
      emit(
        state.copyWith(
          busy: false,
          error: 'Permission GPS définitivement refusée. Ouvrez les réglages pour l’autoriser.',
        ),
      );
      return;
    }

    await _setAvailabilityInternal('AVAILABLE', gpsConsent: true, startSharing: true);
  }

  Future<void> refuseGpsConsent() async {
    await stopSharing(reason: 'Consentement GPS refusé. Diffusion arrêtée.');
    emit(
      state.copyWith(
        gpsConsent: false,
        availability: 'OFFLINE',
        sharing: false,
        error: 'Sans consentement GPS, vous n’êtes pas visible des passagers.',
        errorCode: null,
      ),
    );
  }

  Future<void> goOffline() async {
    await _setAvailabilityInternal('OFFLINE', gpsConsent: state.gpsConsent, startSharing: false);
  }

  Future<void> setOccupiedStub() async {
    await _setAvailabilityInternal(
      'OCCUPIED',
      gpsConsent: true,
      startSharing: true,
      activeTrip: const DriverActiveTripStub(
        id: 'stub-trip',
        passengerLabel: 'Passager',
        destinationLabel: 'Destination en cours',
      ),
    );
  }

  Future<void> stopSharingOnLogout() async {
    _timer?.cancel();
    _timer = null;
    if (state.isOnline || state.sharing) {
      try {
        await _remote.updateAvailability(availability: 'OFFLINE', gpsConsent: false);
      } catch (_) {
        // Best-effort on logout.
      }
    }
    emit(const DriverAvailabilityState(availability: 'OFFLINE', gpsConsent: false, sharing: false));
  }

  Future<void> stopSharing({String? reason}) async {
    _timer?.cancel();
    _timer = null;
    emit(
      state.copyWith(
        sharing: false,
        error: reason,
        errorCode: reason == null ? null : state.errorCode,
      ),
    );
  }

  Future<void> openAppSettings() => Geolocator.openAppSettings();

  Future<void> openLocationSettings() => Geolocator.openLocationSettings();

  Future<void> _setAvailabilityInternal(
    String availability, {
    required bool gpsConsent,
    required bool startSharing,
    DriverActiveTripStub? activeTrip,
  }) async {
    try {
      await _remote.updateAvailability(availability: availability, gpsConsent: gpsConsent);
      final sharing =
          startSharing && gpsConsent && (availability == 'AVAILABLE' || availability == 'OCCUPIED');
      emit(
        state.copyWith(
          availability: availability,
          gpsConsent: gpsConsent,
          sharing: sharing,
          busy: false,
          error: null,
          errorCode: null,
          activeTrip: availability == 'OCCUPIED' ? (activeTrip ?? state.activeTrip) : null,
        ),
      );
      if (sharing) {
        await _startSharing();
      } else {
        _timer?.cancel();
        _timer = null;
      }
    } catch (error) {
      await _handleRemoteError(error, forceOffline: true);
    }
  }

  Future<void> _startSharing() async {
    final permission = await refreshPermissionStatus();
    if (permission != DriverGpsPermission.granted) {
      emit(
        state.copyWith(
          sharing: false,
          gpsOk: false,
          busy: false,
          error: 'Permission GPS insuffisante. Diffusion arrêtée.',
        ),
      );
      return;
    }
    emit(state.copyWith(gpsOk: true, sharing: true, busy: false, error: null, errorCode: null));
    await _sendOnce();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => unawaited(_sendOnce()));
  }

  Future<void> _sendOnce() async {
    if (!state.sharing) return;
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      await _remote.publishPosition(
        lat: position.latitude,
        lon: position.longitude,
        speedKmh: position.speed * 3.6,
        accuracyMeters: position.accuracy,
      );
      emit(
        state.copyWith(
          lastSentAt: DateTime.now(),
          lastPosition: LatLng(position.latitude, position.longitude),
          gpsOk: true,
          error: null,
          errorCode: null,
        ),
      );
    } catch (error) {
      await _handleRemoteError(error, forceOffline: false);
    }
  }

  Future<void> _handleRemoteError(Object error, {required bool forceOffline}) async {
    if (error is ApiException && error.code == 'DRIVER_NOT_ALLOWED') {
      _timer?.cancel();
      _timer = null;
      try {
        await _remote.updateAvailability(availability: 'OFFLINE', gpsConsent: false);
      } catch (_) {}
      emit(
        state.copyWith(
          availability: 'OFFLINE',
          sharing: false,
          gpsConsent: false,
          busy: false,
          activeTrip: null,
          error: error.message,
          errorCode: error.code,
        ),
      );
      return;
    }

    final message = error is ApiException ? error.message : error.toString();
    if (forceOffline) {
      _timer?.cancel();
      _timer = null;
      emit(
        state.copyWith(
          busy: false,
          sharing: false,
          availability: 'OFFLINE',
          error: message,
          errorCode: error is ApiException ? error.code : null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        gpsOk: false,
        error: message,
        errorCode: error is ApiException ? error.code : null,
      ),
    );
  }

  Future<void> _refreshNetwork() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final online = results.any((r) => r != ConnectivityResult.none);
      emit(state.copyWith(networkOk: online));
    } catch (_) {
      emit(state.copyWith(networkOk: true));
    }
  }

  Future<void> _refreshBattery() async {
    try {
      final level = await _battery.batteryLevel;
      emit(
        state.copyWith(
          batteryLevel: level < 0 ? null : level,
          batteryLow: level >= 0 && level <= 15,
        ),
      );
    } catch (_) {
      emit(state.copyWith(batteryLevel: null, batteryLow: false));
    }
  }

  DriverGpsPermission _mapPermission(LocationPermission permission) {
    return switch (permission) {
      LocationPermission.always || LocationPermission.whileInUse => DriverGpsPermission.granted,
      LocationPermission.deniedForever => DriverGpsPermission.permanentlyDenied,
      LocationPermission.denied => DriverGpsPermission.denied,
      LocationPermission.unableToDetermine => DriverGpsPermission.unknown,
    };
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _connectivitySub?.cancel();
    _batterySub?.cancel();
    return super.close();
  }
}
