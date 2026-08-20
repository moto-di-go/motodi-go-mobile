import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/notifications/domain/entities/app_notification.dart';
import 'package:motodi_go_mobile/features/notifications/domain/repositories/notification_repository.dart';

part 'notifications_state.dart';

@injectable
class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationRepository _repository;
  static const _pageSize = 20;

  NotificationsCubit(this._repository) : super(const NotificationsState());

  Future<void> load({bool? unreadOnly}) async {
    final filterUnread = unreadOnly ?? state.unreadOnly;
    final filterChanged = unreadOnly != null && unreadOnly != state.unreadOnly;
    emit(
      state.copyWith(
        status: NotificationsStatus.loading,
        unreadOnly: filterUnread,
        items: filterChanged ? const <AppNotification>[] : state.items,
        errorMessage: null,
      ),
    );
    final result = await _repository.list(unreadOnly: filterUnread, page: 0, size: _pageSize);
    result.fold(
      (failure) =>
          emit(state.copyWith(status: NotificationsStatus.failure, errorMessage: failure.message)),
      (page) => emit(
        state.copyWith(
          status: NotificationsStatus.success,
          items: page.items,
          page: page.page,
          hasMore: page.hasMore,
          unreadCount: page.unreadCount,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.status == NotificationsStatus.loadingMore) return;
    emit(state.copyWith(status: NotificationsStatus.loadingMore));
    final nextPage = state.page + 1;
    final result = await _repository.list(
      unreadOnly: state.unreadOnly,
      page: nextPage,
      size: _pageSize,
    );
    result.fold(
      (failure) =>
          emit(state.copyWith(status: NotificationsStatus.success, errorMessage: failure.message)),
      (page) => emit(
        state.copyWith(
          status: NotificationsStatus.success,
          items: [...state.items, ...page.items],
          page: page.page,
          hasMore: page.hasMore,
          unreadCount: page.unreadCount,
        ),
      ),
    );
  }

  Future<void> markRead(String id) async {
    AppNotification? current;
    for (final item in state.items) {
      if (item.id == id) {
        current = item;
        break;
      }
    }
    if (current == null || !current.unread) return;

    final optimistic = current.copyWith(unread: false, readAt: DateTime.now());
    emit(
      state.copyWith(
        items: state.unreadOnly
            ? state.items.where((item) => item.id != id).toList()
            : state.items.map((item) => item.id == id ? optimistic : item).toList(),
        unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
      ),
    );

    final result = await _repository.markRead(id);
    result.fold((_) => load(), (updated) {
      if (state.unreadOnly) return;
      emit(
        state.copyWith(items: state.items.map((item) => item.id == id ? updated : item).toList()),
      );
    });
  }

  Future<void> markAllRead() async {
    if (state.unreadCount == 0) return;
    emit(
      state.copyWith(
        items: state.unreadOnly
            ? const <AppNotification>[]
            : state.items
                  .map((item) => item.copyWith(unread: false, readAt: DateTime.now()))
                  .toList(),
        unreadCount: 0,
      ),
    );
    final result = await _repository.markAllRead();
    result.fold((_) => load(), (_) {});
  }
}
