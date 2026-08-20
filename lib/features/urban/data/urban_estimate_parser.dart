import 'package:latlong2/latlong.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_geo.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_models.dart';

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

List<RouteOption> resolveRouteOptions({
  required FareEstimate? estimate,
  required LatLng origin,
  required LatLng destination,
}) {
  final api = estimate?.options ?? const <RouteOption>[];
  if (api.isNotEmpty) {
    final sorted = [...api]..sort(
        (left, right) => _routeKindOrder
            .indexOf(left.kind)
            .compareTo(_routeKindOrder.indexOf(right.kind)),
      );
    return sorted;
  }
  return buildMockRouteOptions(origin, destination, estimate);
}

List<RouteOption> buildMockRouteOptions(
  LatLng origin,
  LatLng destination,
  FareEstimate? estimate,
) {
  final baseDistance = estimate?.distanceKm ?? haversineKm(origin, destination);
  final baseDuration = estimate?.durationMinutes ?? estimateUrbanMinutes(baseDistance);
  final baseAmount = estimate?.amountFcfa ?? (300 + baseDistance * 200).roundToDouble();
  final recommendedLine = (estimate?.polyline.isNotEmpty ?? false)
      ? estimate!.polyline
      : toWktLine(bulgedPath(origin, destination, 0.0018));
  final fastestLine = estimate?.alternatives.isNotEmpty == true
      ? estimate!.alternatives.first.polylineWkt
      : toWktLine(bulgedPath(origin, destination, 0.0042));
  final cheapestLine = toWktLine(bulgedPath(origin, destination, -0.0034));
  final fastestDegraded = estimate?.alternatives.any(
        (alt) => alt.reason.toUpperCase().contains('DEGRAD'),
      ) ??
      false;

  return [
    RouteOption(
      kind: RouteOptionKind.recommended,
      label: RouteOptionKind.recommended.defaultLabel,
      distanceKm: baseDistance,
      durationMinutes: baseDuration,
      amountFcfa: baseAmount,
      polyline: recommendedLine,
      isDemo: true,
    ),
    RouteOption(
      kind: RouteOptionKind.fastest,
      label: RouteOptionKind.fastest.defaultLabel,
      distanceKm: (baseDistance * 0.92).clamp(0.3, 80),
      durationMinutes: (baseDuration * 0.82).round().clamp(1, 180),
      amountFcfa: (baseAmount * 1.08).roundToDouble(),
      polyline: fastestLine,
      degraded: fastestDegraded || (estimate?.status.toUpperCase() == 'DEGRADED'),
      isDemo: true,
    ),
    RouteOption(
      kind: RouteOptionKind.cheapest,
      label: RouteOptionKind.cheapest.defaultLabel,
      distanceKm: (baseDistance * 1.18).clamp(0.3, 80),
      durationMinutes: (baseDuration * 1.22).round().clamp(1, 180),
      amountFcfa: (baseAmount * 0.86).roundToDouble(),
      polyline: cheapestLine,
      isDemo: true,
    ),
  ];
}
