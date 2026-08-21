import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/core/network/network_info.dart';
import 'package:motodi_go_mobile/features/auth/data/models/api_error_model.dart';
import 'package:motodi_go_mobile/features/trips/data/datasources/trip_remote_datasource.dart';
import 'package:motodi_go_mobile/features/trips/domain/entities/trip.dart';
import 'package:motodi_go_mobile/features/trips/domain/repositories/trip_repository.dart';

@LazySingleton(as: TripRepository)
class TripRepositoryImpl implements TripRepository {
  final TripRemoteDataSource _remote;
  final NetworkInfo _networkInfo;

  TripRepositoryImpl(this._remote, this._networkInfo);

  @override
  Future<Either<Failure, List<Trip>>> getActiveTrips() {
    return _guard(() async {
      final models = await _remote.getActiveTrips();
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, Trip>> getTrip(String id) {
    return _guard(() async {
      final model = await _remote.getTrip(id);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, List<TripEvent>>> getTripEvents(String id) {
    return _guard(() async {
      final models = await _remote.getTripEvents(id);
      return models.map((m) => m.toEntity()).toList();
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
      return ServerFailure(error.message, code: error.code);
    }
    return ServerFailure(error.toString());
  }
}
