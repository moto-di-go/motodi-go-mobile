import 'package:equatable/equatable.dart';
import 'package:motodi_go_mobile/features/trips/domain/entities/trip.dart';

enum TripTrackStatus { initial, loading, ready, failure }

enum TripConnectionMode { live, polling, offline }

class TripTrackState extends Equatable {
  final TripTrackStatus status;
  final Trip? trip;
  final List<TripEvent> events;
  final TripConnectionMode connectionMode;
  final String? errorMessage;
  final bool nearExpiryWarned;

  const TripTrackState({
    this.status = TripTrackStatus.initial,
    this.trip,
    this.events = const [],
    this.connectionMode = TripConnectionMode.polling,
    this.errorMessage,
    this.nearExpiryWarned = false,
  });

  bool get isLoading => status == TripTrackStatus.loading && trip == null;
  bool get isCompleted => trip?.status == TripStatus.completed;
  bool get isCancelled => trip?.status == TripStatus.cancelled;

  String get nextStepLabel {
    final current = trip?.status;
    return switch (current) {
      TripStatus.confirmed => 'Le conducteur prépare le départ. Restez disponible.',
      TripStatus.approaching => 'Le conducteur arrive. Présentez-vous au point de rendez-vous.',
      TripStatus.onBoard => 'Bon trajet ! Suivez l’itinéraire jusqu’à destination.',
      TripStatus.completed => 'Trajet terminé. Merci d’avoir voyagé avec Moto’di Go.',
      TripStatus.cancelled => 'Ce trajet a été annulé.',
      _ => 'Chargement du statut du trajet…',
    };
  }

  TripTrackState copyWith({
    TripTrackStatus? status,
    Trip? trip,
    List<TripEvent>? events,
    TripConnectionMode? connectionMode,
    String? errorMessage,
    bool? nearExpiryWarned,
    bool clearError = false,
  }) {
    return TripTrackState(
      status: status ?? this.status,
      trip: trip ?? this.trip,
      events: events ?? this.events,
      connectionMode: connectionMode ?? this.connectionMode,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      nearExpiryWarned: nearExpiryWarned ?? this.nearExpiryWarned,
    );
  }

  @override
  List<Object?> get props => [status, trip, events, connectionMode, errorMessage, nearExpiryWarned];
}
