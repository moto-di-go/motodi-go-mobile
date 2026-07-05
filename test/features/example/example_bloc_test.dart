import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_template_app/features/example/domain/entities/example_entity.dart';
import 'package:flutter_template_app/features/example/domain/usecases/get_examples_usecase.dart';
import 'package:flutter_template_app/features/example/presentation/bloc/example_bloc.dart';

class MockGetExamplesUseCase extends Mock implements GetExamplesUseCase {}

void main() {
  late ExampleBloc bloc;
  late MockGetExamplesUseCase mockUseCase;

  final tItems = [
    ExampleEntity(id: '1', title: 'Test', description: 'Desc', createdAt: DateTime(2024)),
  ];

  setUp(() {
    mockUseCase = MockGetExamplesUseCase();
    bloc = ExampleBloc(mockUseCase);
  });

  tearDown(() => bloc.close());

  group('GetExamplesRequested', () {
    blocTest<ExampleBloc, ExampleState>(
      'emit [loading, success] when use case succeeds',
      build: () {
        when(() => mockUseCase()).thenAnswer((_) async => right(tItems));
        return bloc;
      },
      act: (b) => b.add(const GetExamplesRequested()),
      expect: () => [
        const ExampleState(status: ExampleStatus.loading),
        ExampleState(status: ExampleStatus.success, items: tItems),
      ],
    );
  });
}
