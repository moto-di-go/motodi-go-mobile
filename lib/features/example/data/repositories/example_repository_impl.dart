import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_template_app/core/error/failure.dart';
import 'package:flutter_template_app/core/network/network_info.dart';
import 'package:flutter_template_app/features/example/domain/entities/example_entity.dart';
import 'package:flutter_template_app/features/example/domain/repositories/example_repository.dart';
import 'package:flutter_template_app/features/example/data/datasources/example_remote_datasource.dart';

// Rôle : Implémentation du contrat ExampleRepository.
// Coordonne les datasources (remote/local) et transforme les échecs en Failure.
@LazySingleton(as: ExampleRepository)
class ExampleRepositoryImpl implements ExampleRepository {
  final ExampleRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  ExampleRepositoryImpl(this._remoteDataSource, this._networkInfo);

  @override
  Future<Either<Failure, List<ExampleEntity>>> getExamples() async {
    if (!await _networkInfo.isConnected) {
      return left(const NetworkFailure('Pas de connexion internet'));
    }
    try {
      final models = await _remoteDataSource.getExamples();
      return right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExampleEntity>> getExampleById(String id) async {
    try {
      final model = await _remoteDataSource.getExampleById(id);
      return right(model.toEntity());
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExampleEntity>> createExample({
    required String title,
    required String description,
  }) async {
    try {
      final model = await _remoteDataSource.createExample(title: title, description: description);
      return right(model.toEntity());
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExample(String id) async {
    try {
      // TODO: [TEMPLATE] Appeler _remoteDataSource.deleteExample(id)
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
