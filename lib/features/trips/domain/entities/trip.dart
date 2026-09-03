import 'package:equatable/equatable.dart';

enum TripStatus {
  confirmed,
  approaching,
  onBoard,
  completed,
  cancelled,
  unknown;

  static TripStatus fromApi(String? value) {
    return switch (value?.toUpperCase()) {
      'CONFIRMED' => TripStatus.confirmed,
      'APPROACHING' => TripStatus.approaching,
      'ON_BOARD' => TripStatus.onBoard,
      'COMPLETED' => TripStatus.completed,
      'CANCELLED' => TripStatus.cancelled,
      _ => TripStatus.unknown,
    };
  }

  String get apiValue {
    return switch (this) {
      TripStatus.confirmed => 'CONFIRMED',
      TripStatus.approaching => 'APPROACHING',
      TripStatus.onBoard => 'ON_BOARD',
      TripStatus.completed => 'COMPLETED',
      TripStatus.cancelled => 'CANCELLED',
      TripStatus.unknown => 'UNKNOWN',
    };
  }

  String get label {
    return switch (this) {
      TripStatus.confirmed => 'Confirmé',
      TripStatus.approaching => 'Conducteur en approche',
      TripStatus.onBoard => 'À bord',
      TripStatus.completed => 'Trajet terminé',
      TripStatus.cancelled => 'Annulé',
      TripStatus.unknown => 'Statut inconnu',
    };
  }

  bool get isTerminal => this == TripStatus.completed || this == TripStatus.cancelled;

  bool get isActive =>
      this == TripStatus.confirmed || this == TripStatus.approaching || this == TripStatus.onBoard;

  int get timelineIndex {
    return switch (this) {
      TripStatus.confirmed => 0,
      TripStatus.approaching => 1,
      TripStatus.onBoard => 2,
      TripStatus.completed => 3,
      TripStatus.cancelled => -1,
      TripStatus.unknown => 0,
    };
  }
}

class DriverPosition extends Equatable {
  final String? id;
  final String? driverProfileId;
  final double lat;
  final double lon;
  final double? speedKmh;
  final DateTime? capturedAt;

  const DriverPosition({
    this.id,
    this.driverProfileId,
    required this.lat,
    required this.lon,
    this.speedKmh,
    this.capturedAt,
  });

  @override
  List<Object?> get props => [id, driverProfileId, lat, lon, speedKmh, capturedAt];
}

class Trip extends Equatable {
  final String id;
  final String type;
  final TripStatus status;
  final String? passengerProfileId;
  final String? driverProfileId;
  final String? transporterProfileId;
  final String? bookingId;
  final String? departureCity;
  final String? destinationCity;
  final String? ptRamassage;
  final DateTime? plannedDepartureAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double? finalPriceFcfa;
  final String? cancellationReason;
  final DateTime? createdAt;
  final DriverPosition? driverPosition;
  final double? originLat;
  final double? originLon;
  final double? destinationLat;
  final double? destinationLon;

  const Trip({
    required this.id,
    required this.type,
    required this.status,
    this.passengerProfileId,
    this.driverProfileId,
    this.transporterProfileId,
    this.bookingId,
    this.departureCity,
    this.destinationCity,
    this.ptRamassage,
    this.plannedDepartureAt,
    this.startedAt,
    this.completedAt,
    this.finalPriceFcfa,
    this.cancellationReason,
    this.createdAt,
    this.driverPosition,
    this.originLat,
    this.originLon,
    this.destinationLat,
    this.destinationLon,
  });

  String get routeLabel {
    final from = departureCity?.trim();
    final to = destinationCity?.trim();
    if (from != null && from.isNotEmpty && to != null && to.isNotEmpty) {
      return '$from → $to';
    }
    return 'Trajet';
  }

  bool get hasMapCoords =>
      (originLat != null && originLon != null) ||
      (destinationLat != null && destinationLon != null) ||
      driverPosition != null;

  Trip copyWith({
    TripStatus? status,
    DriverPosition? driverPosition,
    DateTime? startedAt,
    DateTime? completedAt,
    String? cancellationReason,
  }) {
    return Trip(
      id: id,
      type: type,
      status: status ?? this.status,
      passengerProfileId: passengerProfileId,
      driverProfileId: driverProfileId,
      transporterProfileId: transporterProfileId,
      bookingId: bookingId,
      departureCity: departureCity,
      destinationCity: destinationCity,
      ptRamassage: ptRamassage,
      plannedDepartureAt: plannedDepartureAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      finalPriceFcfa: finalPriceFcfa,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt,
      driverPosition: driverPosition ?? this.driverPosition,
      originLat: originLat,
      originLon: originLon,
      destinationLat: destinationLat,
      destinationLon: destinationLon,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    status,
    passengerProfileId,
    driverProfileId,
    transporterProfileId,
    bookingId,
    departureCity,
    destinationCity,
    ptRamassage,
    plannedDepartureAt,
    startedAt,
    completedAt,
    finalPriceFcfa,
    cancellationReason,
    createdAt,
    driverPosition,
    originLat,
    originLon,
    destinationLat,
    destinationLon,
  ];
}

class TripEvent extends Equatable {
  final String id;
  final String tripId;
  final TripStatus status;
  final String label;
  final DateTime occurredAt;
  final String? source;

  const TripEvent({
    required this.id,
    required this.tripId,
    required this.status,
    required this.label,
    required this.occurredAt,
    this.source,
  });

  @override
  List<Object?> get props => [id, tripId, status, label, occurredAt, source];
}
