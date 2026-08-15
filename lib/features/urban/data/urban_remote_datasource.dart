import 'package:chopper/chopper.dart';
import 'package:motodi_go_mobile/features/auth/data/models/api_error_model.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_models.dart';

class UrbanRemoteDataSource {
  final ChopperClient _client;

  UrbanRemoteDataSource(this._client);

  Future<NearbySearchResult> nearby({
    required double lat,
    required double lon,
    double? radiusKm,
    double? destLat,
    double? destLon,
  }) async {
    final params = <String, dynamic>{
      'lat': '$lat',
      'lon': '$lon',
    };
    if (radiusKm != null) {
      params['radiusKm'] = '$radiusKm';
    }
    if (destLat != null && destLon != null) {
      params['destLat'] = '$destLat';
      params['destLon'] = '$destLon';
    }
    final response = await _client.get<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/urban/drivers/nearby'),
      parameters: params,
    );
    if (!response.isSuccessful) {
      throw ApiException.fromResponse(response);
    }
    return NearbySearchResult.fromJson(response.body ?? <String, dynamic>{});
  }

  Future<FareEstimate> estimate({
    required double originLat,
    required double originLon,
    required double destinationLat,
    required double destinationLon,
  }) async {
    final response = await _client.post<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/pricing/estimate'),
      body: {
        'originLat': originLat,
        'originLon': originLon,
        'destinationLat': destinationLat,
        'destinationLon': destinationLon,
        'serviceType': 'URBAN',
      },
    );
    if (!response.isSuccessful) {
      throw ApiException.fromResponse(response);
    }
    return FareEstimate.fromJson(response.body ?? <String, dynamic>{});
  }

  Future<List<TrafficLayer>> layers() async {
    final response = await _client.get<List<dynamic>, List<dynamic>>(
      Uri.parse('/gis/layers'),
    );
    if (!response.isSuccessful) {
      throw ApiException.fromResponse(response);
    }
    return (response.body ?? const [])
        .whereType<Map>()
        .map((item) => TrafficLayer.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<UrbanPlace>?> popularPlaces() async {
    return _getPlaces('/urban/places/popular');
  }

  Future<List<UrbanPlace>?> geocode(String query) async {
    return _getPlaces('/urban/geocode', parameters: {'q': query});
  }

  Future<UrbanPlace?> reverseGeocode({required double lat, required double lon}) async {
    try {
      final response = await _client.get<dynamic, dynamic>(
        Uri.parse('/urban/reverse'),
        parameters: {'lat': '$lat', 'lon': '$lon'},
      );
      if (response.statusCode == 404 || !response.isSuccessful) {
        return null;
      }
      final places = parsePlaceList(response.body);
      if (places.isNotEmpty) return places.first;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<WalletSummary?> wallet() async {
    try {
      final response = await _client.get<Map<String, dynamic>, Map<String, dynamic>>(
        Uri.parse('/wallet'),
      );
      if (!response.isSuccessful) return null;
      return WalletSummary.fromJson(response.body ?? <String, dynamic>{});
    } catch (_) {
      return null;
    }
  }

  Future<void> updateAvailability({
    required String availability,
    required bool gpsConsent,
  }) async {
    final response = await _client.patch<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/drivers/availability'),
      body: {
        'availability': availability,
        'gpsConsent': gpsConsent,
      },
    );
    if (!response.isSuccessful) {
      throw ApiException.fromResponse(response);
    }
  }

  Future<void> publishPosition({
    required double lat,
    required double lon,
    double? speedKmh,
    double? accuracyMeters,
  }) async {
    final response = await _client.put<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/drivers/position'),
      body: {
        'lat': lat,
        'lon': lon,
        'speedKmh': speedKmh,
        'accuracyMeters': accuracyMeters,
        'consentConfirmed': true,
      },
    );
    if (!response.isSuccessful) {
      throw ApiException.fromResponse(response);
    }
  }

  Future<List<UrbanPlace>?> _getPlaces(
    String path, {
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final response = await _client.get<dynamic, dynamic>(
        Uri.parse(path),
        parameters: parameters ?? const <String, dynamic>{},
      );
      if (response.statusCode == 404 || !response.isSuccessful) {
        return null;
      }
      return parsePlaceList(response.body);
    } catch (_) {
      return null;
    }
  }
}

List<UrbanPlace> parsePlaceList(dynamic body, {bool isDemo = false}) {
  final raw = switch (body) {
    List list => list,
    Map map => map['items'] as List<dynamic>? ??
        map['places'] as List<dynamic>? ??
        (map['label'] != null || map['name'] != null ? [map] : const []),
    _ => const <dynamic>[],
  };
  return raw
      .whereType<Map>()
      .map((item) => UrbanPlace.fromJson(Map<String, dynamic>.from(item), isDemo: isDemo))
      .where((place) => place.point.latitude != 0 || place.point.longitude != 0)
      .toList();
}
