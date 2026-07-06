# Politique de Tests Unitaires

## Philosophie

Tout code métier doit être couvert par des tests unitaires. Les tests doivent être rapides, isolés, et déterministes.

## Structure

```
test/
├── core/
│   ├── error/           # Tests des Failure
│   ├── network/         # Tests NetworkInfo
│   └── utils/           # Tests des extensions
├── features/
│   └── [feature]/
│       ├── domain/
│       │   └── usecases/    # Tests des use cases
│       ├── data/
│       │   └── repositories/# Tests des repositories
│       └── presentation/
│           └── bloc/        # Tests BLoC (bloc_test)
├── helpers/
│   ├── test_data.dart   # Données de test réutilisables
│   └── mocks.dart       # Mocks centralisés (mocktail)
└── widget_test.dart     # Test de smoke de l'app
```

## Règles

### Ce qu'on teste
- **Use cases** : chaque use case = 1 fichier de test, cas succès + échec
- **Repositories** : chaque méthode publique avec mock des datasources
- **BLoC** : chaque event avec `blocTest`, états loading/success/failure
- **Entités** : égalité Equatable, copyWith si présent
- **Extensions** : chaque extension non-triviale

### Ce qu'on NE teste PAS
- Widgets Flutter (trop fragiles, privilégier les tests manuels / golden tests séparés)
- Code généré (`*.g.dart`, `injection.config.dart`)
- Datasources (moquées dans les repositories)

### Nommage
```dart
// Format : should [résultat attendu] when [condition]
test('should return list of entities when repository succeeds', () {});

// BLoC : emit [etats] when [event]
blocTest<ExampleBloc, ExampleState>(
  'emit [loading, success] when GetExamplesRequested and repository succeeds',
  ...
);
```

### Couverture cible
| Couche | Couverture minimale |
|---|---|
| Domain (use cases + entities) | **90%** |
| Data (repositories) | **80%** |
| Presentation (BLoC) | **85%** |
| Core (utils, error) | **75%** |

### Commandes
```bash
make test              # Tous les tests avec couverture
make test-watch        # Mode watch (TDD)
make check             # lint + test (pipeline CI complet)

# Couverture HTML
flutter test --coverage && genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Patterns

### Pattern Use Case
```dart
void main() {
  late UseCase useCase;
  late MockRepository mockRepository;

  setUp(() {
    mockRepository = MockRepository();
    useCase = UseCase(mockRepository);
  });

  group('UseCase', () {
    test('should return data when repository succeeds', () async {
      when(() => mockRepository.method()).thenAnswer((_) async => right(data));
      final result = await useCase();
      expect(result, right(data));
      verify(() => mockRepository.method()).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.method()).thenAnswer((_) async => left(ServerFailure('error')));
      final result = await useCase();
      expect(result, left(const ServerFailure('error')));
    });
  });
}
```

### Pattern Repository
```dart
void main() {
  late RepositoryImpl repository;
  late MockRemoteDataSource mockRemote;
  late MockNetworkInfo mockNetwork;

  setUp(() {
    mockRemote = MockRemoteDataSource();
    mockNetwork = MockNetworkInfo();
    repository = RepositoryImpl(mockRemote, mockNetwork);
  });

  group('when connected', () {
    setUp(() => when(() => mockNetwork.isConnected).thenAnswer((_) async => true));

    test('should return entities from remote source', () async {
      when(() => mockRemote.getData()).thenAnswer((_) async => [model]);
      final result = await repository.getData();
      expect(result, right([entity]));
    });
  });

  group('when not connected', () {
    setUp(() => when(() => mockNetwork.isConnected).thenAnswer((_) async => false));

    test('should return NetworkFailure', () async {
      final result = await repository.getData();
      expect(result.isLeft(), true);
    });
  });
}
```

### Pattern BLoC
```dart
blocTest<MyBloc, MyState>(
  'emit [loading, success] when event and use case succeeds',
  build: () {
    when(() => mockUseCase()).thenAnswer((_) async => right(data));
    return MyBloc(mockUseCase);
  },
  act: (bloc) => bloc.add(MyEvent()),
  expect: () => [
    const MyState(status: MyStatus.loading),
    MyState(status: MyStatus.success, data: data),
  ],
  verify: (_) => verify(() => mockUseCase()).called(1),
);
```
