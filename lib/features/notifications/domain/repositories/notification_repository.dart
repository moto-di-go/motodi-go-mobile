import 'package:fpdart/fpdart.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/features/notifications/domain/entities/app_notification.dart';

abstract class NotificationRepository {
  Future<Either<Failure, NotificationPage>> list({
    bool unreadOnly = false,
    int page = 0,
    int size = 20,
  });

  Future<Either<Failure, AppNotification>> markRead(String id);

  Future<Either<Failure, NotificationPage>> markAllRead();
}
