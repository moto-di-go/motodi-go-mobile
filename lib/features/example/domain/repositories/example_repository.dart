import 'package:fpdart/fpdart.dart';
import 'package:flutter_template_app/core/error/failure.dart';
import 'package:flutter_template_app/features/example/domain/entities/example_entity.dart';

// Rôle : Contrat (interface) du repository — défini dans le domaine, implémenté dans la data layer.
// L'utilisation de Either<Failure, T> permet de gérer les erreurs de façon fonctionnelle.
abstract class ExampleRepository {
  Future<Either<Failure, List<ExampleEntity>>> getExamples();
  Future<Either<Failure, ExampleEntity>> getExampleById(String id);
  Future<Either<Failure, ExampleEntity>> createExample({
    required String title,
    required String description,
  });
  Future<Either<Failure, void>> deleteExample(String id);
}
