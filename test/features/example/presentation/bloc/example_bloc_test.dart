import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_template_app/core/error/failure.dart';
import 'package:flutter_template_app/features/example/presentation/bloc/example_bloc.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_data.dart';

void main() {
  late ExampleBloc bloc;
  late MockGetExamplesUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockGetExamplesUseCase();
    bloc = ExampleBloc(mockUseCase);
  });

  tearDown(() => bloc.close());

  group('ExampleBloc — état initial', () {
    test('initial state should be ExampleState.initial', () {
      expect(bloc.state, const ExampleState());
      expect(bloc.state.status, ExampleStatus.initial);
      expect(bloc.state.items, isEmpty);
      expect(bloc.state.errorMessage, isNull);
    });
  });

  group('GetExamplesRequested', () {
    blocTest<ExampleBloc, ExampleState>(
      'emit [loading, success] when use case returns data',
      build: () {
        when(() => mockUseCase()).thenAnswer((_) async => right(TestData.tExampleEntities));
        return bloc;
      },
      act: (b) => b.add(const GetExamplesRequested()),
      expect: () => [
        const ExampleState(status: ExampleStatus.loading),
        ExampleState(status: ExampleStatus.success, items: TestData.tExampleEntities),
      ],
      verify: (_) => verify(() => mockUseCase()).called(1),
    );

    blocTest<ExampleBloc, ExampleState>(
      'emit [loading, success] with empty list when use case returns empty',
      build: () {
        when(() => mockUseCase()).thenAnswer((_) async => right([]));
        return bloc;
      },
      act: (b) => b.add(const GetExamplesRequested()),
      expect: () => [
        const ExampleState(status: ExampleStatus.loading),
        const ExampleState(status: ExampleStatus.success, items: []),
      ],
    );

    blocTest<ExampleBloc, ExampleState>(
      'emit [loading, failure] when use case returns ServerFailure',
      build: () {
        when(() => mockUseCase()).thenAnswer((_) async => left(const ServerFailure('Erreur API')));
        return bloc;
      },
      act: (b) => b.add(const GetExamplesRequested()),
      expect: () => [
        const ExampleState(status: ExampleStatus.loading),
        const ExampleState(status: ExampleStatus.failure, errorMessage: 'Erreur API'),
      ],
    );

    blocTest<ExampleBloc, ExampleState>(
      'emit [loading, failure] when use case returns NetworkFailure',
      build: () {
        when(
          () => mockUseCase(),
        ).thenAnswer((_) async => left(const NetworkFailure('Pas de réseau')));
        return bloc;
      },
      act: (b) => b.add(const GetExamplesRequested()),
      expect: () => [
        const ExampleState(status: ExampleStatus.loading),
        const ExampleState(status: ExampleStatus.failure, errorMessage: 'Pas de réseau'),
      ],
    );
  });

  group('ExampleRefreshRequested', () {
    blocTest<ExampleBloc, ExampleState>(
      'emit [loading, success] when refresh succeeds',
      build: () {
        when(() => mockUseCase()).thenAnswer((_) async => right(TestData.tExampleEntities));
        return bloc;
      },
      act: (b) => b.add(const ExampleRefreshRequested()),
      expect: () => [
        const ExampleState(status: ExampleStatus.loading),
        ExampleState(status: ExampleStatus.success, items: TestData.tExampleEntities),
      ],
    );

    blocTest<ExampleBloc, ExampleState>(
      'should call use case exactly once when refreshing',
      build: () {
        when(() => mockUseCase()).thenAnswer((_) async => right([]));
        return bloc;
      },
      act: (b) => b.add(const ExampleRefreshRequested()),
      verify: (_) => verify(() => mockUseCase()).called(1),
    );
  });

  group('ExampleState helpers', () {
    test('isLoading should be true when status is loading', () {
      const state = ExampleState(status: ExampleStatus.loading);
      expect(state.isLoading, isTrue);
      expect(state.isSuccess, isFalse);
      expect(state.isFailure, isFalse);
    });

    test('isSuccess should be true when status is success', () {
      const state = ExampleState(status: ExampleStatus.success);
      expect(state.isSuccess, isTrue);
      expect(state.isLoading, isFalse);
    });

    test('isFailure should be true when status is failure', () {
      const state = ExampleState(status: ExampleStatus.failure, errorMessage: 'err');
      expect(state.isFailure, isTrue);
      expect(state.errorMessage, 'err');
    });

    test('copyWith should update only specified fields', () {
      const initial = ExampleState(status: ExampleStatus.loading);
      final updated = initial.copyWith(
        status: ExampleStatus.success,
        items: TestData.tExampleEntities,
      );
      expect(updated.status, ExampleStatus.success);
      expect(updated.items, TestData.tExampleEntities);
      expect(updated.errorMessage, isNull);
    });

    test('Equatable — two identical states should be equal', () {
      final s1 = ExampleState(status: ExampleStatus.success, items: TestData.tExampleEntities);
      final s2 = ExampleState(status: ExampleStatus.success, items: TestData.tExampleEntities);
      expect(s1, equals(s2));
    });

    test('Equatable — states with different status should NOT be equal', () {
      const s1 = ExampleState(status: ExampleStatus.loading);
      const s2 = ExampleState(status: ExampleStatus.success);
      expect(s1, isNot(equals(s2)));
    });
  });
}
