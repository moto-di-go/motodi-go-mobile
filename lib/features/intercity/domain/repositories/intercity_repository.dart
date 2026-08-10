import 'package:fpdart/fpdart.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_announcement.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_booking.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_vehicle.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/search_filters.dart';

abstract class IntercityRepository {
  Future<Either<Failure, AnnouncementSearchResult>> searchAnnouncements(
    SearchFilters filters, {
    int page = 0,
    int size = 20,
  });

  Future<Either<Failure, AnnouncementPage>> listMyAnnouncements({int page = 0, int size = 20});

  Future<Either<Failure, IntercityAnnouncement>> getAnnouncement(String id);

  Future<Either<Failure, IntercityAnnouncement>> createAnnouncement({
    required String departureCity,
    required String destinationCity,
    String? departureQuarter,
    double? departureLat,
    double? departureLon,
    double? destinationLat,
    double? destinationLon,
    required DateTime departureDate,
    required String departureTime,
    required double priceFcfa,
    required int totalSeats,
    required String vehicleId,
    String? instructions,
  });

  Future<Either<Failure, IntercityAnnouncement>> closeAnnouncement(String id);

  Future<Either<Failure, IntercityAnnouncement>> cancelAnnouncement(String id);

  Future<Either<Failure, IntercityBooking>> createBooking({
    required String announcementId,
    required int seatsRequested,
    required String contactPhone,
  });

  Future<Either<Failure, BookingPage>> listAnnouncementBookings(
    String announcementId, {
    int page = 0,
    int size = 20,
  });

  Future<Either<Failure, BookingPage>> listMyBookings({int page = 0, int size = 20});

  Future<Either<Failure, IntercityBooking>> getBooking(String id);

  Future<Either<Failure, IntercityBooking>> confirmBooking(String id);

  Future<Either<Failure, IntercityBooking>> cancelBooking(String id, String cancellationReason);

  Future<Either<Failure, List<IntercityVehicle>>> listMyVehicles();
}
