import 'package:flutter_test/flutter_test.dart';
import 'package:motodi_go_mobile/features/urban/presentation/wkt_parser.dart';

void main() {
  test('parses linestring lon lat into latlng', () {
    final points = parseWktLine('LINESTRING(11.50 3.86, 11.52 3.86)');
    expect(points, hasLength(2));
    expect(points.first.latitude, closeTo(3.86, 0.0001));
    expect(points.first.longitude, closeTo(11.50, 0.0001));
  });
}
