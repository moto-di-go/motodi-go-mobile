import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_announcement.dart';

// Role : Creneau horaire utilise pour filtrer les departs (matin/apres-midi/soir).
enum IntercityTimeSlot {
  matin,
  apresMidi,
  soir;

  String get label {
    return switch (this) {
      IntercityTimeSlot.matin => 'Matin',
      IntercityTimeSlot.apresMidi => 'Après-midi',
      IntercityTimeSlot.soir => 'Soir',
    };
  }

  // Bornes en minutes depuis minuit (05:00-11:59, 12:00-17:59, 18:00-23:59).
  (int, int) get minutesRange {
    return switch (this) {
      IntercityTimeSlot.matin => (5 * 60, 11 * 60 + 59),
      IntercityTimeSlot.apresMidi => (12 * 60, 17 * 60 + 59),
      IntercityTimeSlot.soir => (18 * 60, 23 * 60 + 59),
    };
  }

  String get timeFrom {
    final (from, _) = minutesRange;
    return '${(from ~/ 60).toString().padLeft(2, '0')}:${(from % 60).toString().padLeft(2, '0')}:00';
  }

  String get timeTo {
    final (_, to) = minutesRange;
    return '${(to ~/ 60).toString().padLeft(2, '0')}:${(to % 60).toString().padLeft(2, '0')}:00';
  }
}

enum IntercitySort {
  departureTime,
  price,
  proximity;

  String get apiValue => name;

  String get label {
    return switch (this) {
      IntercitySort.departureTime => 'Heure de départ',
      IntercitySort.price => 'Prix',
      IntercitySort.proximity => 'Proximité',
    };
  }
}

// Role : Suggestion d'elargissement de recherche renvoyee par le backend quand 0 resultat.
class WideningSuggestion {
  final String code;
  final String message;
  final Map<String, dynamic> suggestedQuery;

  const WideningSuggestion({
    required this.code,
    required this.message,
    required this.suggestedQuery,
  });
}

// Role : Resultat de recherche paginee, avec suggestions d'elargissement si 0 resultat.
class AnnouncementSearchResult {
  final List<IntercityAnnouncement> items;
  final int page;
  final int size;
  final bool hasMore;
  final List<WideningSuggestion> wideningSuggestions;

  const AnnouncementSearchResult({
    required this.items,
    required this.page,
    required this.size,
    required this.hasMore,
    this.wideningSuggestions = const [],
  });

  bool get isEmpty => items.isEmpty;
}

// Role : Filtres de recherche intercity conserves en session (non persistes disque).
class SearchFilters {
  final String? departureCity;
  final String? destinationCity;
  final DateTime? date;
  final int seats;
  final double? maxPrice;
  final IntercityTimeSlot? timeSlot;
  final String? ptRamassage;
  final bool onlyVerified;
  final bool onlyAvailable;
  final IntercitySort sort;

  const SearchFilters({
    this.departureCity,
    this.destinationCity,
    this.date,
    this.seats = 1,
    this.maxPrice,
    this.timeSlot,
    this.ptRamassage,
    this.onlyVerified = false,
    this.onlyAvailable = true,
    this.sort = IntercitySort.departureTime,
  });

  bool get hasRoute =>
      (departureCity != null && departureCity!.trim().isNotEmpty) ||
      (destinationCity != null && destinationCity!.trim().isNotEmpty);

  int get activeFilterCount {
    var count = 0;
    if (date != null) count++;
    if (maxPrice != null) count++;
    if (timeSlot != null) count++;
    if (ptRamassage != null && ptRamassage!.trim().isNotEmpty) count++;
    if (onlyVerified) count++;
    if (!onlyAvailable) count++;
    if (sort != IntercitySort.departureTime) count++;
    if (seats != 1) count++;
    return count;
  }

  SearchFilters copyWith({
    String? departureCity,
    bool clearDepartureCity = false,
    String? destinationCity,
    bool clearDestinationCity = false,
    DateTime? date,
    bool clearDate = false,
    int? seats,
    double? maxPrice,
    bool clearMaxPrice = false,
    IntercityTimeSlot? timeSlot,
    bool clearTimeSlot = false,
    String? ptRamassage,
    bool clearPtRamassage = false,
    bool? onlyVerified,
    bool? onlyAvailable,
    IntercitySort? sort,
  }) {
    return SearchFilters(
      departureCity: clearDepartureCity ? null : (departureCity ?? this.departureCity),
      destinationCity: clearDestinationCity ? null : (destinationCity ?? this.destinationCity),
      date: clearDate ? null : (date ?? this.date),
      seats: seats ?? this.seats,
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      timeSlot: clearTimeSlot ? null : (timeSlot ?? this.timeSlot),
      ptRamassage: clearPtRamassage ? null : (ptRamassage ?? this.ptRamassage),
      onlyVerified: onlyVerified ?? this.onlyVerified,
      onlyAvailable: onlyAvailable ?? this.onlyAvailable,
      sort: sort ?? this.sort,
    );
  }

  SearchFilters clearAdvancedFilters() {
    return SearchFilters(
      departureCity: departureCity,
      destinationCity: destinationCity,
      date: date,
      seats: seats,
    );
  }

  // Applique une suggestion d'elargissement (ex: date ou ville modifiee) en session.
  SearchFilters applyingWidening(Map<String, dynamic> suggestedQuery) {
    return SearchFilters(
      departureCity: suggestedQuery['departureCity'] as String? ?? departureCity,
      destinationCity: suggestedQuery['destinationCity'] as String? ?? destinationCity,
      date: suggestedQuery.containsKey('date')
          ? DateTime.tryParse(suggestedQuery['date'] as String? ?? '')
          : date,
      seats: seats,
      maxPrice: suggestedQuery.containsKey('maxPrice')
          ? (suggestedQuery['maxPrice'] as num?)?.toDouble()
          : maxPrice,
      timeSlot: suggestedQuery.containsKey('timeSlot') ? null : timeSlot,
      ptRamassage: suggestedQuery.containsKey('ptRamassage')
          ? suggestedQuery['ptRamassage'] as String?
          : ptRamassage,
      onlyVerified: onlyVerified,
      onlyAvailable: onlyAvailable,
      sort: sort,
    );
  }
}
