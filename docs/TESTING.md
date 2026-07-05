# Guide des Tests

Ce document décrit la stratégie de tests du template, les conventions à suivre et des exemples concrets.

---

## Stratégie

Le template suit une approche **tests unitaires first** centrée sur la logique métier (Domain + Data) et les BLoC (Presentation). Les tests d'intégration et de widget sont laissés à la discrétion de chaque projet.

### Objectifs de couverture

| Couche | Cible | Justification |
|--------|-------|---------------|
| Domain (Use Cases + Entities) | ≥ 90% | Logique métier pure, testable facilement |
| Data (Repositories) | ≥ 80% | Toutes les branches connecté/déconnecté |
| Presentation (BLoC) | ≥ 85% | Tous les events, états d'erreur |
| Core (Utils, Failures) | ≥ 75% | Extensions et hiérarchie d'erreurs |
| UI (Pages, Widgets) | Smoke tests | Vérification de rendu basique |

---

## Structure des tests

```
test/
├── helpers/
│   ├── mocks.dart          # Tous les mocks centralisés (mocktail)
│   └── test_data.dart      # Données de test réutilisables
├── core/
│   ├── error/
│   │   └── failure_test.dart
│   └── network/
│       └── network_info_test.dart
├── features/
│   └── example/
│       ├── domain/
│       │   ├── entities/
│       │   │   └── example_entity_test.dart
│       │   └── usecases/
│       │       └── get_examples_usecase_test.dart
│       ├── data/
│       │   ├── models/
│       │   │   └── example_model_test.dart
│       │   └── repositories/
│       │       └── example_repository_impl_test.dart
│       └── presentation/
│           └── bloc/
│               └── example_bloc_test.dart
├── widget_test.dart         # Smoke test de l'App
└── TESTING_POLICY.md        # Politique détaillée
```

---

## Commandes

```bash
# Lancer tous les tests
make test
# ou : flutter test --coverage

# Mode watch (relance automatique à chaque modification)
make test-watch
# ou : flutter test --watch

# Test d'un seul fichier
flutter test test/features/example/presentation/bloc/example_bloc_test.dart

# Test d'un seul group/test par nom
flutter test --name "emit \[loading, success\]"

# Voir la couverture (après make test)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html   # macOS
```

---

## Outils

| Package | Rôle | Version |
|---------|------|---------|
| `flutter_test` | Framework de test Flutter (SDK) | SDK |
| `bloc_test` | Test de BLoC avec `blocTest<>()` | ^10.0.0 |
| `mocktail` | Mocks typés sans génération de code | ^1.0.4 |

---

## Convention de nommage des tests

```dart
// Format : 'description de l'état initial / action / résultat attendu'
test('should return list of ExampleEntity when repository succeeds', () { ... });
test('should return ServerFailure when remote call throws', () { ... });
test('should return NetworkFailure without calling remote', () { ... });

// BLoC tests avec blocTest :
blocTest<ExampleBloc, ExampleState>(
  'emit [loading, success] when use case returns data',
  ...
);
```

---

## Mocks centralisés

Tous les mocks sont dans `test/helpers/mocks.dart` :

```dart
import 'package:mocktail/mocktail.dart';
import 'package:flutter_template_app/core/network/network_info.dart';
import 'package:flutter_template_app/features/example/domain/repositories/example_repository.dart';
import 'package:flutter_template_app/features/example/domain/usecases/get_examples_usecase.dart';

class MockExampleRepository extends Mock implements ExampleRepository {}
class MockNetworkInfo extends Mock implements NetworkInfo {}
class MockGetExamplesUseCase extends Mock implements GetExamplesUseCase {}
```

**Règle :** ne jamais définir un mock à l'intérieur d'un fichier de test. Tous dans `helpers/mocks.dart`.

---

## Test d'un Use Case

```dart
void main() {
  late GetExamplesUseCase useCase;
  late MockExampleRepository mockRepository;

  setUp(() {
    mockRepository = MockExampleRepository();
    useCase = GetExamplesUseCase(mockRepository);
  });

  group('GetExamplesUseCase', () {
    test('should delegate call to repository and return its result', () async {
      // Arrange
      when(() => mockRepository.getExamples())
          .thenAnswer((_) async => right(TestData.tExampleEntities));

      // Act
      final result = await useCase();

      // Assert
      expect(result, right(TestData.tExampleEntities));
      verify(() => mockRepository.getExamples()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
```

---

## Test d'un Repository

```dart
group('getExamples', () {
  group('when device is connected', () {
    setUp(() {
      when(() => mockNetwork.isConnected).thenAnswer((_) async => true);
    });

    test('should return list of entities when remote call succeeds', () async {
      when(() => mockRemote.getExamples())
          .thenAnswer((_) async => TestData.tExampleModels);

      final result = await repository.getExamples();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return data'),
        (entities) => expect(entities.length, TestData.tExampleModels.length),
      );
      verify(() => mockRemote.getExamples()).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.getExamples()).thenThrow(Exception('API error'));

      final result = await repository.getExamples();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return failure'),
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
        (_) => fail('Should return NetworkFailure'),
      );
      verifyNever(() => mockRemote.getExamples());  // Important !
    });
  });
});
```

---

## Test d'un BLoC

```dart
void main() {
  late ExampleBloc bloc;
  late MockGetExamplesUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockGetExamplesUseCase();
    bloc = ExampleBloc(mockUseCase);
  });

  tearDown(() => bloc.close());

  group('GetExamplesRequested', () {
    blocTest<ExampleBloc, ExampleState>(
      'emit [loading, success] when use case returns data',
      build: () {
        when(() => mockUseCase())
            .thenAnswer((_) async => right(TestData.tExampleEntities));
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
      'emit [loading, failure] when use case returns ServerFailure',
      build: () {
        when(() => mockUseCase())
            .thenAnswer((_) async => left(const ServerFailure('Erreur API')));
        return bloc;
      },
      act: (b) => b.add(const GetExamplesRequested()),
      expect: () => [
        const ExampleState(status: ExampleStatus.loading),
        const ExampleState(
          status: ExampleStatus.failure,
          errorMessage: 'Erreur API',
        ),
      ],
    );
  });
}
```

---

## Ce qu'on ne teste PAS

- Les fichiers générés (`*.g.dart`, `injection.config.dart`)
- La configuration du thème (couleurs, typographie)
- Les fichiers de localisation ARB
- La configuration du router (routes déclaratives)
- Les widgets purement visuels sans logique

## Ce qu'on teste obligatoirement

- ✅ Chaque use case (succès + erreur)
- ✅ Chaque repository (connecté + déconnecté + exception)
- ✅ Chaque BLoC (tous les events, états d'erreur, état initial)
- ✅ La hiérarchie des Failures (Equatable, messages, codes)
- ✅ Les mappers JSON (fromJson, toJson, toEntity, round-trip)
- ✅ Les extensions utilitaires du Core

---

## Ajouter des tests pour une nouvelle feature

1. Créer `test/helpers/mocks.dart` → ajouter les mocks
2. Créer `test/helpers/test_data.dart` → ajouter les données de test
3. Écrire les tests dans l'ordre recommandé :
   - Domain (entités + use cases) → plus simple, aucune dépendance
   - Data (models + repositories) → mock de la datasource
   - Presentation (BLoC) → mock du use case

---

## Intégration CI

Les tests sont lancés automatiquement à chaque push via `.github/workflows/ci.yml` :

```yaml
- name: Run tests with coverage
  run: flutter test --coverage --reporter github

- name: Upload coverage to Codecov
  uses: codecov/codecov-action@v4
  with:
    file: coverage/lcov.info
```

Le badge de couverture est affiché dans le README.
