import 'package:motodi_go_mobile/features/trips/domain/entities/trip.dart';

class DriverPositionModel {
  final String? id;
  final String? driverProfileId;
  final double lat;
  final double lon;
  final double? speedKmh;
  final String? capturedAt;

  const DriverPositionModel({
    this.id,
    this.driverProfileId,
    required this.lat,
    required this.lon,
    this.speedKmh,
    this.capturedAt,
  });

  factory DriverPositionModel.fromJson(Map<String, dynamic> json) {
    return DriverPositionModel(
      id: json['id']?.toString(),
      driverProfileId: json['driverProfileId']?.toString(),
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0,
      speedKmh: (json['speedKmh'] as num?)?.toDouble(),
      capturedAt: json['capturedAt']?.toString(),
    );
  }

  DriverPosition toEntity() {
    return DriverPosition(
      id: id,
      driverProfileId: driverProfileId,
      lat: lat,
      lon: lon,
      speedKmh: speedKmh,
      capturedAt: capturedAt == null ? null : DateTime.tryParse(capturedAt!),
    );
  }
}

class TripModel {
  final String id;
  final String type;
  final String status;
  final String? passengerProfileId;
  final String? driverProfileId;
  final String? transporterProfileId;
  final String? bookingId;
  final String? departureCity;
  final String? destinationCity;
  final String? ptRamassage;
  final String? plannedDepartureAt;
  final String? startedAt;
  final String? completedAt;
  final double? finalPriceFcfa;
  final String? cancellationReason;
  final String? createdAt;
  final DriverPositionModel? driverPosition;
  final double? originLat;
  final double? originLon;
  final double? destinationLat;
  final double? destinationLon;

  const TripModel({
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

  factory TripModel.fromJson(Map<String, dynamic> json) {
    final driverRaw = json['driverPosition'];
    return TripModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'INTERCITY',
      status: json['status']?.toString() ?? 'UNKNOWN',
      passengerProfileId: json['passengerProfileId']?.toString(),
      driverProfileId: json['driverProfileId']?.toString(),
      transporterProfileId: json['transporterProfileId']?.toString(),
      bookingId: json['bookingId']?.toString(),
      departureCity: json['departureCity']?.toString(),
      destinationCity: json['destinationCity']?.toString(),
      ptRamassage: json['ptRamassage']?.toString(),
      plannedDepartureAt: json['plannedDepartureAt']?.toString(),
      startedAt: json['startedAt']?.toString(),
      completedAt: json['completedAt']?.toString(),
      finalPriceFcfa: (json['finalPriceFcfa'] as num?)?.toDouble(),
      cancellationReason: json['cancellationReason']?.toString(),
      createdAt: json['createdAt']?.toString(),
      driverPosition: driverRaw is Map
          ? DriverPositionModel.fromJson(Map<String, dynamic>.from(driverRaw))
          : null,
      originLat: (json['originLat'] as num?)?.toDouble(),
      originLon: (json['originLon'] as num?)?.toDouble(),
      destinationLat: (json['destinationLat'] as num?)?.toDouble(),
      destinationLon: (json['destinationLon'] as num?)?.toDouble(),
    );
  }

  Trip toEntity() {
    return Trip(
      id: id,
      type: type,
      status: TripStatus.fromApi(status),
      passengerProfileId: passengerProfileId,
      driverProfileId: driverProfileId,
      transporterProfileId: transporterProfileId,
      bookingId: bookingId,
      departureCity: departureCity,
      destinationCity: destinationCity,
      ptRamassage: ptRamassage,
      plannedDepartureAt: plannedDepartureAt == null
          ? null
          : DateTime.tryParse(plannedDepartureAt!),
      startedAt: startedAt == null ? null : DateTime.tryParse(startedAt!),
      completedAt: completedAt == null ? null : DateTime.tryParse(completedAt!),
      finalPriceFcfa: finalPriceFcfa,
      cancellationReason: cancellationReason,
      createdAt: createdAt == null ? null : DateTime.tryParse(createdAt!),
      driverPosition: driverPosition?.toEntity(),
      originLat: originLat,
      originLon: originLon,
      destinationLat: destinationLat,
      destinationLon: destinationLon,
    );
  }
}

class TripEventModel {
  final String id;
  final String tripId;
  final String status;
  final String label;
  final String occurredAt;
  final String? source;

  const TripEventModel({
    required this.id,
    required this.tripId,
    required this.status,
    required this.label,
    required this.occurredAt,
    this.source,
  });

  factory TripEventModel.fromJson(Map<String, dynamic> json) {
    return TripEventModel(
      id: json['id']?.toString() ?? '',
      tripId: json['tripId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'UNKNOWN',
      label: json['label']?.toString() ?? '',
      occurredAt: json['occurredAt']?.toString() ?? '',
      source: json['source']?.toString(),
    );
  }

  TripEvent toEntity() {
    return TripEvent(
      id: id,
      tripId: tripId,
      status: TripStatus.fromApi(status),
      label: label.isEmpty ? TripStatus.fromApi(status).label : label,
      occurredAt: DateTime.tryParse(occurredAt) ?? DateTime.now(),
      source: source,
    );
  }
}
