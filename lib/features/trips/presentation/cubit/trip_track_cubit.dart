import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/trips/data/datasources/trip_sse_client.dart';
import 'package:motodi_go_mobile/features/trips/domain/entities/trip.dart';
import 'package:motodi_go_mobile/features/trips/domain/repositories/trip_repository.dart';
import 'package:motodi_go_mobile/features/trips/presentation/cubit/trip_track_state.dart';

@injectable
class TripTrackCubit extends Cubit<TripTrackState> {
  TripTrackCubit(this._repository, this._sseClient) : super(const TripTrackState());

  final TripRepository _repository;
  final TripSseClient _sseClient;

  Timer? _pollTimer;
  StreamSubscription<List<int>>? _sseSub;
  String? _tripId;

  Future<void> start(String tripId) async {
    _tripId = tripId;
    emit(state.copyWith(status: TripTrackStatus.loading, clearError: true));
    await _refresh(force: true);
    await _connectLive(tripId);
    _startPolling();
  }

  Future<void> refresh() => _refresh(force: true);

  Future<void> _refresh({bool force = false}) async {
    final id = _tripId;
    if (id == null) return;
    final tripResult = await _repository.getTrip(id);
    if (isClosed) return;
    await tripResult.fold(
      (failure) async {
        if (state.trip == null) {
          emit(state.copyWith(status: TripTrackStatus.failure, errorMessage: failure.message));
        }
      },
      (trip) async {
        final eventsResult = await _repository.getTripEvents(id);
        if (isClosed) return;
        final events = eventsResult.fold((_) => state.events, (value) => value);
        emit(
          state.copyWith(
            status: TripTrackStatus.ready,
            trip: trip,
            events: events,
            clearError: true,
          ),
        );
        if (trip.status.isTerminal) {
          await _stopLive();
          _pollTimer?.cancel();
        }
      },
    );
  }

  Future<void> _connectLive(String tripId) async {
    await _stopLive();
    final sub = await _sseClient.subscribe(
      tripId: tripId,
      onEvent: _onSseEvent,
      onError: (_) {
        if (!isClosed) {
          emit(state.copyWith(connectionMode: TripConnectionMode.polling));
        }
      },
      onDone: () {
        if (!isClosed && !(state.trip?.status.isTerminal ?? false)) {
          emit(state.copyWith(connectionMode: TripConnectionMode.polling));
        }
      },
    );
    _sseSub = sub;
    if (!isClosed) {
      emit(
        state.copyWith(
          connectionMode: sub != null ? TripConnectionMode.live : TripConnectionMode.polling,
        ),
      );
    }
  }

  void _onSseEvent(Map<String, dynamic> event) {
    final type = (event['type'] ?? event['eventType'] ?? '').toString().toLowerCase();
    final payload = event['payload'] is Map
        ? Map<String, dynamic>.from(event['payload'] as Map)
        : event;
    final tripId = (payload['tripId'] ?? event['tripId'])?.toString();
    if (tripId != null && _tripId != null && tripId != _tripId) return;

    final statusRaw = (payload['status'] ?? event['status'])?.toString();
    if (statusRaw != null && statusRaw.isNotEmpty && state.trip != null) {
      final next = TripStatus.fromApi(statusRaw);
      emit(
        state.copyWith(
          trip: state.trip!.copyWith(status: next),
          connectionMode: TripConnectionMode.live,
        ),
      );
    }
    if (type.contains('trip') || statusRaw != null) {
      unawaited(_refresh());
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (state.trip?.status.isTerminal == true) {
        _pollTimer?.cancel();
        return;
      }
      if (state.connectionMode == TripConnectionMode.live) {
        // Keep a slow safety poll even in live mode.
        unawaited(_refresh());
        return;
      }
      unawaited(_refresh());
    });
  }

  Future<void> _stopLive() async {
    await _sseSub?.cancel();
    _sseSub = null;
  }

  @override
  Future<void> close() async {
    _pollTimer?.cancel();
    await _stopLive();
    return super.close();
  }
}
