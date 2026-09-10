import 'package:latlong2/latlong.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_geo.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_models.dart';
import 'package:motodi_go_mobile/features/urban/presentation/wkt_parser.dart';

final _traceRegex = RegExp(
  r'base\s+([\d.]+)\s*\+\s*([\d.]+)\s*km\s*\*\s*([\d.]+).*night\s*=\s*([\d.]+).*weather\s*=\s*([\d.]+)',
  caseSensitive: false,
);

FareBreakdown resolveFareBreakdown(FareEstimate? estimate, {double? selectedAmount}) {
  if (estimate?.breakdown != null) {
    final breakdown = estimate!.breakdown!;
    if (selectedAmount != null && selectedAmount != breakdown.total) {
      return FareBreakdown(
        base: breakdown.base,
        distanceKm: breakdown.distanceKm,
        pricePerKm: breakdown.pricePerKm,
        distanceAmount: breakdown.distanceAmount,
        nightCoefficient: breakdown.nightCoefficient,
        weatherCoefficient: breakdown.weatherCoefficient,
        nightWeatherApplicable: breakdown.nightWeatherApplicable,
        rounding: breakdown.rounding,
        total: selectedAmount,
        isDemo: breakdown.isDemo,
      );
    }
    return breakdown;
  }
  final parsed = parseAppliedRulesTrace(
    estimate?.appliedRulesTrace ?? '',
    fallbackTotal: selectedAmount ?? estimate?.amountFcfa ?? 0,
    fallbackDistanceKm: estimate?.distanceKm ?? 0,
  );
  if (parsed != null) return parsed;
  return mockBreakdown(
    amount: selectedAmount ?? estimate?.amountFcfa ?? 800,
    distanceKm: estimate?.distanceKm ?? 3.2,
  );
}

FareBreakdown? parseAppliedRulesTrace(
  String trace, {
  required double fallbackTotal,
  required double fallbackDistanceKm,
}) {
  final match = _traceRegex.firstMatch(trace);
  if (match == null) return null;
  final base = double.tryParse(match.group(1)!) ?? 0;
  final distanceKm = double.tryParse(match.group(2)!) ?? fallbackDistanceKm;
  final pricePerKm = double.tryParse(match.group(3)!) ?? 0;
  final night = double.tryParse(match.group(4)!) ?? 1;
  final weather = double.tryParse(match.group(5)!) ?? 1;
  final distanceAmount = distanceKm * pricePerKm;
  final raw = (base + distanceAmount) * night * weather;
  return FareBreakdown(
    base: base,
    distanceKm: distanceKm,
    pricePerKm: pricePerKm,
    distanceAmount: distanceAmount,
    nightCoefficient: night,
    weatherCoefficient: weather,
    rounding: fallbackTotal - raw,
    total: fallbackTotal,
  );
}

FareBreakdown mockBreakdown({required double amount, required double distanceKm}) {
  const base = 300.0;
  const pricePerKm = 150.0;
  final distanceAmount = distanceKm * pricePerKm;
  return FareBreakdown(
    base: base,
    distanceKm: distanceKm,
    pricePerKm: pricePerKm,
    distanceAmount: distanceAmount,
    nightCoefficient: 1,
    weatherCoefficient: 1,
    rounding: amount - (base + distanceAmount),
    total: amount,
    isDemo: true,
  );
}

const _routeKindOrder = [
  RouteOptionKind.recommended,
  RouteOptionKind.fastest,
  RouteOptionKind.cheapest,
];

/// Same validation as intercity detail map: reject DIRECT / empty / too-short geometries.
bool isRoadItinerary(RoutePreview? preview) {
  if (preview == null || preview.polyline.trim().isEmpty) {
    return false;
  }
  if (preview.engine.toUpperCase() == 'DIRECT') {
    return false;
  }
  return parseWktLine(preview.polyline).length >= 3;
}

List<RouteOption> resolveRouteOptions({
  required FareEstimate? estimate,
  required LatLng origin,
  required LatLng destination,
  RoutePreview? preview,
}) {
  final api = estimate?.options ?? const <RouteOption>[];
  if (api.isNotEmpty) {
    final sorted = [...api]
      ..sort(
        (left, right) =>
            _routeKindOrder.indexOf(left.kind).compareTo(_routeKindOrder.indexOf(right.kind)),
      );
    return applyPreviewGeometry(sorted, preview: preview);
  }
  return buildMockRouteOptions(origin, destination, estimate, preview: preview);
}

/// Prefer `/urban/route/preview` road geometry (Valhalla) over pricing / bulged polylines.
List<RouteOption> applyPreviewGeometry(
  List<RouteOption> options, {
  RoutePreview? preview,
}) {
  if (!isRoadItinerary(preview)) return options;
  final road = preview!;
  final alts = road.alternatives
      .where((alt) => parseWktLine(alt.polylineWkt).length >= 3)
      .toList();
  return options.map((option) {
    final polyline = switch (option.kind) {
      RouteOptionKind.recommended => road.polyline,
      RouteOptionKind.fastest => alts.isNotEmpty ? alts.first.polylineWkt : road.polyline,
      RouteOptionKind.cheapest => alts.length > 1 ? alts[1].polylineWkt : road.polyline,
    };
    return option.copyWith(polyline: polyline);
  }).toList();
}

List<RouteOption> buildMockRouteOptions(
  LatLng origin,
  LatLng destination,
  FareEstimate? estimate, {
  RoutePreview? preview,
}) {
  final baseDistance = (isRoadItinerary(preview) && preview!.distanceKm > 0)
      ? preview.distanceKm
      : (estimate?.distanceKm ?? haversineKm(origin, destination));
  final baseDuration = (isRoadItinerary(preview) && preview!.durationMinutes > 0)
      ? preview.durationMinutes
      : (estimate?.durationMinutes ?? estimateUrbanMinutes(baseDistance));
  final baseAmount = estimate?.amountFcfa ?? (300 + baseDistance * 200).roundToDouble();

  final roadOk = isRoadItinerary(preview);
  final roadAlts = roadOk
      ? preview!.alternatives
            .where((alt) => parseWktLine(alt.polylineWkt).length >= 3)
            .toList()
      : const <RouteAlternative>[];

  final recommendedLine = roadOk
      ? preview!.polyline
      : ((estimate?.polyline.isNotEmpty ?? false)
            ? estimate!.polyline
            : toWktLine(bulgedPath(origin, destination, 0.0018)));
  final fastestLine = roadOk
      ? (roadAlts.isNotEmpty ? roadAlts.first.polylineWkt : preview!.polyline)
      : (estimate?.alternatives.isNotEmpty == true
            ? estimate!.alternatives.first.polylineWkt
            : toWktLine(bulgedPath(origin, destination, 0.0042)));
  final cheapestLine = roadOk
      ? (roadAlts.length > 1 ? roadAlts[1].polylineWkt : preview!.polyline)
      : toWktLine(bulgedPath(origin, destination, -0.0034));
  final fastestDegraded =
      estimate?.alternatives.any((alt) => alt.reason.toUpperCase().contains('DEGRAD')) ?? false;

  return [
    RouteOption(
      kind: RouteOptionKind.recommended,
      label: RouteOptionKind.recommended.defaultLabel,
      distanceKm: baseDistance,
      durationMinutes: baseDuration,
      amountFcfa: baseAmount,
      polyline: recommendedLine,
      isDemo: !roadOk,
    ),
    RouteOption(
      kind: RouteOptionKind.fastest,
      label: RouteOptionKind.fastest.defaultLabel,
      distanceKm: (baseDistance * 0.92).clamp(0.3, 80),
      durationMinutes: (baseDuration * 0.82).round().clamp(1, 180),
      amountFcfa: (baseAmount * 1.08).roundToDouble(),
      polyline: fastestLine,
      degraded: fastestDegraded || (estimate?.status.toUpperCase() == 'DEGRADED'),
      isDemo: !roadOk,
    ),
    RouteOption(
      kind: RouteOptionKind.cheapest,
      label: RouteOptionKind.cheapest.defaultLabel,
      distanceKm: (baseDistance * 1.18).clamp(0.3, 80),
      durationMinutes: (baseDuration * 1.22).round().clamp(1, 180),
      amountFcfa: (baseAmount * 0.86).roundToDouble(),
      polyline: cheapestLine,
      isDemo: !roadOk,
    ),
  ];
}
