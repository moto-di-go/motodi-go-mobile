import 'package:chopper/chopper.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/auth/data/models/api_error_model.dart';
import 'package:motodi_go_mobile/features/notifications/data/models/notification_models.dart';

abstract class NotificationRemoteDataSource {
  Future<NotificationPageModel> list({
    bool unreadOnly = false,
    int page = 0,
    int size = 20,
  });

  Future<AppNotificationModel> markRead(String id);

  Future<NotificationPageModel> markAllRead();
}

@LazySingleton(as: NotificationRemoteDataSource)
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ChopperClient _client;

  NotificationRemoteDataSourceImpl(this._client);

  @override
  Future<NotificationPageModel> list({
    bool unreadOnly = false,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _client.get<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/notifications'),
      parameters: {
        'unreadOnly': '$unreadOnly',
        'page': '$page',
        'size': '$size',
      },
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return NotificationPageModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<AppNotificationModel> markRead(String id) async {
    final response = await _client.post<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/notifications/$id/read'),
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return AppNotificationModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<NotificationPageModel> markAllRead() async {
    final response = await _client.post<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/notifications/read-all'),
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return NotificationPageModel.fromJson(response.body ?? <String, dynamic>{});
  }
}
