import 'dart:math';

import 'package:latlong2/latlong.dart';

const kYaoundeCenter = LatLng(3.868, 11.516);
const kUrbanSpeedKmh = 25.0;

double haversineKm(LatLng a, LatLng b) {
  const earth = 6371.0;
  final dLat = _rad(b.latitude - a.latitude);
  final dLon = _rad(b.longitude - a.longitude);
  final h =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(_rad(a.latitude)) * cos(_rad(b.latitude)) * sin(dLon / 2) * sin(dLon / 2);
  return earth * 2 * atan2(sqrt(h), sqrt(1 - h));
}

int estimateUrbanMinutes(double distanceKm) {
  if (distanceKm <= 0) return 1;
  return max(1, (distanceKm / kUrbanSpeedKmh * 60).round());
}

double _rad(double deg) => deg * pi / 180;

List<LatLng> bulgedPath(LatLng origin, LatLng destination, double bulge) {
  final mid = LatLng(
    (origin.latitude + destination.latitude) / 2 + bulge,
    (origin.longitude + destination.longitude) / 2 + bulge * 0.55,
  );
  return [origin, mid, destination];
}

String toWktLine(List<LatLng> points) {
  final coords = points.map((p) => '${p.longitude} ${p.latitude}').join(', ');
  return 'LINESTRING($coords)';
}
