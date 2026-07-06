import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_template_app/core/error/failure.dart';
import 'package:flutter_template_app/features/example/data/repositories/example_repository_impl.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_data.dart';

void main() {
  late ExampleRepositoryImpl repository;
  late MockExampleRemoteDataSource mockRemote;
  late MockNetworkInfo mockNetwork;

  setUp(() {
    mockRemote = MockExampleRemoteDataSource();
    mockNetwork = MockNetworkInfo();
    repository = ExampleRepositoryImpl(mockRemote, mockNetwork);
  });

  group('getExamples', () {
    group('when device is connected', () {
      setUp(() {
        when(() => mockNetwork.isConnected).thenAnswer((_) async => true);
      });

      test('should return list of entities when remote call succeeds', () async {
        when(() => mockRemote.getExamples()).thenAnswer((_) async => TestData.tExampleModels);

        final result = await repository.getExamples();

        expect(result.isRight(), isTrue);
        result.fold((_) => fail('Should have returned data'), (entities) {
          expect(entities.length, TestData.tExampleModels.length);
          expect(entities.first.id, TestData.tExampleModels.first.id);
          expect(entities.first.title, TestData.tExampleModels.first.title);
        });
        verify(() => mockRemote.getExamples()).called(1);
      });

      test('should return ServerFailure when remote call throws', () async {
        when(() => mockRemote.getExamples()).thenThrow(Exception('API error'));

        final result = await repository.getExamples();

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Should have returned a failure'),
        );
      });

      test('should return empty list when remote returns empty', () async {
        when(() => mockRemote.getExamples()).thenAnswer((_) async => []);

        final result = await repository.getExamples();

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Should have returned data'),
          (entities) => expect(entities, isEmpty),
        );
      });
    });

    group('when device is NOT connected', () {
      setUp(() {
        when(() => mockNetwork.isConnected).thenAnswer((_) async => false);
      });

      test('should return NetworkFailure without calling remote', () async {
        final result = await repository.getExamples();

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Should have returned NetworkFailure'),
        );
        verifyNever(() => mockRemote.getExamples());
      });
    });
  });

  group('getExampleById', () {
    test('should return entity when remote call succeeds', () async {
      when(() => mockRemote.getExampleById(any())).thenAnswer((_) async => TestData.tExampleModel);

      final result = await repository.getExampleById('test-id-1');

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should have returned data'),
        (entity) => expect(entity.id, 'test-id-1'),
      );
    });

    test('should return ServerFailure when remote call throws', () async {
      when(() => mockRemote.getExampleById(any())).thenThrow(Exception('not found'));

      final result = await repository.getExampleById('bad-id');

      expect(result.isLeft(), isTrue);
    });
  });

  group('createExample', () {
    test('should return created entity on success', () async {
      when(
        () => mockRemote.createExample(
          title: any(named: 'title'),
          description: any(named: 'description'),
        ),
      ).thenAnswer((_) async => TestData.tExampleModel);

      final result = await repository.createExample(title: 'New', description: 'Desc');

      expect(result.isRight(), isTrue);
    });

    test('should return ServerFailure on exception', () async {
      when(
        () => mockRemote.createExample(
          title: any(named: 'title'),
          description: any(named: 'description'),
        ),
      ).thenThrow(Exception('creation failed'));

      final result = await repository.createExample(title: 'New', description: 'Desc');

      expect(result.isLeft(), isTrue);
    });
  });
}
