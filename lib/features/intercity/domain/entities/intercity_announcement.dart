enum AnnouncementStatus {
  draft,
  published,
  full,
  closed,
  cancelled,
  unknown;

  static AnnouncementStatus fromApi(String? value) {
    return switch (value?.toUpperCase()) {
      'DRAFT' => AnnouncementStatus.draft,
      'PUBLISHED' => AnnouncementStatus.published,
      'FULL' => AnnouncementStatus.full,
      'CLOSED' => AnnouncementStatus.closed,
      'CANCELLED' => AnnouncementStatus.cancelled,
      _ => AnnouncementStatus.unknown,
    };
  }

  String get apiValue {
    return switch (this) {
      AnnouncementStatus.draft => 'DRAFT',
      AnnouncementStatus.published => 'PUBLISHED',
      AnnouncementStatus.full => 'FULL',
      AnnouncementStatus.closed => 'CLOSED',
      AnnouncementStatus.cancelled => 'CANCELLED',
      AnnouncementStatus.unknown => 'UNKNOWN',
    };
  }

  String get label {
    return switch (this) {
      AnnouncementStatus.draft => 'Brouillon',
      AnnouncementStatus.published => 'Publiée',
      AnnouncementStatus.full => 'Complète',
      AnnouncementStatus.closed => 'Clôturée',
      AnnouncementStatus.cancelled => 'Annulée',
      AnnouncementStatus.unknown => 'Statut inconnu',
    };
  }

  bool get isActive => this == AnnouncementStatus.published || this == AnnouncementStatus.full;
}

// Role : Represente une annonce de trajet intercity telle que renvoyee par l'API.
class IntercityAnnouncement {
  final String id;
  final String publisherProfileId;
  final String? vehicleId;
  final String departureCity;
  final String destinationCity;
  final String? ptRamassage;
  final DateTime departureDate;
  final String departureTime;
  final double priceFcfa;
  final int totalSeats;
  final int remainingSeats;
  final String? instructions;
  final AnnouncementStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? publisherDisplayName;
  final bool publisherVerified;
  final String? vehicleType;
  final int? vehicleCapacity;
  final double? departureLat;
  final double? departureLon;
  final String? vehiclePhotoUrl;

  const IntercityAnnouncement({
    required this.id,
    required this.publisherProfileId,
    this.vehicleId,
    required this.departureCity,
    required this.destinationCity,
    this.ptRamassage,
    required this.departureDate,
    required this.departureTime,
    required this.priceFcfa,
    required this.totalSeats,
    required this.remainingSeats,
    this.instructions,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.publisherDisplayName,
    this.publisherVerified = false,
    this.vehicleType,
    this.vehicleCapacity,
    this.departureLat,
    this.departureLon,
    this.vehiclePhotoUrl,
  });

  bool get hasSeatsAvailable => remainingSeats > 0;

  int get departureHour {
    final parts = departureTime.split(':');
    return int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
  }

  int get departureMinute {
    final parts = departureTime.split(':');
    return parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  }

  int get departureMinutesOfDay => departureHour * 60 + departureMinute;

  String get formattedDepartureTime {
    final hour = departureHour.toString().padLeft(2, '0');
    final minute = departureMinute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get route => '$departureCity → $destinationCity';

  bool get hasGeoPoint => departureLat != null && departureLon != null;
}

// Role : Page de resultats paginee (recherche ou "mes annonces").
class AnnouncementPage {
  final List<IntercityAnnouncement> items;
  final int page;
  final int size;
  final bool hasMore;

  const AnnouncementPage({
    required this.items,
    required this.page,
    required this.size,
    required this.hasMore,
  });

  static const empty = AnnouncementPage(items: [], page: 0, size: 20, hasMore: false);
}
