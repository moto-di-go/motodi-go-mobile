import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_announcement.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_booking.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_vehicle.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/search_filters.dart';

class IntercityAnnouncementModel {
  final String id;
  final String publisherProfileId;
  final String? vehicleId;
  final String departureCity;
  final String destinationCity;
  final String? departureQuarter;
  final String departureDate;
  final String departureTime;
  final double priceFcfa;
  final int totalSeats;
  final int remainingSeats;
  final String? instructions;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final String? publisherDisplayName;
  final bool publisherVerified;
  final String? vehicleType;
  final int? vehicleCapacity;
  final double? departureLat;
  final double? departureLon;
  final String? vehiclePhotoUrl;

  const IntercityAnnouncementModel({
    required this.id,
    required this.publisherProfileId,
    this.vehicleId,
    required this.departureCity,
    required this.destinationCity,
    this.departureQuarter,
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

  factory IntercityAnnouncementModel.fromJson(Map<String, dynamic> json) {
    return IntercityAnnouncementModel(
      id: json['id'] as String,
      publisherProfileId: json['publisherProfileId'] as String? ?? '',
      vehicleId: json['vehicleId'] as String?,
      departureCity: json['departureCity'] as String? ?? '',
      destinationCity: json['destinationCity'] as String? ?? '',
      departureQuarter: json['departureQuarter'] as String?,
      departureDate: json['departureDate'] as String? ?? '',
      departureTime: json['departureTime'] as String? ?? '00:00:00',
      priceFcfa: (json['priceFcfa'] as num?)?.toDouble() ?? 0,
      totalSeats: (json['totalSeats'] as num?)?.toInt() ?? 0,
      remainingSeats: (json['remainingSeats'] as num?)?.toInt() ?? 0,
      instructions: json['instructions'] as String?,
      status: json['status'] as String? ?? 'UNKNOWN',
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      publisherDisplayName: json['publisherDisplayName'] as String?,
      publisherVerified: json['publisherVerified'] as bool? ?? false,
      vehicleType: json['vehicleType'] as String?,
      vehicleCapacity: (json['vehicleCapacity'] as num?)?.toInt(),
      departureLat: (json['departureLat'] as num?)?.toDouble(),
      departureLon: (json['departureLon'] as num?)?.toDouble(),
      vehiclePhotoUrl: json['vehiclePhotoUrl'] as String?,
    );
  }

  IntercityAnnouncement toEntity() {
    return IntercityAnnouncement(
      id: id,
      publisherProfileId: publisherProfileId,
      vehicleId: vehicleId,
      departureCity: departureCity,
      destinationCity: destinationCity,
      departureQuarter: departureQuarter,
      departureDate: DateTime.tryParse(departureDate) ?? DateTime.now(),
      departureTime: departureTime,
      priceFcfa: priceFcfa,
      totalSeats: totalSeats,
      remainingSeats: remainingSeats,
      instructions: instructions,
      status: AnnouncementStatus.fromApi(status),
      createdAt: createdAt == null ? null : DateTime.tryParse(createdAt!),
      updatedAt: updatedAt == null ? null : DateTime.tryParse(updatedAt!),
      publisherDisplayName: publisherDisplayName,
      publisherVerified: publisherVerified,
      vehicleType: vehicleType,
      vehicleCapacity: vehicleCapacity,
      departureLat: departureLat,
      departureLon: departureLon,
      vehiclePhotoUrl: vehiclePhotoUrl,
    );
  }
}

class WideningSuggestionModel {
  final String code;
  final String message;
  final Map<String, dynamic> suggestedQuery;

  const WideningSuggestionModel({
    required this.code,
    required this.message,
    required this.suggestedQuery,
  });

  factory WideningSuggestionModel.fromJson(Map<String, dynamic> json) {
    final rawQuery = json['suggestedQuery'];
    return WideningSuggestionModel(
      code: json['code'] as String? ?? '',
      message: json['message'] as String? ?? '',
      suggestedQuery: rawQuery is Map
          ? Map<String, dynamic>.from(rawQuery)
          : <String, dynamic>{},
    );
  }

  WideningSuggestion toEntity() {
    return WideningSuggestion(code: code, message: message, suggestedQuery: suggestedQuery);
  }
}

class AnnouncementSearchPageModel {
  final List<IntercityAnnouncementModel> items;
  final int page;
  final int size;
  final bool hasMore;
  final List<WideningSuggestionModel> wideningSuggestions;

  const AnnouncementSearchPageModel({
    required this.items,
    required this.page,
    required this.size,
    required this.hasMore,
    this.wideningSuggestions = const [],
  });

  factory AnnouncementSearchPageModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final rawSuggestions = json['wideningSuggestions'] as List<dynamic>? ?? [];
    return AnnouncementSearchPageModel(
      items: rawItems
          .map((item) => IntercityAnnouncementModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      page: (json['page'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 20,
      hasMore: json['hasMore'] as bool? ?? false,
      wideningSuggestions: rawSuggestions
          .map((item) => WideningSuggestionModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }

  AnnouncementSearchResult toEntity() {
    return AnnouncementSearchResult(
      items: items.map((item) => item.toEntity()).toList(),
      page: page,
      size: size,
      hasMore: hasMore,
      wideningSuggestions: wideningSuggestions.map((item) => item.toEntity()).toList(),
    );
  }
}

class AnnouncementPageModel {
  final List<IntercityAnnouncementModel> items;
  final int page;
  final int size;
  final bool hasMore;

  const AnnouncementPageModel({
    required this.items,
    required this.page,
    required this.size,
    required this.hasMore,
  });

  factory AnnouncementPageModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return AnnouncementPageModel(
      items: rawItems
          .map((item) => IntercityAnnouncementModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      page: (json['page'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 20,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  AnnouncementPage toEntity() {
    return AnnouncementPage(
      items: items.map((item) => item.toEntity()).toList(),
      page: page,
      size: size,
      hasMore: hasMore,
    );
  }
}

class IntercityBookingModel {
  final String id;
  final String announcementId;
  final String passengerProfileId;
  final String? tripId;
  final String status;
  final int seatsRequested;
  final String contactPhone;
  final String? requestedAt;
  final String? confirmedAt;
  final String? cancelledAt;
  final String? expiresAt;
  final String? cancellationReason;

  const IntercityBookingModel({
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

  factory IntercityBookingModel.fromJson(Map<String, dynamic> json) {
    return IntercityBookingModel(
      id: json['id'] as String,
      announcementId: json['announcementId'] as String? ?? '',
      passengerProfileId: json['passengerProfileId'] as String? ?? '',
      tripId: json['tripId'] as String?,
      status: json['status'] as String? ?? 'UNKNOWN',
      seatsRequested: (json['seatsRequested'] as num?)?.toInt() ?? 1,
      contactPhone: json['contactPhone'] as String? ?? '',
      requestedAt: json['requestedAt'] as String?,
      confirmedAt: json['confirmedAt'] as String?,
      cancelledAt: json['cancelledAt'] as String?,
      expiresAt: json['expiresAt'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
    );
  }

  IntercityBooking toEntity() {
    return IntercityBooking(
      id: id,
      announcementId: announcementId,
      passengerProfileId: passengerProfileId,
      tripId: tripId,
      status: IntercityBookingStatus.fromApi(status),
      seatsRequested: seatsRequested,
      contactPhone: contactPhone,
      requestedAt: requestedAt == null ? null : DateTime.tryParse(requestedAt!),
      confirmedAt: confirmedAt == null ? null : DateTime.tryParse(confirmedAt!),
      cancelledAt: cancelledAt == null ? null : DateTime.tryParse(cancelledAt!),
      expiresAt: expiresAt == null ? null : DateTime.tryParse(expiresAt!),
      cancellationReason: cancellationReason,
    );
  }
}

class BookingPageModel {
  final List<IntercityBookingModel> items;
  final int page;
  final int size;
  final bool hasMore;

  const BookingPageModel({
    required this.items,
    required this.page,
    required this.size,
    required this.hasMore,
  });

  factory BookingPageModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return BookingPageModel(
      items: rawItems
          .map((item) => IntercityBookingModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      page: (json['page'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 20,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  BookingPage toEntity() {
    return BookingPage(
      items: items.map((item) => item.toEntity()).toList(),
      page: page,
      size: size,
      hasMore: hasMore,
    );
  }
}

class IntercityVehicleModel {
  final String id;
  final String ownerProfileId;
  final String type;
  final int? capacity;
  final String validationStatus;
  final bool active;
  final String photoUrl;

  const IntercityVehicleModel({
    required this.id,
    required this.ownerProfileId,
    required this.type,
    this.capacity,
    required this.validationStatus,
    required this.active,
    required this.photoUrl,
  });

  factory IntercityVehicleModel.fromJson(Map<String, dynamic> json) {
    return IntercityVehicleModel(
      id: json['id'] as String,
      ownerProfileId: json['ownerProfileId'] as String? ?? '',
      type: json['type'] as String? ?? '',
      capacity: (json['capacity'] as num?)?.toInt(),
      validationStatus: json['validationStatus'] as String? ?? 'UNKNOWN',
      active: json['active'] as bool? ?? false,
      photoUrl: json['photoUrl'] as String? ?? '',
    );
  }

  IntercityVehicle toEntity() {
    return IntercityVehicle(
      id: id,
      ownerProfileId: ownerProfileId,
      type: type,
      capacity: capacity,
      validationStatus: validationStatus,
      active: active,
      photoUrl: photoUrl,
    );
  }
}

// Role : Construit le corps JSON pour POST /intercity/announcements.
class CreateAnnouncementPayload {
  final String departureCity;
  final String destinationCity;
  final String? departureQuarter;
  final double? departureLat;
  final double? departureLon;
  final double? destinationLat;
  final double? destinationLon;
  final DateTime departureDate;
  final String departureTime;
  final double priceFcfa;
  final int totalSeats;
  final String vehicleId;
  final String? instructions;

  const CreateAnnouncementPayload({
    required this.departureCity,
    required this.destinationCity,
    this.departureQuarter,
    this.departureLat,
    this.departureLon,
    this.destinationLat,
    this.destinationLon,
    required this.departureDate,
    required this.departureTime,
    required this.priceFcfa,
    required this.totalSeats,
    required this.vehicleId,
    this.instructions,
  });

  Map<String, dynamic> toJson() {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    final isoDate =
        '${departureDate.year.toString().padLeft(4, '0')}-${twoDigits(departureDate.month)}-${twoDigits(departureDate.day)}';
    return {
      'departureCity': departureCity,
      'destinationCity': destinationCity,
      if (departureQuarter != null && departureQuarter!.isNotEmpty) 'departureQuarter': departureQuarter,
      if (departureLat != null && departureLon != null)
        'departurePoint': {'latitude': departureLat, 'longitude': departureLon},
      if (destinationLat != null && destinationLon != null)
        'destinationPoint': {'latitude': destinationLat, 'longitude': destinationLon},
      'departureDate': isoDate,
      'departureTime': departureTime,
      'priceFcfa': priceFcfa,
      'totalSeats': totalSeats,
      'vehicleId': vehicleId,
      if (instructions != null && instructions!.isNotEmpty) 'instructions': instructions,
    };
  }
}
