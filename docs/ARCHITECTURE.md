# Architecture

Ce document décrit l'architecture du template et les décisions de conception qui la fondent.

---

## Vue d'ensemble

Le template suit la **Clean Architecture** de Robert C. Martin (Uncle Bob), adaptée au contexte Flutter avec une organisation **feature-first**.

```
┌─────────────────────────────────────────────────┐
│                  Presentation                    │
│          (BLoC · Pages · Widgets)                │
├─────────────────────────────────────────────────┤
│                    Domain                        │
│       (Entities · Use Cases · Repositories)      │
├─────────────────────────────────────────────────┤
│                     Data                         │
│    (Models · DataSources · Repository Impls)     │
├─────────────────────────────────────────────────┤
│                     Core                         │
│  (Network · Theme · DI · Utils · Error Handling) │
└─────────────────────────────────────────────────┘
```

**Règle fondamentale :** les dépendances pointent toujours vers l'intérieur.
- `Data` peut dépendre de `Domain`
- `Presentation` peut dépendre de `Domain`
- `Domain` ne dépend de rien d'autre

---

## Structure des fichiers

```
lib/
├── core/                          # Infrastructure transversale
│   ├── constants/
│   │   └── route_constants.dart   # Chemins de navigation
│   ├── error/
│   │   └── failure.dart           # Hiérarchie des erreurs (Either<Failure, T>)
│   ├── network/
│   │   ├── api_client.dart        # ChopperClient central
│   │   ├── authenticator.dart     # Refresh automatique du token (401)
│   │   ├── interceptors.dart      # Injection du JWT Bearer
│   │   ├── json_type_converter.dart
│   │   └── network_info.dart      # Détection de connectivité
│   ├── services/
│   │   └── notification_service.dart
│   ├── theme/
│   │   ├── app_colors.dart        # Palette complète (Material 3)
│   │   ├── app_typography.dart    # Police Outfit + hiérarchie
│   │   └── app_theme.dart         # ThemeData light + dark
│   ├── utils/
│   │   └── extensions.dart        # Extensions Dart/Flutter (BuildContext, String…)
│   └── widgets/
│       ├── app_button.dart
│       ├── app_error_view.dart
│       └── app_loading.dart
│
├── di/
│   ├── injection.dart             # GetIt instance + @InjectableInit
│   ├── injection.config.dart      # Généré par injectable_generator
│   └── register_module.dart       # Services tiers (@module)
│
├── features/
│   └── example/                   # Feature d'exemple — dupliquer pour chaque feature
│       ├── data/
│       │   ├── datasources/
│       │   │   └── example_remote_datasource.dart
│       │   ├── models/
│       │   │   ├── example_model.dart
│       │   │   └── example_model.g.dart     # Généré
│       │   └── repositories/
│       │       └── example_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── example_entity.dart
│       │   ├── repositories/
│       │   │   └── example_repository.dart  # Interface (contrat)
│       │   └── usecases/
│       │       └── get_examples_usecase.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── example_bloc.dart
│           │   ├── example_event.dart
│           │   └── example_state.dart
│           ├── pages/
│           │   ├── example_list_page.dart
│           │   └── example_detail_page.dart
│           └── widgets/
│               └── example_card.dart
│
├── l10n/
│   ├── app_fr.arb                 # Fichier de traductions français (référence)
│   ├── app_en.arb                 # Fichier de traductions anglais
│   ├── app_localizations.dart     # Classe abstraite générée
│   ├── app_localizations_fr.dart  # Implémentation FR générée
│   └── app_localizations_en.dart  # Implémentation EN générée
│
├── routes/
│   └── app_router.dart            # GoRouter centralisé
│
└── main.dart                      # Point d'entrée
```

---

## Couche Domain

La couche Domain est le cœur de l'application. Elle ne contient **aucune dépendance Flutter ou tierce**.

### Entities

Les entités sont des objets métier purs avec `Equatable` pour la comparaison :

```dart
class ExampleEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;

  const ExampleEntity({...});

  @override
  List<Object?> get props => [id, title, description, createdAt];
}
```

### Repository Interfaces

Contrats définis dans Domain, implémentés dans Data. Toujours utiliser `Either<Failure, T>` :

```dart
abstract class ExampleRepository {
  Future<Either<Failure, List<ExampleEntity>>> getExamples();
  Future<Either<Failure, ExampleEntity>> getExampleById(String id);
  Future<Either<Failure, ExampleEntity>> createExample({
    required String title,
    required String description,
  });
}
```

### Use Cases

Un use case = une seule action métier = un seul fichier. Pattern `call()` :

```dart
@injectable
class GetExamplesUseCase {
  final ExampleRepository _repository;
  GetExamplesUseCase(this._repository);

  Future<Either<Failure, List<ExampleEntity>>> call() =>
      _repository.getExamples();
}
```

---

## Couche Data

### Models (JSON ↔ Entity)

Les models étendent ou wrappent les entités et ajoutent la sérialisation JSON :

```dart
@JsonSerializable(fieldRename: FieldRename.snake)
class ExampleModel {
  factory ExampleModel.fromJson(Map<String, dynamic> json) =>
      _$ExampleModelFromJson(json);
  Map<String, dynamic> toJson() => _$ExampleModelToJson(this);

  ExampleEntity toEntity() => ExampleEntity(id: id, title: title, ...);
  factory ExampleModel.fromEntity(ExampleEntity e) => ExampleModel(...);
}
```

Générer avec : `dart run build_runner build --delete-conflicting-outputs`

### DataSources

Source unique de vérité pour les données. Utilise Chopper pour les appels réseau :

```dart
@lazySingleton
class ExampleRemoteDataSource {
  // TODO: [TEMPLATE] Injecter ExampleApiService (Chopper)
  Future<List<ExampleModel>> getExamples() async { ... }
}
```

### Repository Implementations

Pont entre Domain et Data. Gère les erreurs et la connectivité :

```dart
@LazySingleton(as: ExampleRepository)
class ExampleRepositoryImpl implements ExampleRepository {
  final ExampleRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<ExampleEntity>>> getExamples() async {
    if (!await _networkInfo.isConnected) {
      return left(const NetworkFailure('Pas de connexion internet'));
    }
    try {
      final models = await _remoteDataSource.getExamples();
      return right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
```

---

## Couche Presentation (BLoC)

### Pattern Event → State

```
UI action  ──→  Event  ──→  BLoC  ──→  State  ──→  UI rebuild
```

### Convention de nommage

| Élément | Convention | Exemple |
|---------|-----------|----------|
| Event (request) | `NomAction + Requested` | `GetExamplesRequested` |
| Event (refresh) | `Nom + RefreshRequested` | `ExampleRefreshRequested` |
| State status | `enum NomStatus` | `ExampleStatus { initial, loading, success, failure }` |
| State class | `NomState extends Equatable` | `ExampleState` |
| BLoC class | `Nom + Bloc` | `ExampleBloc` |

### Template BLoC

```dart
@injectable
class ExampleBloc extends Bloc<ExampleEvent, ExampleState> {
  final GetExamplesUseCase _getExamples;

  ExampleBloc(this._getExamples) : super(const ExampleState()) {
    on<GetExamplesRequested>(_onGetExamples);
  }

  Future<void> _onGetExamples(
    GetExamplesRequested event,
    Emitter<ExampleState> emit,
  ) async {
    emit(state.copyWith(status: ExampleStatus.loading));
    final result = await _getExamples();
    result.fold(
      (failure) => emit(state.copyWith(
        status: ExampleStatus.failure,
        errorMessage: failure.message,
      )),
      (items) => emit(state.copyWith(
        status: ExampleStatus.success,
        items: items,
      )),
    );
  }
}
```

---

## Injection de dépendances

### GetIt + Injectable

Annotations disponibles :

| Annotation | Usage |
|-----------|-------|
| `@injectable` | Classe instanciée à chaque appel |
| `@lazySingleton` | Singleton créé à la première utilisation |
| `@singleton` | Singleton créé au démarrage |
| `@LazySingleton(as: Interface)` | Singleton lié à une interface |
| `@module` + `@lazySingleton` | Services tiers (ChopperClient, SharedPrefs…) |
| `@preResolve` | Future résolue avant injection |

### Régénérer l'injection

```bash
dart run build_runner build --delete-conflicting-outputs
```

Le fichier `lib/di/injection.config.dart` est commité pour ne pas bloquer les contributeurs.

---

## Gestion des erreurs

### Hiérarchie des Failures

```dart
abstract class Failure extends Equatable {
  final String message;
  final String? code;
}

class ServerFailure extends Failure { ... }      // Erreur API (4xx, 5xx)
class NetworkFailure extends Failure { ... }     // Pas de connectivité
class CacheFailure extends Failure { ... }       // Erreur Drift/cache
class ValidationFailure extends Failure { ... }  // Validation d'entrée
class AuthFailure extends Failure { ... }        // Token expiré, non autorisé
```

### Flux d'erreur

```
Exception (Data) → Failure (Domain) → ExampleStatus.failure + errorMessage (Presentation)
```

Ne jamais laisser remonter d'exception au-delà du repository. Toutes les erreurs passent par `Either<Failure, T>`.

---

## Navigation (GoRouter)

### Configuration

Routes déclarées dans `lib/routes/app_router.dart`. Pattern recommandé :

```dart
GoRoute(
  path: '/examples',
  builder: (ctx, state) => const ExampleListPage(),
  routes: [
    GoRoute(
      path: ':id',
      builder: (ctx, state) => ExampleDetailPage(
        itemId: state.pathParameters['id']!,
      ),
    ),
  ],
),
```

### Deep links

GoRouter gère nativement les deep links. Configurer dans `AndroidManifest.xml` et `Info.plist`.

### Guards d'authentification

```dart
redirect: (context, state) {
  final isLoggedIn = context.read<AuthBloc>().state.isAuthenticated;
  final isGoingToLogin = state.matchedLocation == '/login';
  if (!isLoggedIn && !isGoingToLogin) return '/login';
  if (isLoggedIn && isGoingToLogin) return '/home';
  return null;
},
```

---

## Ajouter une nouvelle feature

### Checklist

```bash
lib/features/ma_feature/
├── domain/
│   ├── entities/ma_feature_entity.dart          # 1. Entité Equatable
│   ├── repositories/ma_feature_repository.dart  # 2. Interface Either<Failure, T>
│   └── usecases/
│       ├── get_ma_feature_usecase.dart           # 3. Use case par action
│       └── create_ma_feature_usecase.dart
├── data/
│   ├── datasources/ma_feature_remote_ds.dart    # 4. Appels Chopper
│   ├── models/ma_feature_model.dart             # 5. @JsonSerializable
│   └── repositories/ma_feature_repo_impl.dart  # 6. @LazySingleton(as: Interface)
└── presentation/
    ├── bloc/
    │   ├── ma_feature_bloc.dart                 # 7. @injectable extends Bloc
    │   ├── ma_feature_event.dart
    │   └── ma_feature_state.dart                # 8. enum Status + copyWith
    ├── pages/
    │   └── ma_feature_page.dart                 # 9. BlocProvider + BlocBuilder
    └── widgets/
        └── ma_feature_card.dart                 # 10. Widgets réutilisables

test/features/ma_feature/
├── domain/usecases/get_ma_feature_usecase_test.dart
├── data/repositories/ma_feature_repo_impl_test.dart
└── presentation/bloc/ma_feature_bloc_test.dart
```
