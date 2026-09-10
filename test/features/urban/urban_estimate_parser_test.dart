import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_estimate_parser.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_models.dart';

void main() {
  const origin = LatLng(3.868, 11.516);
  const destination = LatLng(3.8905, 11.5108);

  test('parses appliedRulesTrace into breakdown', () {
    const trace = 'base 300 + 4.200km*150, arrondi, night=1, weather=1.150 (precip=2.0mm)';
    final breakdown = parseAppliedRulesTrace(trace, fallbackTotal: 978, fallbackDistanceKm: 4.2);
    expect(breakdown, isNotNull);
    expect(breakdown!.base, 300);
    expect(breakdown.distanceKm, closeTo(4.2, 0.001));
    expect(breakdown.pricePerKm, 150);
    expect(breakdown.nightCoefficient, 1);
    expect(breakdown.weatherCoefficient, closeTo(1.15, 0.001));
    expect(breakdown.total, 978);
    expect(breakdown.isDemo, isFalse);
  });

  test('uses API options when three kinds are present', () {
    final estimate = FareEstimate.fromJson({
      'id': 'est-1',
      'amountFcfa': 800,
      'distanceKm': 3.2,
      'durationMinutes': 10,
      'appliedRulesTrace': '',
      'polyline': 'LINESTRING(11.516 3.868, 11.511 3.890)',
      'options': [
        {
          'kind': 'RECOMMENDED',
          'distanceKm': 3.2,
          'durationMinutes': 10,
          'amountFcfa': 800,
          'polyline': 'LINESTRING(11.516 3.868, 11.511 3.890)',
        },
        {
          'kind': 'FASTEST',
          'distanceKm': 3.0,
          'durationMinutes': 8,
          'amountFcfa': 900,
          'polyline': 'LINESTRING(11.516 3.868, 11.520 3.880, 11.511 3.890)',
          'degraded': true,
        },
        {
          'kind': 'CHEAPEST',
          'distanceKm': 3.8,
          'durationMinutes': 13,
          'amountFcfa': 700,
          'polyline': 'LINESTRING(11.516 3.868, 11.500 3.870, 11.511 3.890)',
        },
      ],
    });

    final options = resolveRouteOptions(
      estimate: estimate,
      origin: origin,
      destination: destination,
    );
    expect(options, hasLength(3));
    expect(options.map((o) => o.kind), [
      RouteOptionKind.recommended,
      RouteOptionKind.fastest,
      RouteOptionKind.cheapest,
    ]);
    expect(options.every((o) => o.isDemo), isFalse);
    expect(options[1].degraded, isTrue);
  });

  test('falls back to three distinct demo geometries when options are absent', () {
    final estimate = FareEstimate.fromJson({
      'id': 'est-2',
      'amountFcfa': 850,
      'distanceKm': 4.0,
      'durationMinutes': 12,
      'appliedRulesTrace': 'base 300 + 4.000km*150, arrondi, night=1, weather=1 (precip=0mm)',
      'polyline': 'LINESTRING(11.516 3.868, 11.511 3.890)',
    });

    final options = resolveRouteOptions(
      estimate: estimate,
      origin: origin,
      destination: destination,
    );
    expect(options, hasLength(3));
    expect(options.every((o) => o.isDemo), isTrue);
    expect(options.map((o) => o.polyline).toSet(), hasLength(3));
    expect(options.first.amountFcfa, 850);
  });

  test('uses /urban/route/preview road geometry when available', () {
    final estimate = FareEstimate.fromJson({
      'id': 'est-preview',
      'amountFcfa': 900,
      'distanceKm': 3.5,
      'durationMinutes': 11,
      'polyline': 'LINESTRING(11.516 3.868, 11.511 3.890)',
      'options': [
        {
          'kind': 'RECOMMENDED',
          'distanceKm': 3.5,
          'durationMinutes': 11,
          'amountFcfa': 900,
          'polyline': 'LINESTRING(11.516 3.868, 11.511 3.890)',
        },
        {
          'kind': 'FASTEST',
          'distanceKm': 3.2,
          'durationMinutes': 9,
          'amountFcfa': 980,
          'polyline': 'LINESTRING(11.516 3.868, 11.520 3.875, 11.511 3.890)',
        },
        {
          'kind': 'CHEAPEST',
          'distanceKm': 4.1,
          'durationMinutes': 14,
          'amountFcfa': 780,
          'polyline': 'LINESTRING(11.516 3.868, 11.500 3.870, 11.511 3.890)',
        },
      ],
    });
    const preview = RoutePreview(
      polyline: 'LINESTRING(11.516 3.868, 11.518 3.875, 11.515 3.882, 11.511 3.890)',
      distanceKm: 3.7,
      durationMinutes: 12,
      engine: 'VALHALLA',
      alternatives: [
        RouteAlternative(
          reason: 'ALT',
          polylineWkt: 'LINESTRING(11.516 3.868, 11.522 3.878, 11.511 3.890)',
          extraDistanceKm: 0.2,
          extraDurationMinutes: -1,
        ),
      ],
    );

    final options = resolveRouteOptions(
      estimate: estimate,
      origin: origin,
      destination: destination,
      preview: preview,
    );
    expect(isRoadItinerary(preview), isTrue);
    expect(options.first.polyline, preview.polyline);
    expect(options[1].polyline, preview.alternatives.first.polylineWkt);
    expect(options[2].polyline, preview.polyline);
    expect(options.every((o) => o.isDemo), isFalse);
  });

  test('prefers API options even when fewer than three kinds are returned', () {
    final estimate = FareEstimate.fromJson({
      'id': 'est-partial',
      'amountFcfa': 850,
      'distanceKm': 3.2,
      'durationMinutes': 10,
      'polyline': 'LINESTRING(11.516 3.868, 11.511 3.890)',
      'options': [
        {
          'kind': 'FASTEST',
          'label': 'Plus rapide',
          'degraded': true,
          'distanceKm': 3.0,
          'durationMinutes': 8,
          'amountFcfa': 900,
          'polyline': 'LINESTRING(11.516 3.868, 11.520 3.880, 11.511 3.890)',
          'reason': 'Route dégradée',
        },
        {
          'kind': 'RECOMMENDED',
          'label': 'Évite routes dégradées',
          'degraded': false,
          'distanceKm': 3.2,
          'durationMinutes': 10,
          'amountFcfa': 850,
          'polyline': 'LINESTRING(11.516 3.868, 11.511 3.890)',
        },
      ],
    });

    final options = resolveRouteOptions(
      estimate: estimate,
      origin: origin,
      destination: destination,
    );
    expect(options, hasLength(2));
    expect(options.map((o) => o.kind), [RouteOptionKind.recommended, RouteOptionKind.fastest]);
    expect(options.every((o) => o.isDemo), isFalse);
  });

  test('parses a real Jackson PricingEstimateResponse', () {
    final estimate = FareEstimate.fromJson(_jacksonEstimateJson);
    expect(estimate.id, '7b1d2c3a-4e5f-6789-abcd-ef0123456789');
    expect(estimate.amountFcfa, 978);
    expect(estimate.distanceKm, 10.0);
    expect(estimate.durationMinutes, 18);
    expect(estimate.polyline, 'LINESTRING(11.50 3.86, 11.54 3.88)');
    expect(estimate.status, 'PROPOSED');
    expect(estimate.alternatives, hasLength(1));
    expect(
      estimate.alternatives.first.polylineWkt,
      'LINESTRING(11.50 3.86, 11.52 3.87, 11.54 3.88)',
    );
    expect(estimate.alternatives.first.reason, 'DEGRADED_AVOIDED');
    expect(estimate.options, hasLength(3));
    expect(estimate.options.map((o) => o.kind), [
      RouteOptionKind.recommended,
      RouteOptionKind.fastest,
      RouteOptionKind.cheapest,
    ]);
    expect(estimate.options[0].label, 'Évite routes dégradées');
    expect(estimate.options[1].degraded, isTrue);
    expect(estimate.options[1].polyline, isNot(estimate.options[0].polyline));

    final breakdown = resolveFareBreakdown(estimate);
    expect(breakdown.isDemo, isFalse);
    expect(breakdown.base, 500);
    expect(breakdown.distanceKm, 10.0);
    expect(breakdown.pricePerKm, 35);
    expect(breakdown.distanceAmount, 350);
    expect(breakdown.nightCoefficient, 1);
    expect(breakdown.weatherCoefficient, closeTo(1.15, 0.001));
    expect(breakdown.nightWeatherApplicable, isTrue);
    expect(breakdown.rounding, closeTo(0.50, 0.001));
    expect(breakdown.total, 978);

    final options = resolveRouteOptions(
      estimate: estimate,
      origin: origin,
      destination: destination,
    );
    expect(options, hasLength(3));
    expect(options.every((o) => o.isDemo), isFalse);
    expect(options.map((o) => o.polyline).toSet(), hasLength(3));
  });
}

/// Shape produced by Jackson from Java records PricingEstimateResponse /
/// PricingBreakdown / PricingRouteOption / BuiltRouteAlternative.
const _jacksonEstimateJson = {
  'id': '7b1d2c3a-4e5f-6789-abcd-ef0123456789',
  'routeId': '0c1d2e3f-4a5b-6789-abcd-ef0123456789',
  'amountFcfa': 978,
  'distanceKm': 10.0,
  'durationMinutes': 18,
  'appliedRulesTrace': 'base 500 + 10.000km*35, arrondi, night=1, weather=1.150 (precip=1.2mm)',
  'polyline': 'LINESTRING(11.50 3.86, 11.54 3.88)',
  'status': 'PROPOSED',
  'alternatives': [
    {
      'reason': 'DEGRADED_AVOIDED',
      'polylineWkt': 'LINESTRING(11.50 3.86, 11.52 3.87, 11.54 3.88)',
      'extraDistanceKm': 0.4,
      'extraDurationMinutes': 2,
    },
  ],
  'calculatedAt': '2026-08-15T10:00:00Z',
  'expiresAt': '2026-08-15T13:30:00Z',
  'breakdown': {
    'baseFcfa': 500,
    'distanceKm': 10.0,
    'pricePerKmFcfa': 35,
    'distanceAmountFcfa': 350.00,
    'nightMultiplier': 1,
    'weatherMultiplier': 1.150,
    'nightWeatherApplicable': true,
    'roundingFcfa': 0.50,
    'totalFcfa': 978,
  },
  'options': [
    {
      'kind': 'RECOMMENDED',
      'label': 'Évite routes dégradées',
      'degraded': false,
      'distanceKm': 11.4,
      'durationMinutes': 45,
      'amountFcfa': 978,
      'polyline': 'LINESTRING(11.50 3.86, 11.51 3.87, 11.54 3.88)',
      'reason': null,
    },
    {
      'kind': 'FASTEST',
      'label': 'Plus rapide',
      'degraded': true,
      'distanceKm': 9.2,
      'durationMinutes': 38,
      'amountFcfa': 822,
      'polyline': 'LINESTRING(11.50 3.86, 11.54 3.88)',
      'reason': 'Route dégradée',
    },
    {
      'kind': 'CHEAPEST',
      'label': 'Moins cher',
      'degraded': false,
      'distanceKm': 10.1,
      'durationMinutes': 50,
      'amountFcfa': 854,
      'polyline': 'LINESTRING(11.50 3.86, 11.52 3.86, 11.54 3.88)',
      'reason': null,
    },
  ],
};
