import 'package:latlong2/latlong.dart';

List<LatLng> parseWktLine(String wkt) {
  final match = RegExp(r'LINESTRING\s*\((.+)\)', caseSensitive: false).firstMatch(wkt);
  if (match == null) {
    return const [];
  }
  return match.group(1)!.split(',').map((part) {
    final coords = part.trim().split(RegExp(r'\s+'));
    return LatLng(double.parse(coords[1]), double.parse(coords[0]));
  }).toList();
}

List<LatLng> parseWktPolygon(String wkt) {
  final match = RegExp(r'POLYGON\s*\(\((.+)\)\)', caseSensitive: false).firstMatch(wkt);
  if (match == null) {
    return parseWktLine(wkt);
  }
  return match.group(1)!.split(',').map((part) {
    final coords = part.trim().split(RegExp(r'\s+'));
    return LatLng(double.parse(coords[1]), double.parse(coords[0]));
  }).toList();
}
