import 'package:motodi_go_mobile/features/post/domain/entities/post_entities.dart';

double _asDouble(Object? value, [double fallback = 0]) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? fallback;
}

int _asInt(Object? value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}

DateTime? _asDate(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value)?.toLocal();
}

class TripHistoryItemModel {
  final String id;
  final String kind;
  final String? tripType;
  final String status;
  final String? origin;
  final String? destination;
  final double? amount;
  final String? paymentStatus;
  final String? receiptId;
  final bool ratingSubmitted;
  final DateTime createdAt;
  final DateTime? completedAt;

  const TripHistoryItemModel({
    required this.id,
    required this.kind,
    this.tripType,
    required this.status,
    this.origin,
    this.destination,
    this.amount,
    this.paymentStatus,
    this.receiptId,
    this.ratingSubmitted = false,
    required this.createdAt,
    this.completedAt,
  });

  factory TripHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return TripHistoryItemModel(
      id: json['id']?.toString() ?? '',
      kind: json['kind'] as String? ?? 'TRIP',
      tripType: json['tripType'] as String?,
      status: json['status'] as String? ?? '',
      origin: json['origin'] as String?,
      destination: json['destination'] as String?,
      amount: json['amount'] == null ? null : _asDouble(json['amount']),
      paymentStatus: json['paymentStatus'] as String?,
      receiptId: json['receiptId']?.toString(),
      ratingSubmitted: json['ratingSubmitted'] as bool? ?? false,
      createdAt: _asDate(json['createdAt']) ?? DateTime.now(),
      completedAt: _asDate(json['completedAt']),
    );
  }

  TripHistoryItem toEntity() {
    return TripHistoryItem(
      id: id,
      kind: kind,
      tripType: tripType,
      status: status,
      origin: origin,
      destination: destination,
      amount: amount,
      paymentStatus: paymentStatus,
      receiptId: receiptId,
      ratingSubmitted: ratingSubmitted,
      createdAt: createdAt,
      completedAt: completedAt,
    );
  }
}

class TripHistoryPageModel {
  final List<TripHistoryItemModel> items;
  final int page;
  final int size;
  final bool hasMore;

  const TripHistoryPageModel({
    required this.items,
    required this.page,
    required this.size,
    required this.hasMore,
  });

  factory TripHistoryPageModel.fromJson(Map<String, dynamic> json) {
    final raw = json['items'] as List? ?? const [];
    return TripHistoryPageModel(
      items: raw
          .whereType<Map>()
          .map((item) => TripHistoryItemModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      page: _asInt(json['page']),
      size: _asInt(json['size'], 20),
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  TripHistoryResult toEntity() {
    return TripHistoryResult(
      items: items.map((e) => e.toEntity()).toList(),
      page: page,
      size: size,
      hasMore: hasMore,
    );
  }
}

class TripRatingModel {
  final String id;
  final String tripId;
  final String ratedProfileId;
  final int stars;
  final String? comment;
  final List<String> tags;
  final String status;
  final double? averageRating;
  final DateTime createdAt;

  const TripRatingModel({
    required this.id,
    required this.tripId,
    required this.ratedProfileId,
    required this.stars,
    this.comment,
    this.tags = const [],
    required this.status,
    this.averageRating,
    required this.createdAt,
  });

  factory TripRatingModel.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'] as List? ?? const [];
    return TripRatingModel(
      id: json['id']?.toString() ?? '',
      tripId: json['tripId']?.toString() ?? '',
      ratedProfileId: json['ratedProfileId']?.toString() ?? '',
      stars: _asInt(json['stars']),
      comment: json['comment'] as String?,
      tags: rawTags.map((e) => e.toString()).toList(),
      status: json['status'] as String? ?? 'PUBLISHED',
      averageRating: json['averageRating'] == null ? null : _asDouble(json['averageRating']),
      createdAt: _asDate(json['createdAt']) ?? DateTime.now(),
    );
  }

  TripRating toEntity() {
    return TripRating(
      id: id,
      tripId: tripId,
      ratedProfileId: ratedProfileId,
      stars: stars,
      comment: comment,
      tags: tags,
      status: status,
      averageRating: averageRating,
      createdAt: createdAt,
    );
  }
}

class PostReceiptModel {
  final String id;
  final String? paymentTransactionId;
  final String receiptNumber;
  final double amount;
  final String currency;
  final String? pdfUrl;
  final DateTime issuedAt;

  const PostReceiptModel({
    required this.id,
    this.paymentTransactionId,
    required this.receiptNumber,
    required this.amount,
    required this.currency,
    this.pdfUrl,
    required this.issuedAt,
  });

  factory PostReceiptModel.fromJson(Map<String, dynamic> json) {
    return PostReceiptModel(
      id: json['id']?.toString() ?? '',
      paymentTransactionId: json['paymentTransactionId']?.toString(),
      receiptNumber: json['receiptNumber'] as String? ?? '',
      amount: _asDouble(json['amount']),
      currency: json['currency'] as String? ?? 'XAF',
      pdfUrl: json['pdfUrl'] as String?,
      issuedAt: _asDate(json['issuedAt']) ?? DateTime.now(),
    );
  }

  PostReceipt toEntity() {
    return PostReceipt(
      id: id,
      paymentTransactionId: paymentTransactionId,
      receiptNumber: receiptNumber,
      amount: amount,
      currency: currency,
      pdfUrl: pdfUrl,
      issuedAt: issuedAt,
    );
  }
}

class ReceiptPageModel {
  final List<PostReceiptModel> receipts;
  final int page;
  final int size;
  final bool hasMore;

  const ReceiptPageModel({
    required this.receipts,
    required this.page,
    required this.size,
    required this.hasMore,
  });

  factory ReceiptPageModel.fromJson(Map<String, dynamic> json) {
    final raw = json['receipts'] as List? ?? const [];
    return ReceiptPageModel(
      receipts: raw
          .whereType<Map>()
          .map((item) => PostReceiptModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      page: _asInt(json['page']),
      size: _asInt(json['size'], 20),
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  ReceiptListResult toEntity() {
    return ReceiptListResult(
      receipts: receipts.map((e) => e.toEntity()).toList(),
      page: page,
      size: size,
      hasMore: hasMore,
    );
  }
}

class SupportTicketModel {
  final String id;
  final String ticketNumber;
  final String category;
  final String priority;
  final String status;
  final String subject;
  final String message;
  final String? tripId;
  final String? bookingId;
  final String? paymentTransactionId;
  final String? offlineOperationId;
  final DateTime createdAt;
  final DateTime? closedAt;

  const SupportTicketModel({
    required this.id,
    required this.ticketNumber,
    required this.category,
    required this.priority,
    required this.status,
    required this.subject,
    required this.message,
    this.tripId,
    this.bookingId,
    this.paymentTransactionId,
    this.offlineOperationId,
    required this.createdAt,
    this.closedAt,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    return SupportTicketModel(
      id: json['id']?.toString() ?? '',
      ticketNumber: json['ticketNumber'] as String? ?? '',
      category: json['category'] as String? ?? 'TRANSPORT',
      priority: json['priority'] as String? ?? 'MEDIUM',
      status: json['status'] as String? ?? 'OPEN',
      subject: json['subject'] as String? ?? '',
      message: json['message'] as String? ?? '',
      tripId: json['tripId']?.toString(),
      bookingId: json['bookingId']?.toString(),
      paymentTransactionId: json['paymentTransactionId']?.toString(),
      offlineOperationId: json['offlineOperationId']?.toString(),
      createdAt: _asDate(json['createdAt']) ?? DateTime.now(),
      closedAt: _asDate(json['closedAt']),
    );
  }

  SupportTicket toEntity() {
    return SupportTicket(
      id: id,
      ticketNumber: ticketNumber,
      category: SupportCategory.fromApi(category),
      priority: SupportPriority.fromApi(priority),
      status: SupportTicketStatus.fromApi(status),
      subject: subject,
      message: message,
      tripId: tripId,
      bookingId: bookingId,
      paymentTransactionId: paymentTransactionId,
      offlineOperationId: offlineOperationId,
      createdAt: createdAt,
      closedAt: closedAt,
    );
  }
}

class SupportTicketPageModel {
  final List<SupportTicketModel> tickets;
  final int page;
  final int size;
  final bool hasMore;

  const SupportTicketPageModel({
    required this.tickets,
    required this.page,
    required this.size,
    required this.hasMore,
  });

  factory SupportTicketPageModel.fromJson(Map<String, dynamic> json) {
    final raw = json['tickets'] as List? ?? const [];
    return SupportTicketPageModel(
      tickets: raw
          .whereType<Map>()
          .map((item) => SupportTicketModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      page: _asInt(json['page']),
      size: _asInt(json['size'], 20),
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  SupportTicketListResult toEntity() {
    return SupportTicketListResult(
      tickets: tickets.map((e) => e.toEntity()).toList(),
      page: page,
      size: size,
      hasMore: hasMore,
    );
  }
}
