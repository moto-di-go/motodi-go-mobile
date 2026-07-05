import 'package:flutter_template_app/features/example/data/models/example_model.dart';
import 'package:flutter_template_app/features/example/domain/entities/example_entity.dart';

// Données de test réutilisables dans tous les fichiers de test.
// Importer via : import '../../helpers/test_data.dart';
class TestData {
  static final tDateTime = DateTime(2024, 1, 1);

  static final tExampleEntity = ExampleEntity(
    id: 'test-id-1',
    title: 'Titre de test',
    description: 'Description de test',
    createdAt: tDateTime,
  );

  static final tExampleEntity2 = ExampleEntity(
    id: 'test-id-2',
    title: 'Titre de test 2',
    description: 'Description de test 2',
    createdAt: tDateTime,
  );

  static final tExampleEntities = [tExampleEntity, tExampleEntity2];

  static final tExampleModel = ExampleModel(
    id: 'test-id-1',
    title: 'Titre de test',
    description: 'Description de test',
    createdAt: tDateTime,
  );

  static final tExampleModels = [
    tExampleModel,
    ExampleModel(
      id: 'test-id-2',
      title: 'Titre de test 2',
      description: 'Description de test 2',
      createdAt: tDateTime,
    ),
  ];
}
