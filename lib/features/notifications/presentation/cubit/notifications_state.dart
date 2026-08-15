part of 'notifications_cubit.dart';

enum NotificationsStatus { initial, loading, loadingMore, success, failure }

class NotificationsState extends Equatable {
  final NotificationsStatus status;
  final bool unreadOnly;
  final List<AppNotification> items;
  final int page;
  final bool hasMore;
  final int unreadCount;
  final String? errorMessage;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.unreadOnly = true,
    this.items = const [],
    this.page = 0,
    this.hasMore = false,
    this.unreadCount = 0,
    this.errorMessage,
  });

  bool get isLoading =>
      status == NotificationsStatus.loading || status == NotificationsStatus.initial;

  NotificationsState copyWith({
    NotificationsStatus? status,
    bool? unreadOnly,
    List<AppNotification>? items,
    int? page,
    bool? hasMore,
    int? unreadCount,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      unreadOnly: unreadOnly ?? this.unreadOnly,
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, unreadOnly, items, page, hasMore, unreadCount, errorMessage];
}
