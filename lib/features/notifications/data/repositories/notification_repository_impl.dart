import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/core/network/network_info.dart';
import 'package:motodi_go_mobile/features/auth/data/models/api_error_model.dart';
import 'package:motodi_go_mobile/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:motodi_go_mobile/features/notifications/domain/entities/app_notification.dart';
import 'package:motodi_go_mobile/features/notifications/domain/repositories/notification_repository.dart';

@LazySingleton(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  NotificationRepositoryImpl(this._remoteDataSource, this._networkInfo);

  @override
  Future<Either<Failure, NotificationPage>> list({
    bool unreadOnly = false,
    int page = 0,
    int size = 20,
  }) {
    return _guard(() async {
      final model = await _remoteDataSource.list(unreadOnly: unreadOnly, page: page, size: size);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, AppNotification>> markRead(String id) {
    return _guard(() async {
      final model = await _remoteDataSource.markRead(id);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, NotificationPage>> markAllRead() {
    return _guard(() async {
      final model = await _remoteDataSource.markAllRead();
      return model.toEntity();
    });
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    if (!await _networkInfo.isConnected) {
      return left(const NetworkFailure('Pas de connexion internet.', code: 'NETWORK_OFFLINE'));
    }
    try {
      return right(await action());
    } catch (error) {
      return left(_failureFromException(error));
    }
  }

  Failure _failureFromException(Object error) {
    if (error is ApiException) {
      return switch (error.code) {
        'NOTIFICATION_NOT_FOUND' => ValidationFailure(error.message, code: error.code),
        'SESSION_EXPIRED' => AuthFailure(error.message, code: error.code),
        _ => ServerFailure(error.message, code: error.code),
      };
    }
    return ServerFailure(error.toString());
  }
}
