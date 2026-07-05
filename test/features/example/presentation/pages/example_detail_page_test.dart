import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_template_app/di/injection.dart';
import 'package:flutter_template_app/features/example/presentation/bloc/example_bloc.dart';
import 'package:flutter_template_app/features/example/presentation/pages/example_detail_page.dart';

import '../../../../helpers/test_data.dart';

class _MockExampleBloc extends MockBloc<ExampleEvent, ExampleState> implements ExampleBloc {}

void main() {
  late _MockExampleBloc mockBloc;

  setUp(() {
    mockBloc = _MockExampleBloc();
    getIt.reset();
    getIt.registerSingleton<ExampleBloc>(mockBloc);
  });

  tearDown(getIt.reset);

  group('ExampleDetailPage', () {
    testWidgets('affiche le titre et la description de l\'élément trouvé', (tester) async {
      when(
        () => mockBloc.state,
      ).thenReturn(ExampleState(status: ExampleStatus.success, items: TestData.tExampleEntities));
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        MaterialApp(
          home: ExampleDetailPage(itemId: TestData.tExampleEntity.id, bloc: mockBloc),
        ),
      );

      expect(find.text(TestData.tExampleEntity.title), findsOneWidget);
      expect(find.text(TestData.tExampleEntity.description), findsOneWidget);
    });

    testWidgets('affiche le bon élément parmi plusieurs', (tester) async {
      when(
        () => mockBloc.state,
      ).thenReturn(ExampleState(status: ExampleStatus.success, items: TestData.tExampleEntities));
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        MaterialApp(
          home: ExampleDetailPage(itemId: TestData.tExampleEntity2.id, bloc: mockBloc),
        ),
      );

      expect(find.text(TestData.tExampleEntity2.title), findsOneWidget);
      expect(find.text(TestData.tExampleEntity2.description), findsOneWidget);
      expect(find.text(TestData.tExampleEntity.title), findsNothing);
    });

    testWidgets('affiche "Element non trouvé" si l\'id est absent', (tester) async {
      when(
        () => mockBloc.state,
      ).thenReturn(const ExampleState(status: ExampleStatus.success, items: []));
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        MaterialApp(
          home: ExampleDetailPage(itemId: 'id-inexistant', bloc: mockBloc),
        ),
      );

      expect(find.text('Element non trouvé'), findsOneWidget);
    });

    testWidgets('affiche "Element non trouvé" quand la liste est vide', (tester) async {
      when(() => mockBloc.state).thenReturn(const ExampleState(status: ExampleStatus.initial));
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        MaterialApp(
          home: ExampleDetailPage(itemId: 'test-id-1', bloc: mockBloc),
        ),
      );

      expect(find.text('Element non trouvé'), findsOneWidget);
    });
  });
}
