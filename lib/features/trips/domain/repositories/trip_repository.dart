import 'package:fpdart/fpdart.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/features/trips/domain/entities/trip.dart';

abstract class TripRepository {
  Future<Either<Failure, List<Trip>>> getActiveTrips();

  Future<Either<Failure, Trip>> getTrip(String id);

  Future<Either<Failure, List<TripEvent>>> getTripEvents(String id);
}
