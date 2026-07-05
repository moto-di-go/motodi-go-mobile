import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_template_app/core/error/failure.dart';
import 'package:flutter_template_app/features/example/domain/usecases/get_examples_usecase.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_data.dart';

void main() {
  late GetExamplesUseCase useCase;
  late MockExampleRepository mockRepository;

  setUp(() {
    mockRepository = MockExampleRepository();
    useCase = GetExamplesUseCase(mockRepository);
  });

  group('GetExamplesUseCase', () {
    test('should return list of ExampleEntity when repository succeeds', () async {
      when(
        () => mockRepository.getExamples(),
      ).thenAnswer((_) async => right(TestData.tExampleEntities));

      final result = await useCase();

      expect(result, right(TestData.tExampleEntities));
      verify(() => mockRepository.getExamples()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository fails', () async {
      when(
        () => mockRepository.getExamples(),
      ).thenAnswer((_) async => left(const ServerFailure('Erreur API')));

      final result = await useCase();

      expect(result, left(const ServerFailure('Erreur API')));
      verify(() => mockRepository.getExamples()).called(1);
    });

    test('should return NetworkFailure when no connectivity', () async {
      when(
        () => mockRepository.getExamples(),
      ).thenAnswer((_) async => left(const NetworkFailure('Pas de réseau')));

      final result = await useCase();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should have returned a failure'),
      );
    });

    test('should delegate call to repository exactly once', () async {
      when(() => mockRepository.getExamples()).thenAnswer((_) async => right([]));

      await useCase();

      verify(() => mockRepository.getExamples()).called(1);
    });
  });
}
