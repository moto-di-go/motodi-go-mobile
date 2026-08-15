import 'package:equatable/equatable.dart';

enum AppNotificationType {
  subscription,
  confirmation,
  cancellation,
  departureReminder,
  statusChange,
  payment,
  kycDecision,
  unknown;

  static AppNotificationType fromApi(String? value) {
    return switch (value?.toUpperCase()) {
      'SUBSCRIPTION' => AppNotificationType.subscription,
      'CONFIRMATION' => AppNotificationType.confirmation,
      'CANCELLATION' => AppNotificationType.cancellation,
      'DEPARTURE_REMINDER' => AppNotificationType.departureReminder,
      'STATUS_CHANGE' => AppNotificationType.statusChange,
      'PAYMENT' => AppNotificationType.payment,
      'KYC_DECISION' => AppNotificationType.kycDecision,
      _ => AppNotificationType.unknown,
    };
  }
}

enum NotificationVisualKind { success, warning, info, welcome }

class AppNotification extends Equatable {
  final String id;
  final AppNotificationType type;
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

  const AppNotification({
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

  String? get metadataStatus => metadata['status']?.toString();

  NotificationVisualKind get visualKind {
    final lowerTitle = title.toLowerCase();
    final lowerBody = body.toLowerCase();
    if (type == AppNotificationType.kycDecision) {
      final status = metadataStatus?.toUpperCase();
      if (status == 'REJECTED' ||
          lowerTitle.contains('corrig') ||
          lowerTitle.contains('rejet') ||
          lowerBody.contains('rejet')) {
        return NotificationVisualKind.warning;
      }
      if (status == 'VALIDATED' || lowerTitle.contains('valid')) {
        return NotificationVisualKind.success;
      }
      return NotificationVisualKind.info;
    }
    if (lowerTitle.contains('incomplet') ||
        lowerTitle.contains('ajouter') ||
        lowerBody.contains('carte grise') ||
        lowerBody.contains('cni')) {
      return NotificationVisualKind.info;
    }
    if (lowerTitle.contains('bienvenue') || lowerBody.contains('compte a été créé')) {
      return NotificationVisualKind.welcome;
    }
    if (type == AppNotificationType.payment ||
        type == AppNotificationType.confirmation ||
        type == AppNotificationType.subscription) {
      return NotificationVisualKind.success;
    }
    if (type == AppNotificationType.cancellation) {
      return NotificationVisualKind.warning;
    }
    return NotificationVisualKind.welcome;
  }

  AppNotification copyWith({bool? unread, DateTime? readAt}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      status: status,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
      bookingId: bookingId,
      paymentTransactionId: paymentTransactionId,
      tripId: tripId,
      metadata: metadata,
      unread: unread ?? this.unread,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    title,
    body,
    status,
    createdAt,
    readAt,
    bookingId,
    paymentTransactionId,
    tripId,
    metadata,
    unread,
  ];
}

class NotificationPage extends Equatable {
  final List<AppNotification> items;
  final int page;
  final int size;
  final bool hasMore;
  final int unreadCount;

  const NotificationPage({
    required this.items,
    required this.page,
    required this.size,
    required this.hasMore,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [items, page, size, hasMore, unreadCount];
}
