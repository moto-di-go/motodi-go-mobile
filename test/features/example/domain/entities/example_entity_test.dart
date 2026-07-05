import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_template_app/features/example/domain/entities/example_entity.dart';

void main() {
  final tDateTime = DateTime(2024, 1, 1);

  group('ExampleEntity', () {
    test('should be equal when all properties are identical (Equatable)', () {
      final entity1 = ExampleEntity(
        id: '1',
        title: 'Test',
        description: 'Desc',
        createdAt: tDateTime,
      );
      final entity2 = ExampleEntity(
        id: '1',
        title: 'Test',
        description: 'Desc',
        createdAt: tDateTime,
      );
      expect(entity1, equals(entity2));
    });

    test('should NOT be equal when id differs', () {
      final entity1 = ExampleEntity(id: '1', title: 'T', description: 'D', createdAt: tDateTime);
      final entity2 = ExampleEntity(id: '2', title: 'T', description: 'D', createdAt: tDateTime);
      expect(entity1, isNot(equals(entity2)));
    });

    test('should NOT be equal when title differs', () {
      final entity1 = ExampleEntity(id: '1', title: 'A', description: 'D', createdAt: tDateTime);
      final entity2 = ExampleEntity(id: '1', title: 'B', description: 'D', createdAt: tDateTime);
      expect(entity1, isNot(equals(entity2)));
    });

    test('props should contain all fields', () {
      final entity = ExampleEntity(id: '1', title: 'T', description: 'D', createdAt: tDateTime);
      expect(entity.props, [entity.id, entity.title, entity.description, entity.createdAt]);
    });
  });
}
