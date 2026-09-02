import 'package:equatable/equatable.dart';

enum TripHistoryTab { past, upcoming, cancelled }

extension TripHistoryTabApi on TripHistoryTab {
  String get apiValue => switch (this) {
    TripHistoryTab.past => 'PAST',
    TripHistoryTab.upcoming => 'UPCOMING',
    TripHistoryTab.cancelled => 'CANCELLED',
  };

  String get labelFr => switch (this) {
    TripHistoryTab.past => 'Passés',
    TripHistoryTab.upcoming => 'À venir',
    TripHistoryTab.cancelled => 'Annulés',
  };
}

enum RatingTag {
  ponctuel,
  conduiteSure,
  prixRespecte,
  vehiculePropre,
  problemeItineraire;

  String get apiValue => switch (this) {
    RatingTag.ponctuel => 'PONCTUEL',
    RatingTag.conduiteSure => 'CONDUITE_SURE',
    RatingTag.prixRespecte => 'PRIX_RESPECTE',
    RatingTag.vehiculePropre => 'VEHICULE_PROPRE',
    RatingTag.problemeItineraire => 'PROBLEME_ITINERAIRE',
  };

  String get labelFr => switch (this) {
    RatingTag.ponctuel => 'Ponctuel',
    RatingTag.conduiteSure => 'Conduite sûre',
    RatingTag.prixRespecte => 'Prix respecté',
    RatingTag.vehiculePropre => 'Véhicule propre',
    RatingTag.problemeItineraire => 'Problème itinéraire',
  };

  static RatingTag? fromApi(String? value) {
    return switch (value?.toUpperCase()) {
      'PONCTUEL' => RatingTag.ponctuel,
      'CONDUITE_SURE' => RatingTag.conduiteSure,
      'PRIX_RESPECTE' => RatingTag.prixRespecte,
      'VEHICULE_PROPRE' => RatingTag.vehiculePropre,
      'PROBLEME_ITINERAIRE' => RatingTag.problemeItineraire,
      _ => null,
    };
  }
}

enum SupportCategory {
  transport,
  payment,
  account,
  security,
  emergency;

  String get apiValue => switch (this) {
    SupportCategory.transport => 'TRANSPORT',
    SupportCategory.payment => 'PAYMENT',
    SupportCategory.account => 'ACCOUNT',
    SupportCategory.security => 'SECURITY',
    SupportCategory.emergency => 'EMERGENCY',
  };

  String get labelFr => switch (this) {
    SupportCategory.transport => 'Transport',
    SupportCategory.payment => 'Paiement',
    SupportCategory.account => 'Compte',
    SupportCategory.security => 'Sécurité',
    SupportCategory.emergency => 'Urgence',
  };

  static SupportCategory fromApi(String? value) {
    return switch (value?.toUpperCase()) {
      'TRANSPORT' => SupportCategory.transport,
      'PAYMENT' => SupportCategory.payment,
      'ACCOUNT' => SupportCategory.account,
      'SECURITY' => SupportCategory.security,
      'EMERGENCY' => SupportCategory.emergency,
      _ => SupportCategory.transport,
    };
  }
}

enum SupportPriority {
  low,
  medium,
  high,
  urgent;

  String get apiValue => switch (this) {
    SupportPriority.low => 'LOW',
    SupportPriority.medium => 'MEDIUM',
    SupportPriority.high => 'HIGH',
    SupportPriority.urgent => 'URGENT',
  };

  String get labelFr => switch (this) {
    SupportPriority.low => 'Basse',
    SupportPriority.medium => 'Moyenne',
    SupportPriority.high => 'Haute',
    SupportPriority.urgent => 'Urgente',
  };

  static SupportPriority fromApi(String? value) {
    return switch (value?.toUpperCase()) {
      'LOW' => SupportPriority.low,
      'MEDIUM' => SupportPriority.medium,
      'HIGH' => SupportPriority.high,
      'URGENT' => SupportPriority.urgent,
      _ => SupportPriority.medium,
    };
  }
}

enum SupportTicketStatus {
  open,
  inProgress,
  waitingUser,
  resolved,
  closed,
  unknown;

  String get apiValue => switch (this) {
    SupportTicketStatus.open => 'OPEN',
    SupportTicketStatus.inProgress => 'IN_PROGRESS',
    SupportTicketStatus.waitingUser => 'WAITING_USER',
    SupportTicketStatus.resolved => 'RESOLVED',
    SupportTicketStatus.closed => 'CLOSED',
    SupportTicketStatus.unknown => 'UNKNOWN',
  };

  String get labelFr => switch (this) {
    SupportTicketStatus.open => 'Ouvert',
    SupportTicketStatus.inProgress => 'En cours',
    SupportTicketStatus.waitingUser => 'En attente',
    SupportTicketStatus.resolved => 'Résolu',
    SupportTicketStatus.closed => 'Fermé',
    SupportTicketStatus.unknown => 'Inconnu',
  };

  static SupportTicketStatus fromApi(String? value) {
    return switch (value?.toUpperCase()) {
      'OPEN' => SupportTicketStatus.open,
      'IN_PROGRESS' => SupportTicketStatus.inProgress,
      'WAITING_USER' => SupportTicketStatus.waitingUser,
      'RESOLVED' => SupportTicketStatus.resolved,
      'CLOSED' => SupportTicketStatus.closed,
      _ => SupportTicketStatus.unknown,
    };
  }
}

class TripHistoryItem extends Equatable {
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

  const TripHistoryItem({
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

  bool get isTrip => kind.toUpperCase() == 'TRIP';

  String get routeLabel {
    final from = origin?.trim();
    final to = destination?.trim();
    if (from != null && from.isNotEmpty && to != null && to.isNotEmpty) {
      return '$from → $to';
    }
    return tripType?.toUpperCase() == 'INTERCITY' ? 'Trajet interurbain' : 'Trajet urbain';
  }

  @override
  List<Object?> get props => [
    id,
    kind,
    tripType,
    status,
    origin,
    destination,
    amount,
    paymentStatus,
    receiptId,
    ratingSubmitted,
    createdAt,
    completedAt,
  ];
}

class TripHistoryResult extends Equatable {
  final List<TripHistoryItem> items;
  final int page;
  final int size;
  final bool hasMore;

  const TripHistoryResult({
    required this.items,
    required this.page,
    required this.size,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [items, page, size, hasMore];
}

class TripRating extends Equatable {
  final String id;
  final String tripId;
  final String ratedProfileId;
  final int stars;
  final String? comment;
  final List<String> tags;
  final String status;
  final double? averageRating;
  final DateTime createdAt;

  const TripRating({
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

  @override
  List<Object?> get props => [
    id,
    tripId,
    ratedProfileId,
    stars,
    comment,
    tags,
    status,
    averageRating,
    createdAt,
  ];
}

class PostReceipt extends Equatable {
  final String id;
  final String? paymentTransactionId;
  final String receiptNumber;
  final double amount;
  final String currency;
  final String? pdfUrl;
  final DateTime issuedAt;

  const PostReceipt({
    required this.id,
    this.paymentTransactionId,
    required this.receiptNumber,
    required this.amount,
    required this.currency,
    this.pdfUrl,
    required this.issuedAt,
  });

  @override
  List<Object?> get props => [
    id,
    paymentTransactionId,
    receiptNumber,
    amount,
    currency,
    pdfUrl,
    issuedAt,
  ];
}

class ReceiptListResult extends Equatable {
  final List<PostReceipt> receipts;
  final int page;
  final int size;
  final bool hasMore;

  const ReceiptListResult({
    required this.receipts,
    required this.page,
    required this.size,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [receipts, page, size, hasMore];
}

class SupportTicket extends Equatable {
  final String id;
  final String ticketNumber;
  final SupportCategory category;
  final SupportPriority priority;
  final SupportTicketStatus status;
  final String subject;
  final String message;
  final String? tripId;
  final String? bookingId;
  final String? paymentTransactionId;
  final String? offlineOperationId;
  final DateTime createdAt;
  final DateTime? closedAt;

  const SupportTicket({
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

  @override
  List<Object?> get props => [
    id,
    ticketNumber,
    category,
    priority,
    status,
    subject,
    message,
    tripId,
    bookingId,
    paymentTransactionId,
    offlineOperationId,
    createdAt,
    closedAt,
  ];
}

class SupportTicketListResult extends Equatable {
  final List<SupportTicket> tickets;
  final int page;
  final int size;
  final bool hasMore;

  const SupportTicketListResult({
    required this.tickets,
    required this.page,
    required this.size,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [tickets, page, size, hasMore];
}

class SupportContext extends Equatable {
  final String? tripId;
  final String? bookingId;
  final String? routeLabel;
  final String? statusLabel;

  const SupportContext({this.tripId, this.bookingId, this.routeLabel, this.statusLabel});

  bool get hasContext =>
      (tripId != null && tripId!.isNotEmpty) ||
      (bookingId != null && bookingId!.isNotEmpty) ||
      (routeLabel != null && routeLabel!.isNotEmpty);

  @override
  List<Object?> get props => [tripId, bookingId, routeLabel, statusLabel];
}
