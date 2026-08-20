import 'package:motodi_go_mobile/features/intercity/data/models/intercity_models.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_announcement.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_booking.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_vehicle.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/user_profile.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';

Map<String, dynamic> announcementJson({
  String id = 'ann-1',
  String status = 'PUBLISHED',
  int remainingSeats = 2,
}) {
  return {
    'id': id,
    'publisherProfileId': 'pub-1',
    'vehicleId': 'veh-1',
    'departureCity': 'Yaoundé',
    'destinationCity': 'Douala',
    'ptRamassage': 'Bastos',
    'departureDate': '2026-08-21',
    'departureTime': '08:30:00',
    'priceFcfa': 7500,
    'totalSeats': 4,
    'remainingSeats': remainingSeats,
    'instructions': 'Être à l heure',
    'status': status,
    'createdAt': '2026-08-20T10:00:00.000Z',
    'updatedAt': '2026-08-20T10:00:00.000Z',
    'publisherDisplayName': 'Ibrahim M.',
    'publisherVerified': true,
    'vehicleType': 'MINIBUS',
    'vehicleCapacity': 18,
    'departureLat': 3.87,
    'departureLon': 11.52,
    'vehiclePhotoUrl': 'https://cdn.example/v.jpg',
  };
}

Map<String, dynamic> bookingJson({String id = 'book-1', String status = 'PENDING'}) {
  return {
    'id': id,
    'announcementId': 'ann-1',
    'passengerProfileId': 'pass-1',
    'tripId': 'trip-1',
    'status': status,
    'seatsRequested': 2,
    'contactPhone': '+237699001122',
    'requestedAt': '2026-08-20T11:00:00.000Z',
    'confirmedAt': null,
    'cancelledAt': null,
    'expiresAt': '2026-08-21T08:00:00.000Z',
    'cancellationReason': null,
    'passengerDisplayName': 'Marie Nguema',
  };
}

Map<String, dynamic> vehicleJson({
  String id = 'veh-1',
  String validationStatus = 'VALIDATED',
  bool active = true,
}) {
  return {
    'id': id,
    'ownerProfileId': 'pub-1',
    'type': 'MINIBUS',
    'capacity': 18,
    'validationStatus': validationStatus,
    'active': active,
    'photoUrl': 'https://cdn.example/v.jpg',
  };
}

IntercityAnnouncement announcementEntity({
  String id = 'ann-1',
  AnnouncementStatus status = AnnouncementStatus.published,
}) {
  return IntercityAnnouncementModel.fromJson(
    announcementJson(id: id, status: status.apiValue),
  ).toEntity();
}

IntercityBooking bookingEntity({
  String id = 'book-1',
  IntercityBookingStatus status = IntercityBookingStatus.pending,
}) {
  return IntercityBookingModel.fromJson(bookingJson(id: id, status: status.apiValue)).toEntity();
}

IntercityVehicle vehicleEntity({String id = 'veh-1', bool usable = true}) {
  return IntercityVehicleModel.fromJson(
    vehicleJson(id: id, validationStatus: usable ? 'VALIDATED' : 'PENDING', active: usable),
  ).toEntity();
}

UserProfile publisherProfile({
  ProfileType type = ProfileType.mototaxi,
  ValidationStatus validation = ValidationStatus.validated,
}) {
  return UserProfile(
    id: 'pub-1',
    userId: 'user-1',
    type: type,
    validationStatus: validation,
    displayName: 'Ibrahim',
    averageRating: 4.5,
    active: true,
    allowedActions: const [],
  );
}
