import 'package:flutter_test/flutter_test.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_models.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_remote_datasource.dart';

void main() {
  test('parses UrbanPlaceResponse list from Jackson popular/geocode', () {
    final places = parsePlaceList([
      {
        'id': '11111111-1111-1111-1111-111111111111',
        'label': 'Bastos',
        'lat': 3.896,
        'lon': 11.51,
        'kind': 'NEIGHBORHOOD',
      },
      {
        'id': '22222222-2222-2222-2222-222222222222',
        'label': 'Marché Mokolo',
        'lat': 3.878,
        'lon': 11.503,
        'kind': 'POI',
      },
    ]);

    expect(places, hasLength(2));
    expect(places.first.id, '11111111-1111-1111-1111-111111111111');
    expect(places.first.label, 'Bastos');
    expect(places.first.point.latitude, closeTo(3.896, 0.0001));
    expect(places.first.point.longitude, closeTo(11.51, 0.0001));
    expect(places.first.isDemo, isFalse);
  });

  test('parses a single UrbanPlaceResponse from Jackson reverse', () {
    final places = parsePlaceList({
      'id': '33333333-3333-3333-3333-333333333333',
      'label': 'Nlongkak',
      'lat': 3.885,
      'lon': 11.512,
      'kind': 'NEIGHBORHOOD',
    });

    expect(places, hasLength(1));
    expect(places.single.label, 'Nlongkak');
    expect(places.single.isDemo, isFalse);
  });

  test('parses TrafficLayerResponse updatedAt and fresh', () {
    final layer = TrafficLayer.fromJson({
      'id': '44444444-4444-4444-4444-444444444444',
      'type': 'CONGESTION',
      'label': 'Embouteillage Nlongkak',
      'geometryWkt': 'LINESTRING(11.51 3.88, 11.52 3.89)',
      'geoJson': '{"type":"LineString"}',
      'severity': 'HIGH',
      'validFrom': '2026-08-15T09:00:00Z',
      'validTo': '2026-08-15T18:00:00Z',
      'active': true,
      'source': 'ADMIN',
      'updatedAt': '2026-08-15T09:00:00Z',
      'fresh': true,
    });

    expect(layer.updatedAt, DateTime.parse('2026-08-15T09:00:00Z'));
    expect(layer.fresh, isTrue);
    expect(layer.isStale(DateTime.parse('2026-08-15T10:00:00Z')), isFalse);
    expect(
      layer.freshnessLabel(DateTime.parse('2026-08-15T09:12:00Z')),
      'Mis à jour il y a 12 min',
    );

    final stale = TrafficLayer.fromJson({
      'id': '55555555-5555-5555-5555-555555555555',
      'type': 'ROADWORK',
      'label': 'Travaux',
      'geometryWkt': 'LINESTRING(11.50 3.86, 11.51 3.87)',
      'severity': 'LOW',
      'validFrom': '2026-08-14T09:00:00Z',
      'validTo': '2026-08-14T18:00:00Z',
      'active': false,
      'updatedAt': '2026-08-14T09:00:00Z',
      'fresh': false,
    });
    expect(stale.isStale(), isTrue);
    expect(stale.freshnessLabel(), 'Données anciennes');
  });
}
