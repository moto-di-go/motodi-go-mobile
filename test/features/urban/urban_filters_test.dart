import 'package:flutter_test/flutter_test.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_filters.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_models.dart';

UrbanDriverCard _driver({
  required String id,
  double rating = 4.2,
  double price = 800,
  String availability = 'AVAILABLE',
}) {
  return UrbanDriverCard(
    id: id,
    name: id,
    rating: rating,
    tripCount: 10,
    vehicleLabel: 'Yamaha Crypton',
    plate: 'LT 1000 A',
    documentsVerified: true,
    cniVerified: true,
    etaMinutes: 4,
    priceFcfa: price,
    availability: availability,
    lat: 3.86,
    lon: 11.51,
    approachDistanceKm: 0.4,
    profileIsDemo: true,
  );
}

void main() {
  final drivers = [
    _driver(id: 'a', rating: 4.8, price: 700),
    _driver(id: 'b', rating: 4.1, price: 900),
    _driver(id: 'c', rating: 3.9, price: 600, availability: 'BUSY'),
  ];

  test('filters by minimum rating', () {
    final result = applyUrbanFilters(drivers, const UrbanFilters(minRating: 4.5));
    expect(result.map((d) => d.id), ['a']);
  });

  test('filters by max price on the client', () {
    final result = applyUrbanFilters(drivers, const UrbanFilters(maxPriceFcfa: 750));
    expect(result.map((d) => d.id), ['a', 'c']);
  });

  test('filters immediate availability on the client', () {
    final result = applyUrbanFilters(drivers, const UrbanFilters(immediateOnly: true));
    expect(result.map((d) => d.id), ['a', 'b']);
  });

  test('combines rating and price filters', () {
    final result = applyUrbanFilters(
      drivers,
      const UrbanFilters(minRating: 4.0, maxPriceFcfa: 850),
    );
    expect(result.map((d) => d.id), ['a']);
  });
}
