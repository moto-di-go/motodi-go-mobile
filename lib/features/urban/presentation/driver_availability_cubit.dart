import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_remote_datasource.dart';

class DriverAvailabilityState extends Equatable {
  final String availability;
  final bool gpsConsent;
  final bool sharing;
  final bool gpsOk;
  final String? error;
  final DateTime? lastSentAt;

  const DriverAvailabilityState({
    this.availability = 'OFFLINE',
    this.gpsConsent = false,
    this.sharing = false,
    this.gpsOk = false,
    this.error,
    this.lastSentAt,
  });

  DriverAvailabilityState copyWith({
    String? availability,
    bool? gpsConsent,
    bool? sharing,
    bool? gpsOk,
    String? error,
    DateTime? lastSentAt,
    bool clearError = false,
  }) {
    return DriverAvailabilityState(
      availability: availability ?? this.availability,
      gpsConsent: gpsConsent ?? this.gpsConsent,
      sharing: sharing ?? this.sharing,
      gpsOk: gpsOk ?? this.gpsOk,
      error: clearError ? null : error ?? this.error,
      lastSentAt: lastSentAt ?? this.lastSentAt,
    );
  }

  @override
  List<Object?> get props => [availability, gpsConsent, sharing, gpsOk, error, lastSentAt];
}

class DriverAvailabilityCubit extends Cubit<DriverAvailabilityState> {
  final UrbanRemoteDataSource _remote;
  Timer? _timer;

  DriverAvailabilityCubit(this._remote) : super(const DriverAvailabilityState());

  Future<void> setAvailability(String availability, {required bool gpsConsent}) async {
    try {
      await _remote.updateAvailability(availability: availability, gpsConsent: gpsConsent);
      emit(state.copyWith(
        availability: availability,
        gpsConsent: gpsConsent,
        sharing: availability == 'AVAILABLE' && gpsConsent,
        clearError: true,
      ));
      if (state.sharing) {
        await _startSharing();
      } else {
        _timer?.cancel();
      }
    } catch (error) {
      emit(state.copyWith(error: error.toString(), sharing: false));
      _timer?.cancel();
    }
  }

  Future<void> _startSharing() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      emit(state.copyWith(error: 'Permission GPS refusee. Diffusion arretee.', sharing: false, gpsOk: false));
      return;
    }
    emit(state.copyWith(gpsOk: true, sharing: true, clearError: true));
    await _sendOnce();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _sendOnce());
  }

  Future<void> _sendOnce() async {
    if (!state.sharing) {
      return;
    }
    try {
      final position = await Geolocator.getCurrentPosition();
      await _remote.publishPosition(
        lat: position.latitude,
        lon: position.longitude,
        speedKmh: position.speed * 3.6,
        accuracyMeters: position.accuracy,
      );
      emit(state.copyWith(lastSentAt: DateTime.now(), gpsOk: true, clearError: true));
    } catch (error) {
      emit(state.copyWith(error: error.toString(), gpsOk: false));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
