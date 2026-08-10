import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/core/network/network_info.dart';
import 'package:motodi_go_mobile/features/auth/data/models/api_error_model.dart';
import 'package:motodi_go_mobile/features/intercity/data/datasources/intercity_remote_datasource.dart';
import 'package:motodi_go_mobile/features/intercity/data/models/intercity_models.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_announcement.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_booking.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_vehicle.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/search_filters.dart';
import 'package:motodi_go_mobile/features/intercity/domain/repositories/intercity_repository.dart';

@LazySingleton(as: IntercityRepository)
class IntercityRepositoryImpl implements IntercityRepository {
  final IntercityRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  IntercityRepositoryImpl(this._remoteDataSource, this._networkInfo);

  @override
  Future<Either<Failure, AnnouncementSearchResult>> searchAnnouncements(
    SearchFilters filters, {
    int page = 0,
    int size = 20,
  }) {
    return _guard(() async {
      final model = await _remoteDataSource.searchAnnouncements(filters, page: page, size: size);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, AnnouncementPage>> listMyAnnouncements({int page = 0, int size = 20}) {
    return _guard(() async {
      final model = await _remoteDataSource.listMyAnnouncements(page: page, size: size);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, IntercityAnnouncement>> getAnnouncement(String id) {
    return _guard(() async {
      final model = await _remoteDataSource.getAnnouncement(id);
      return model.toEntity();
    });
  }

  @override
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
  }) {
    return _guard(() async {
      final model = await _remoteDataSource.createAnnouncement(
        CreateAnnouncementPayload(
          departureCity: departureCity,
          destinationCity: destinationCity,
          departureQuarter: departureQuarter,
          departureLat: departureLat,
          departureLon: departureLon,
          destinationLat: destinationLat,
          destinationLon: destinationLon,
          departureDate: departureDate,
          departureTime: departureTime,
          priceFcfa: priceFcfa,
          totalSeats: totalSeats,
          vehicleId: vehicleId,
          instructions: instructions,
        ),
      );
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, IntercityAnnouncement>> closeAnnouncement(String id) {
    return _guard(() async {
      final model = await _remoteDataSource.closeAnnouncement(id);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, IntercityAnnouncement>> cancelAnnouncement(String id) {
    return _guard(() async {
      final model = await _remoteDataSource.cancelAnnouncement(id);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, IntercityBooking>> createBooking({
    required String announcementId,
    required int seatsRequested,
    required String contactPhone,
  }) {
    return _guard(() async {
      final model = await _remoteDataSource.createBooking(
        announcementId,
        seatsRequested: seatsRequested,
        contactPhone: contactPhone,
      );
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, BookingPage>> listAnnouncementBookings(
    String announcementId, {
    int page = 0,
    int size = 20,
  }) {
    return _guard(() async {
      final model = await _remoteDataSource.listAnnouncementBookings(announcementId, page: page, size: size);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, BookingPage>> listMyBookings({int page = 0, int size = 20}) {
    return _guard(() async {
      final model = await _remoteDataSource.listMyBookings(page: page, size: size);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, IntercityBooking>> getBooking(String id) {
    return _guard(() async {
      final model = await _remoteDataSource.getBooking(id);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, IntercityBooking>> confirmBooking(String id) {
    return _guard(() async {
      final model = await _remoteDataSource.confirmBooking(id);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, IntercityBooking>> cancelBooking(String id, String cancellationReason) {
    return _guard(() async {
      final model = await _remoteDataSource.cancelBooking(id, cancellationReason);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, List<IntercityVehicle>>> listMyVehicles() {
    return _guard(() async {
      final models = await _remoteDataSource.listMyVehicles();
      return models.map((model) => model.toEntity()).toList();
    });
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    if (!await _networkInfo.isConnected) {
      return left(const NetworkFailure('Pas de connexion internet.', code: 'NETWORK_OFFLINE'));
    }
    try {
      return right(await action());
    } catch (e) {
      return left(_failureFromException(e));
    }
  }

  Failure _failureFromException(Object error) {
    if (error is ApiException) {
      return switch (error.code) {
        'VALIDATION_FAILED' ||
        'BOOKING_NOT_AVAILABLE' ||
        'NO_SEAT_AVAILABLE' ||
        'BOOKING_NOT_CANCELLABLE' => ValidationFailure(error.message, code: error.code),
        'SESSION_EXPIRED' ||
        'BOOKING_FORBIDDEN' ||
        'PROFILE_NOT_ALLOWED' => AuthFailure(error.message, code: error.code),
        _ => ServerFailure(error.message, code: error.code),
      };
    }
    return ServerFailure(error.toString());
  }
}
