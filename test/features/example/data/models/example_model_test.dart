import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_template_app/features/example/data/models/example_model.dart';
import 'package:flutter_template_app/features/example/domain/entities/example_entity.dart';

import '../../../../helpers/test_data.dart';

void main() {
  group('ExampleModel', () {
    final tJson = {
      'id': 'test-id-1',
      'title': 'Titre de test',
      'description': 'Description de test',
      'created_at': '2024-01-01T00:00:00.000',
    };

    test('fromJson should correctly parse JSON to ExampleModel', () {
      final model = ExampleModel.fromJson(tJson);
      expect(model.id, 'test-id-1');
      expect(model.title, 'Titre de test');
      expect(model.description, 'Description de test');
      expect(model.createdAt.year, 2024);
    });

    test('toJson should correctly serialize ExampleModel to Map', () {
      final json = TestData.tExampleModel.toJson();
      expect(json['id'], 'test-id-1');
      expect(json['title'], 'Titre de test');
      expect(json['description'], 'Description de test');
      expect(json.containsKey('created_at'), isTrue);
    });

    test('toEntity should convert model to correct entity', () {
      final entity = TestData.tExampleModel.toEntity();
      expect(entity, isA<ExampleEntity>());
      expect(entity.id, TestData.tExampleModel.id);
      expect(entity.title, TestData.tExampleModel.title);
      expect(entity.description, TestData.tExampleModel.description);
    });

    test('fromEntity should create model from entity', () {
      final model = ExampleModel.fromEntity(TestData.tExampleEntity);
      expect(model.id, TestData.tExampleEntity.id);
      expect(model.title, TestData.tExampleEntity.title);
    });

    test('fromJson then toEntity should preserve all data (round-trip)', () {
      final model = ExampleModel.fromJson(tJson);
      final entity = model.toEntity();
      expect(entity.id, tJson['id']);
      expect(entity.title, tJson['title']);
      expect(entity.description, tJson['description']);
    });
  });
}
