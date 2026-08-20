import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class UrbanLocationResult {
  final LatLng? position;
  final String? error;

  const UrbanLocationResult({this.position, this.error});
}

abstract class UrbanLocationSource {
  Future<UrbanLocationResult> currentPosition();

  Stream<UrbanLocationResult> watchPosition();
}

class GeolocatorLocationSource implements UrbanLocationSource {
  static const _settings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 8);

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

  @override
  Stream<UrbanLocationResult> watchPosition() {
    return Geolocator.getPositionStream(locationSettings: _settings).transform(
      StreamTransformer<Position, UrbanLocationResult>.fromHandlers(
        handleData: (position, sink) {
          sink.add(UrbanLocationResult(position: LatLng(position.latitude, position.longitude)));
        },
        handleError: (error, stack, sink) {
          sink.add(
            const UrbanLocationResult(
              error: 'GPS indisponible. Mode dégradé : sélection manuelle sur la carte.',
            ),
          );
        },
      ),
    );
  }
}
