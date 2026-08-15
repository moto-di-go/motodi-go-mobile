import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class UrbanLocationResult {
  final LatLng? position;
  final String? error;

  const UrbanLocationResult({this.position, this.error});
}

abstract class UrbanLocationSource {
  Future<UrbanLocationResult> currentPosition();
}

class GeolocatorLocationSource implements UrbanLocationSource {
  @override
  Future<UrbanLocationResult> currentPosition() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return const UrbanLocationResult(
          error: 'Localisation refusée. Vous pouvez choisir origine et destination sur la carte.',
        );
      }
      final position = await Geolocator.getCurrentPosition();
      return UrbanLocationResult(position: LatLng(position.latitude, position.longitude));
    } catch (_) {
      return const UrbanLocationResult(
        error: 'GPS indisponible. Mode dégradé : sélection manuelle sur la carte.',
      );
    }
  }
}
