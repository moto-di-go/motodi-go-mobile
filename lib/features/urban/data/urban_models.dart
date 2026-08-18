import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

enum RouteOptionKind { recommended, fastest, cheapest }

enum UrbanRideStep {
  home,
  destination,
  pickDestination,
  calculating,
  tripSummary,
  priceDetail,
  searching,
  results,
  filters,
  empty,
  driverDetail,
  confirm,
  layers,
  incident,
  compareRoutes,
  routeOptions,
  confirmed,
}

class NearbyDriver {
  final String driverProfileId;
  final double lat;
  final double lon;
  final double approachDistanceKm;
  final String availability;
  final double? estimatedAmountFcfa;
  final double tripDistanceKm;
  final int tripDurationMinutes;
  final String? appliedRulesTrace;
  final String? displayName;
  final double? rating;
  final int? tripCount;
  final String? vehicleLabel;
  final String? plate;
  final bool? documentsVerified;

  const NearbyDriver({
    required this.driverProfileId,
    required this.lat,
    required this.lon,
    required this.approachDistanceKm,
    required this.availability,
    this.estimatedAmountFcfa,
    this.tripDistanceKm = 0,
    this.tripDurationMinutes = 0,
    this.appliedRulesTrace,
    this.displayName,
    this.rating,
    this.tripCount,
    this.vehicleLabel,
    this.plate,
    this.documentsVerified,
  });

  factory NearbyDriver.fromJson(Map<String, dynamic> json) {
    return NearbyDriver(
      driverProfileId: json['driverProfileId'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0,
      approachDistanceKm: (json['approachDistanceKm'] as num?)?.toDouble() ?? 0,
      availability: json['availability'] as String? ?? 'AVAILABLE',
      estimatedAmountFcfa: (json['estimatedAmountFcfa'] as num?)?.toDouble(),
      tripDistanceKm: (json['tripDistanceKm'] as num?)?.toDouble() ?? 0,
      tripDurationMinutes: (json['tripDurationMinutes'] as num?)?.toInt() ?? 0,
      appliedRulesTrace: json['appliedRulesTrace'] as String?,
      displayName: json['displayName'] as String? ?? json['name'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      tripCount: (json['tripCount'] as num?)?.toInt() ?? (json['completedTrips'] as num?)?.toInt(),
      vehicleLabel: json['vehicleLabel'] as String? ?? json['vehicle'] as String?,
      plate: json['plate'] as String? ?? json['licensePlate'] as String?,
      documentsVerified: json['documentsVerified'] as bool? ?? json['cniVerified'] as bool?,
    );
  }

  bool get isAvailable => availability.toUpperCase() == 'AVAILABLE';
}

class NearbySearchResult {
  final List<NearbyDriver> items;
  final String? emptyReason;
  final double radiusKm;

  const NearbySearchResult({
    required this.items,
    this.emptyReason,
    required this.radiusKm,
  });

  factory NearbySearchResult.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return NearbySearchResult(
      items: rawItems
          .whereType<Map>()
          .map((item) => NearbyDriver.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      emptyReason: json['emptyReason'] as String?,
      radiusKm: (json['radiusKm'] as num?)?.toDouble() ?? 2,
    );
  }
}

class FareBreakdown extends Equatable {
  final double base;
  final double distanceKm;
  final double pricePerKm;
  final double distanceAmount;
  final double nightCoefficient;
  final double weatherCoefficient;
  final bool nightWeatherApplicable;
  final double rounding;
  final double total;
  final bool isDemo;

  const FareBreakdown({
    required this.base,
    required this.distanceKm,
    required this.pricePerKm,
    required this.distanceAmount,
    required this.nightCoefficient,
    required this.weatherCoefficient,
    required this.rounding,
    required this.total,
    this.nightWeatherApplicable = false,
    this.isDemo = false,
  });

  factory FareBreakdown.fromJson(Map<String, dynamic> json, {double? fallbackTotal}) {
    final distanceKm = _readDouble(json, const ['distanceKm']) ?? 0;
    final pricePerKm = _readDouble(json, const ['pricePerKmFcfa', 'pricePerKm', 'perKm']) ?? 0;
    final distanceAmount = _readDouble(json, const ['distanceAmountFcfa', 'distanceAmount']) ??
        (distanceKm * pricePerKm);
    return FareBreakdown(
      base: _readDouble(json, const ['baseFcfa', 'base', 'baseFare']) ?? 0,
      distanceKm: distanceKm,
      pricePerKm: pricePerKm,
      distanceAmount: distanceAmount,
      nightCoefficient: _readDouble(json, const ['nightMultiplier', 'nightCoefficient', 'night']) ?? 1,
      weatherCoefficient:
          _readDouble(json, const ['weatherMultiplier', 'weatherCoefficient', 'weather']) ?? 1,
      nightWeatherApplicable: _readBool(json, const ['nightWeatherApplicable']) ?? false,
      rounding: _readDouble(json, const ['roundingFcfa', 'rounding', 'arrondi']) ?? 0,
      total: _readDouble(json, const ['totalFcfa', 'total']) ?? fallbackTotal ?? 0,
      isDemo: false,
    );
  }

  @override
  List<Object?> get props => [
        base,
        distanceKm,
        pricePerKm,
        distanceAmount,
        nightCoefficient,
        weatherCoefficient,
        nightWeatherApplicable,
        rounding,
        total,
        isDemo,
      ];
}

class RouteOption extends Equatable {
  final RouteOptionKind kind;
  final String label;
  final double distanceKm;
  final int durationMinutes;
  final double amountFcfa;
  final String polyline;
  final bool degraded;
  final bool isDemo;

  const RouteOption({
    required this.kind,
    required this.label,
    required this.distanceKm,
    required this.durationMinutes,
    required this.amountFcfa,
    required this.polyline,
    this.degraded = false,
    this.isDemo = false,
  });

  factory RouteOption.fromJson(Map<String, dynamic> json) {
    final kind = parseRouteOptionKind(json['kind'] as String? ?? json['type'] as String?);
    return RouteOption(
      kind: kind,
      label: json['label'] as String? ?? kind.defaultLabel,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      amountFcfa: (json['amountFcfa'] as num?)?.toDouble() ?? 0,
      polyline: json['polyline'] as String? ?? json['polylineWkt'] as String? ?? '',
      degraded: json['degraded'] as bool? ?? json['isDegraded'] as bool? ?? false,
      isDemo: false,
    );
  }

  RouteOption copyWith({
    String? polyline,
    double? amountFcfa,
    double? distanceKm,
    int? durationMinutes,
    bool? degraded,
    bool? isDemo,
  }) {
    return RouteOption(
      kind: kind,
      label: label,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      amountFcfa: amountFcfa ?? this.amountFcfa,
      polyline: polyline ?? this.polyline,
      degraded: degraded ?? this.degraded,
      isDemo: isDemo ?? this.isDemo,
    );
  }

  @override
  List<Object?> get props =>
      [kind, label, distanceKm, durationMinutes, amountFcfa, polyline, degraded, isDemo];
}

RouteOptionKind parseRouteOptionKind(String? raw) {
  return switch (raw?.toUpperCase()) {
    'FASTEST' || 'PLUS_RAPIDE' => RouteOptionKind.fastest,
    'CHEAPEST' || 'MOINS_CHER' => RouteOptionKind.cheapest,
    _ => RouteOptionKind.recommended,
  };
}

extension RouteOptionKindX on RouteOptionKind {
  String get defaultLabel => switch (this) {
        RouteOptionKind.recommended => 'Conseillé',
        RouteOptionKind.fastest => 'Plus rapide',
        RouteOptionKind.cheapest => 'Moins cher',
      };

  String get apiValue => switch (this) {
        RouteOptionKind.recommended => 'RECOMMENDED',
        RouteOptionKind.fastest => 'FASTEST',
        RouteOptionKind.cheapest => 'CHEAPEST',
      };
}

class RouteAlternative {
  final String reason;
  final String polylineWkt;
  final double extraDistanceKm;
  final int extraDurationMinutes;

  const RouteAlternative({
    required this.reason,
    required this.polylineWkt,
    required this.extraDistanceKm,
    required this.extraDurationMinutes,
  });

  factory RouteAlternative.fromJson(Map<String, dynamic> json) {
    return RouteAlternative(
      reason: json['reason'] as String? ?? '',
      polylineWkt: json['polylineWkt'] as String? ?? json['polyline'] as String? ?? '',
      extraDistanceKm: (json['extraDistanceKm'] as num?)?.toDouble() ?? 0,
      extraDurationMinutes: (json['extraDurationMinutes'] as num?)?.toInt() ?? 0,
    );
  }
}

class FareEstimate {
  final String id;
  final double amountFcfa;
  final double distanceKm;
  final int durationMinutes;
  final String appliedRulesTrace;
  final String polyline;
  final String status;
  final List<RouteAlternative> alternatives;
  final FareBreakdown? breakdown;
  final List<RouteOption> options;

  const FareEstimate({
    required this.id,
    required this.amountFcfa,
    required this.distanceKm,
    required this.durationMinutes,
    required this.appliedRulesTrace,
    required this.polyline,
    required this.status,
    this.alternatives = const [],
    this.breakdown,
    this.options = const [],
  });

  factory FareEstimate.fromJson(Map<String, dynamic> json) {
    final rawAlts = json['alternatives'] as List<dynamic>? ?? const [];
    final rawOptions = json['options'] as List<dynamic>? ?? const [];
    final amount = (json['amountFcfa'] as num?)?.toDouble() ?? 0;
    final breakdownJson = json['breakdown'];
    return FareEstimate(
      id: json['id']?.toString() ?? '',
      amountFcfa: amount,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      appliedRulesTrace: json['appliedRulesTrace'] as String? ?? '',
      polyline: json['polyline'] as String? ?? json['polylineWkt'] as String? ?? '',
      status: json['status'] as String? ?? 'PROPOSED',
      alternatives: rawAlts
          .whereType<Map>()
          .map((item) => RouteAlternative.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      breakdown: breakdownJson is Map
          ? FareBreakdown.fromJson(Map<String, dynamic>.from(breakdownJson), fallbackTotal: amount)
          : null,
      options: rawOptions
          .whereType<Map>()
          .map((item) => RouteOption.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

class RoutePreview {
  final String polyline;
  final double distanceKm;
  final int durationMinutes;
  final String engine;

  const RoutePreview({
    required this.polyline,
    this.distanceKm = 0,
    this.durationMinutes = 0,
    this.engine = '',
  });

  factory RoutePreview.fromJson(Map<String, dynamic> json) {
    return RoutePreview(
      polyline: json['polyline'] as String? ?? json['polylineWkt'] as String? ?? '',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      engine: json['engine'] as String? ?? '',
    );
  }
}

class TrafficLayer {
  final String id;
  final String type;
  final String label;
  final String geometryWkt;
  final String? geoJson;
  final String severity;
  final DateTime fetchedAt;
  final DateTime? updatedAt;
  final DateTime? validFrom;
  final DateTime? validTo;
  final bool active;
  final bool? fresh;
  final String? source;
  final String? impact;

  const TrafficLayer({
    required this.id,
    required this.type,
    required this.label,
    required this.geometryWkt,
    required this.severity,
    required this.fetchedAt,
    this.geoJson,
    this.updatedAt,
    this.validFrom,
    this.validTo,
    this.active = true,
    this.fresh,
    this.source,
    this.impact,
  });

  factory TrafficLayer.fromJson(Map<String, dynamic> json) {
    final updatedAt = DateTime.tryParse(json['updatedAt'] as String? ?? '');
    return TrafficLayer(
      id: json['id']?.toString() ?? '',
      type: json['type'] as String? ?? '',
      label: json['label'] as String? ?? '',
      geometryWkt: json['geometryWkt'] as String? ?? json['wkt'] as String? ?? '',
      geoJson: json['geoJson'] as String?,
      severity: json['severity'] as String? ?? 'LOW',
      fetchedAt: updatedAt ?? DateTime.now(),
      updatedAt: updatedAt,
      validFrom: DateTime.tryParse(json['validFrom'] as String? ?? ''),
      validTo: DateTime.tryParse(json['validTo'] as String? ?? ''),
      active: json['active'] as bool? ?? true,
      fresh: json['fresh'] as bool?,
      source: json['source'] as String?,
      impact: json['impact'] as String?,
    );
  }

  bool isStale([DateTime? now]) {
    if (fresh != null) return !fresh!;
    final clock = now ?? DateTime.now();
    if (validTo != null && clock.isAfter(validTo!)) return true;
    if (validFrom != null && clock.isBefore(validFrom!)) return true;
    return false;
  }

  String freshnessLabel([DateTime? now]) {
    final clock = now ?? DateTime.now();
    if (isStale(clock)) return 'Données anciennes';
    final reference = updatedAt ?? validFrom ?? fetchedAt;
    final minutes = clock.difference(reference).inMinutes.abs();
    if (minutes <= 0) return "Mis à jour à l'instant";
    return 'Mis à jour il y a $minutes min';
  }
}

class UrbanPlace extends Equatable {
  final String id;
  final String label;
  final LatLng point;
  final String? subtitle;
  final String source;
  final double? distanceKm;
  final bool isDemo;

  const UrbanPlace({
    required this.id,
    required this.label,
    required this.point,
    this.subtitle,
    this.source = 'LOCAL',
    this.distanceKm,
    this.isDemo = false,
  });

  factory UrbanPlace.fromJson(Map<String, dynamic> json, {bool isDemo = false}) {
    final lat = (json['lat'] as num?)?.toDouble() ??
        (json['latitude'] as num?)?.toDouble() ??
        0;
    final lon = (json['lon'] as num?)?.toDouble() ??
        (json['lng'] as num?)?.toDouble() ??
        (json['longitude'] as num?)?.toDouble() ??
        0;
    return UrbanPlace(
      id: json['id']?.toString() ?? json['label']?.toString() ?? '$lat,$lon',
      label: json['label'] as String? ?? json['name'] as String? ?? 'Lieu',
      point: LatLng(lat, lon),
      subtitle: json['subtitle'] as String?,
      source: json['source'] as String? ?? 'LOCAL',
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      isDemo: isDemo,
    );
  }

  @override
  List<Object?> get props => [id, label, point, subtitle, source, distanceKm, isDemo];
}

class DestinationHistoryEntry extends Equatable {
  final String label;
  final double lat;
  final double lon;
  final DateTime savedAt;

  const DestinationHistoryEntry({
    required this.label,
    required this.lat,
    required this.lon,
    required this.savedAt,
  });

  LatLng get point => LatLng(lat, lon);

  Map<String, dynamic> toJson() => {
        'label': label,
        'lat': lat,
        'lon': lon,
        'savedAt': savedAt.toIso8601String(),
      };

  factory DestinationHistoryEntry.fromJson(Map<String, dynamic> json) {
    return DestinationHistoryEntry(
      label: json['label'] as String? ?? 'Destination',
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0,
      savedAt: DateTime.tryParse(json['savedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [label, lat, lon, savedAt];
}

class WalletSummary {
  final double currentBalance;
  final String currency;
  final String status;

  const WalletSummary({
    required this.currentBalance,
    this.currency = 'XAF',
    this.status = 'ACTIVE',
  });

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    return WalletSummary(
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'XAF',
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }
}

class UrbanDriverCard extends Equatable {
  final String id;
  final String name;
  final double rating;
  final int tripCount;
  final String vehicleLabel;
  final String plate;
  final bool documentsVerified;
  final bool cniVerified;
  final int etaMinutes;
  final double priceFcfa;
  final String availability;
  final double lat;
  final double lon;
  final double approachDistanceKm;
  final bool profileIsDemo;

  const UrbanDriverCard({
    required this.id,
    required this.name,
    required this.rating,
    required this.tripCount,
    required this.vehicleLabel,
    required this.plate,
    required this.documentsVerified,
    required this.cniVerified,
    required this.etaMinutes,
    required this.priceFcfa,
    required this.availability,
    required this.lat,
    required this.lon,
    required this.approachDistanceKm,
    required this.profileIsDemo,
  });

  bool get isAvailable => availability.toUpperCase() == 'AVAILABLE';

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  @override
  List<Object?> get props => [
        id,
        name,
        rating,
        tripCount,
        vehicleLabel,
        plate,
        documentsVerified,
        cniVerified,
        etaMinutes,
        priceFcfa,
        availability,
        lat,
        lon,
        approachDistanceKm,
        profileIsDemo,
      ];
}

class UrbanFilters extends Equatable {
  final double radiusKm;
  final double? minRating;
  final bool immediateOnly;
  final double? maxPriceFcfa;

  const UrbanFilters({
    this.radiusKm = 2,
    this.minRating,
    this.immediateOnly = false,
    this.maxPriceFcfa,
  });

  UrbanFilters copyWith({
    double? radiusKm,
    Object? minRating = _sentinel,
    bool? immediateOnly,
    Object? maxPriceFcfa = _sentinel,
  }) {
    return UrbanFilters(
      radiusKm: radiusKm ?? this.radiusKm,
      minRating: identical(minRating, _sentinel) ? this.minRating : minRating as double?,
      immediateOnly: immediateOnly ?? this.immediateOnly,
      maxPriceFcfa: identical(maxPriceFcfa, _sentinel) ? this.maxPriceFcfa : maxPriceFcfa as double?,
    );
  }

  @override
  List<Object?> get props => [radiusKm, minRating, immediateOnly, maxPriceFcfa];
}

class LayerVisibility extends Equatable {
  final bool congestion;
  final bool roadwork;
  final bool damagedRoad;
  final bool alternative;
  final bool avoidZones;

  const LayerVisibility({
    this.congestion = true,
    this.roadwork = true,
    this.damagedRoad = true,
    this.alternative = true,
    this.avoidZones = true,
  });

  static const reset = LayerVisibility();

  LayerVisibility copyWith({
    bool? congestion,
    bool? roadwork,
    bool? damagedRoad,
    bool? alternative,
    bool? avoidZones,
  }) {
    return LayerVisibility(
      congestion: congestion ?? this.congestion,
      roadwork: roadwork ?? this.roadwork,
      damagedRoad: damagedRoad ?? this.damagedRoad,
      alternative: alternative ?? this.alternative,
      avoidZones: avoidZones ?? this.avoidZones,
    );
  }

  bool allows(TrafficLayer layer) {
    final type = layer.type.toUpperCase();
    final staleOrDamaged = layer.isStale() || type == 'DAMAGED_ROAD';
    if (staleOrDamaged && type != 'ALTERNATIVE_ROUTE') {
      if (type == 'DAMAGED_ROAD') return damagedRoad || avoidZones;
      if (layer.isStale()) return avoidZones;
    }
    return switch (type) {
      'CONGESTION' => congestion,
      'ROADWORK' => roadwork,
      'DAMAGED_ROAD' => damagedRoad,
      'ALTERNATIVE_ROUTE' => alternative,
      _ => avoidZones,
    };
  }

  @override
  List<Object?> get props => [congestion, roadwork, damagedRoad, alternative, avoidZones];
}

const Object _sentinel = Object();

double? _readDouble(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
  }
  return null;
}

bool? _readBool(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) return value;
  }
  return null;
}
