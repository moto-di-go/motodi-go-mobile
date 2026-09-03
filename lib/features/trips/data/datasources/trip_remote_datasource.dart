import 'package:chopper/chopper.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/auth/data/models/api_error_model.dart';
import 'package:motodi_go_mobile/features/trips/data/models/trip_models.dart';

abstract class TripRemoteDataSource {
  Future<List<TripModel>> getActiveTrips();

  Future<TripModel> getTrip(String id);

  Future<List<TripEventModel>> getTripEvents(String id);
}

@LazySingleton(as: TripRemoteDataSource)
class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  final ChopperClient _client;

  TripRemoteDataSourceImpl(this._client);

  @override
  Future<List<TripModel>> getActiveTrips() async {
    final response = await _client.get<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/trips/active'),
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    final body = response.body ?? <String, dynamic>{};
    final raw = body['trips'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => TripModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<TripModel> getTrip(String id) async {
    final response = await _client.get<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/trips/$id'),
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return TripModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<List<TripEventModel>> getTripEvents(String id) async {
    final response = await _client.get<dynamic, dynamic>(Uri.parse('/trips/$id/events'));
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    final body = response.body;
    if (body is List) {
      return body
          .whereType<Map>()
          .map((item) => TripEventModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    if (body is Map) {
      final events = body['events'] ?? body['items'];
      if (events is List) {
        return events
            .whereType<Map>()
            .map((item) => TripEventModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    }
    return const [];
  }
}
