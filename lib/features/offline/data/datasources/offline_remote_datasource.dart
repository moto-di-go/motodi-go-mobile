import 'package:chopper/chopper.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/auth/data/models/api_error_model.dart';
import 'package:motodi_go_mobile/features/offline/data/models/offline_models.dart';

abstract class OfflineRemoteDataSource {
  Future<List<OfflineMapAreaModel>> getMapAreas();

  Future<OfflineSyncBatchModel> sync({required List<Map<String, dynamic>> operations});

  Future<OfflineOperationPageModel> listOperations({
    String? status,
    int page = 0,
    int size = 20,
  });
}

@LazySingleton(as: OfflineRemoteDataSource)
class OfflineRemoteDataSourceImpl implements OfflineRemoteDataSource {
  final ChopperClient _client;

  OfflineRemoteDataSourceImpl(this._client);

  @override
  Future<List<OfflineMapAreaModel>> getMapAreas() async {
    final response = await _client.get<Object, Object>(Uri.parse('/offline/map-areas'));
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    final body = response.body;
    final list = body is List
        ? body
        : (body is Map
            ? (body['areas'] as List? ?? body['content'] as List? ?? const [])
            : const []);
    return list
        .map((e) => OfflineMapAreaModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<OfflineSyncBatchModel> sync({required List<Map<String, dynamic>> operations}) async {
    final response = await _client.post<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/offline/sync'),
      body: {'operations': operations},
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return OfflineSyncBatchModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<OfflineOperationPageModel> listOperations({
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'size': '$size',
      if (status != null && status.isNotEmpty) 'status': status,
    };
    final response = await _client.get<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/offline/operations').replace(queryParameters: params),
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return OfflineOperationPageModel.fromJson(response.body ?? <String, dynamic>{});
  }
}
