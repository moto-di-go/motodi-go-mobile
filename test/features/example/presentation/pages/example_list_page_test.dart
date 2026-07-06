import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_template_app/core/widgets/app_error_view.dart';
import 'package:flutter_template_app/core/widgets/app_loading.dart';
import 'package:flutter_template_app/di/injection.dart';
import 'package:flutter_template_app/features/example/presentation/bloc/example_bloc.dart';
import 'package:flutter_template_app/features/example/presentation/pages/example_list_page.dart';

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

  Widget buildApp() => MaterialApp(home: ExampleListPage(bloc: mockBloc));

  group('ExampleListPage', () {
    testWidgets('affiche AppLoading quand le statut est initial', (tester) async {
      when(() => mockBloc.state).thenReturn(const ExampleState());
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(buildApp());

      expect(find.byType(AppLoading), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('affiche AppLoading quand le statut est loading', (tester) async {
      when(() => mockBloc.state).thenReturn(const ExampleState(status: ExampleStatus.loading));
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(buildApp());

      expect(find.byType(AppLoading), findsOneWidget);
    });

    testWidgets('affiche la liste quand le statut est success', (tester) async {
      when(
        () => mockBloc.state,
      ).thenReturn(ExampleState(status: ExampleStatus.success, items: TestData.tExampleEntities));
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(buildApp());

      expect(find.byType(AppLoading), findsNothing);
      expect(find.byType(AppErrorView), findsNothing);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text(TestData.tExampleEntities.first.title), findsOneWidget);
      expect(find.text(TestData.tExampleEntities[1].title), findsOneWidget);
    });

    testWidgets('affiche une liste vide quand success sans items', (tester) async {
      when(() => mockBloc.state).thenReturn(const ExampleState(status: ExampleStatus.success));
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(buildApp());

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('affiche AppErrorView avec le message quand failure', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const ExampleState(status: ExampleStatus.failure, errorMessage: 'Erreur réseau'),
      );
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(buildApp());

      expect(find.byType(AppErrorView), findsOneWidget);
      expect(find.text('Erreur réseau'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('affiche le message par défaut si errorMessage est null', (tester) async {
      when(() => mockBloc.state).thenReturn(const ExampleState(status: ExampleStatus.failure));
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(buildApp());

      expect(find.byType(AppErrorView), findsOneWidget);
      expect(find.text('Une erreur est survenue'), findsOneWidget);
    });

    testWidgets('le bouton refresh émet ExampleRefreshRequested', (tester) async {
      when(
        () => mockBloc.state,
      ).thenReturn(ExampleState(status: ExampleStatus.success, items: TestData.tExampleEntities));
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(buildApp());
      await tester.tap(find.byIcon(Icons.refresh));

      verify(() => mockBloc.add(const ExampleRefreshRequested())).called(1);
    });
  });
}
