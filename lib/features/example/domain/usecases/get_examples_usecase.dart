import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/features/example/domain/entities/example_entity.dart';
import 'package:motodi_go_mobile/features/example/domain/repositories/example_repository.dart';

// Rôle : Use case qui encapsule la logique métier de récupération des exemples.
// Chaque action métier = 1 use case = 1 fichier.
@lazySingleton
class GetExamplesUseCase {
  final ExampleRepository _repository;

  GetExamplesUseCase(this._repository);

  Future<Either<Failure, List<ExampleEntity>>> call() {
    return _repository.getExamples();
  }
}
