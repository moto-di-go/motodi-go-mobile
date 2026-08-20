import 'package:motodi_go_mobile/features/notifications/domain/entities/app_notification.dart';

class AppNotificationModel {
  final String id;
  final String type;
  final String title;
  final String body;
  final String status;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? bookingId;
  final String? paymentTransactionId;
  final String? tripId;
  final Map<String, dynamic> metadata;
  final bool unread;

  const AppNotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.status,
    required this.createdAt,
    this.readAt,
    this.bookingId,
    this.paymentTransactionId,
    this.tripId,
    this.metadata = const {},
    required this.unread,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      status: json['status'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '')?.toLocal() ?? DateTime.now(),
      readAt: DateTime.tryParse(json['readAt'] as String? ?? '')?.toLocal(),
      bookingId: json['bookingId']?.toString(),
      paymentTransactionId: json['paymentTransactionId']?.toString(),
      tripId: json['tripId']?.toString(),
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : const {},
      unread: json['unread'] as bool? ?? (json['readAt'] == null),
    );
  }

  AppNotification toEntity() {
    return AppNotification(
      id: id,
      type: AppNotificationType.fromApi(type),
      title: title,
      body: body,
      status: status,
      createdAt: createdAt,
      readAt: readAt,
      bookingId: bookingId,
      paymentTransactionId: paymentTransactionId,
      tripId: tripId,
      metadata: metadata,
      unread: unread,
    );
  }
}

class NotificationPageModel {
  final List<AppNotificationModel> items;
  final int page;
  final int size;
  final bool hasMore;
  final int unreadCount;

  const NotificationPageModel({
    required this.items,
    required this.page,
    required this.size,
    required this.hasMore,
    required this.unreadCount,
  });

  factory NotificationPageModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? const [];
    return NotificationPageModel(
      items: rawItems
          .map((item) => AppNotificationModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      page: _asInt(json['page']),
      size: _asInt(json['size'], 20),
      hasMore: json['hasMore'] as bool? ?? false,
      unreadCount: _asInt(json['unreadCount']),
    );
  }

  NotificationPage toEntity() {
    return NotificationPage(
      items: items.map((item) => item.toEntity()).toList(),
      page: page,
      size: size,
      hasMore: hasMore,
      unreadCount: unreadCount,
    );
  }
}

int _asInt(Object? value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}
