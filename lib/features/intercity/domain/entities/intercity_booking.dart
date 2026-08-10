enum IntercityBookingStatus {
  pending,
  confirmed,
  pendingPayment,
  cancelled,
  expired,
  paid,
  unknown;

  static IntercityBookingStatus fromApi(String? value) {
    return switch (value?.toUpperCase()) {
      'PENDING' => IntercityBookingStatus.pending,
      'CONFIRMED' => IntercityBookingStatus.confirmed,
      'PENDING_PAYMENT' => IntercityBookingStatus.pendingPayment,
      'CANCELLED' => IntercityBookingStatus.cancelled,
      'EXPIRED' => IntercityBookingStatus.expired,
      'PAID' => IntercityBookingStatus.paid,
      _ => IntercityBookingStatus.unknown,
    };
  }

  String get apiValue {
    return switch (this) {
      IntercityBookingStatus.pending => 'PENDING',
      IntercityBookingStatus.confirmed => 'CONFIRMED',
      IntercityBookingStatus.pendingPayment => 'PENDING_PAYMENT',
      IntercityBookingStatus.cancelled => 'CANCELLED',
      IntercityBookingStatus.expired => 'EXPIRED',
      IntercityBookingStatus.paid => 'PAID',
      IntercityBookingStatus.unknown => 'UNKNOWN',
    };
  }

  // Libelles courts utilises dans les listes et badges.
  String get label {
    return switch (this) {
      IntercityBookingStatus.pending => 'En attente',
      IntercityBookingStatus.confirmed => 'Confirmée',
      IntercityBookingStatus.pendingPayment => 'Confirmée · paiement',
      IntercityBookingStatus.cancelled => 'Annulée',
      IntercityBookingStatus.expired => 'Expirée',
      IntercityBookingStatus.paid => 'Payée',
      IntercityBookingStatus.unknown => 'Statut inconnu',
    };
  }

  // Message plus long utilise sur les pages de statut/timeline.
  String get longLabel {
    return switch (this) {
      IntercityBookingStatus.pending => 'Demande envoyée',
      IntercityBookingStatus.confirmed => 'Réservation confirmée',
      IntercityBookingStatus.pendingPayment => 'Confirmée, en attente de paiement',
      IntercityBookingStatus.cancelled => 'Réservation annulée',
      IntercityBookingStatus.expired => 'Réservation expirée',
      IntercityBookingStatus.paid => 'Réservation payée',
      IntercityBookingStatus.unknown => 'Statut inconnu',
    };
  }

  bool get isFinal =>
      this == IntercityBookingStatus.cancelled ||
      this == IntercityBookingStatus.expired ||
      this == IntercityBookingStatus.paid;

  bool get isCancellable =>
      this == IntercityBookingStatus.pending ||
      this == IntercityBookingStatus.confirmed ||
      this == IntercityBookingStatus.pendingPayment;
}

// Role : Represente une reservation de siege sur une annonce intercity.
class IntercityBooking {
  final String id;
  final String announcementId;
  final String passengerProfileId;
  final String? tripId;
  final IntercityBookingStatus status;
  final int seatsRequested;
  final String contactPhone;
  final DateTime? requestedAt;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final DateTime? expiresAt;
  final String? cancellationReason;

  const IntercityBooking({
    required this.id,
    required this.announcementId,
    required this.passengerProfileId,
    this.tripId,
    required this.status,
    required this.seatsRequested,
    required this.contactPhone,
    this.requestedAt,
    this.confirmedAt,
    this.cancelledAt,
    this.expiresAt,
    this.cancellationReason,
  });

  bool get isExpiringSoon {
    if (expiresAt == null || status.isFinal) return false;
    return expiresAt!.difference(DateTime.now()).inMinutes <= 5;
  }
}

// Role : Page de resultats paginee pour les reservations.
class BookingPage {
  final List<IntercityBooking> items;
  final int page;
  final int size;
  final bool hasMore;

  const BookingPage({
    required this.items,
    required this.page,
    required this.size,
    required this.hasMore,
  });

  static const empty = BookingPage(items: [], page: 0, size: 20, hasMore: false);
}
