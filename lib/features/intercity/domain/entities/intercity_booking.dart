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
  final String? passengerDisplayName;

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
    this.passengerDisplayName,
  });

  bool get isExpiringSoon {
    if (expiresAt == null || status.isFinal) return false;
    return expiresAt!.difference(DateTime.now()).inMinutes <= 5;
  }

  /// Libellé court Figma — ex. `Marie N.`
  String get shortPassengerName {
    final raw = passengerDisplayName?.trim();
    if (raw == null || raw.isEmpty) {
      final digits = contactPhone.replaceAll(RegExp(r'\D'), '');
      final tail = digits.length >= 2 ? digits.substring(digits.length - 2) : '';
      return tail.isEmpty ? 'Voyageur' : 'Voyageur $tail';
    }
    final parts = raw.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) return parts.first;
    final initial = parts.last.isNotEmpty ? parts.last[0].toUpperCase() : '';
    return '${parts.first} $initial.';
  }

  String get passengerInitials {
    final name = shortPassengerName;
    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      final a = parts[0].isNotEmpty ? parts[0][0] : '';
      final b = parts[1].isNotEmpty ? parts[1][0] : '';
      return ('$a$b').toUpperCase();
    }
    if (name.length >= 2) return name.substring(0, 2).toUpperCase();
    return name.toUpperCase();
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
