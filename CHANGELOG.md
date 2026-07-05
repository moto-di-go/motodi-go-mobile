# Changelog

Tous les changements notables de ce projet sont documentés dans ce fichier.

Format basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/).
Ce projet suit le [Versionnage Sémantique](https://semver.org/lang/fr/).

---

## [Non publié]

### À venir
- Tests d'intégration avec `integration_test`
- Support WebSocket (Chopper + Drift streaming)
- Module d'authentification complet (Google + Apple + Biométrie)
- Dashboard analytics Flutter (FL Chart)
- Support Flavor (dev/staging/prod) avec `flutter_flavorizr`

---

## [1.0.0] — 2026-05-13

### ✨ Ajouté

#### Architecture
- Clean Architecture (Domain / Data / Presentation) organisée par feature
- Feature `example` complète illustrant tous les patterns du template
- Hiérarchie des Failures (`ServerFailure`, `NetworkFailure`, `CacheFailure`, `ValidationFailure`, `AuthFailure`)
- Pattern `Either<Failure, T>` via `fpdart` pour tous les use cases et repositories

#### Gestion d'état
- `flutter_bloc ^9.1.1` — BLoC avec `enum Status`, `copyWith`, `Equatable`
- Pattern loading/success/failure pour tous les états
- `BlocObserver` global en mode debug

#### Navigation
- `go_router ^17.1.0` — routeur déclaratif avec deep links
- Support des routes imbriquées (`/examples/:id`)
- Placeholder de guard d'authentification

#### Réseau
- `chopper ^8.5.1` — ChopperClient central avec intercepteurs
- `AuthInterceptor` — injection automatique du JWT Bearer
- `AppAuthenticator` — refresh automatique du token sur 401
- `JsonToTypeConverter` — sérialisation JSON centralisée

#### Base de données & Stockage
- `drift ^2.21.0` — ORM SQLite avec génération de code
- `flutter_secure_storage ^10.0.0` — stockage chiffré des tokens
- `shared_preferences ^2.5.4` — préférences utilisateur

#### Firebase
- `firebase_core ^4.3.0`
- `firebase_auth ^6.1.4`
- `firebase_crashlytics ^5.0.6`
- `firebase_messaging ^16.1.0`
- `firebase_performance ^0.11.1+3`

#### Authentification
- `google_sign_in ^7.2.0`
- `sign_in_with_apple ^6.1.1`
- `local_auth ^3.0.0` (biométrie)

#### UI & Design
- Thème Material 3 complet — light + dark — avec `ColorScheme` généré
- Police `Outfit` intégrée (Regular, Medium, SemiBold, Bold)
- `AppColors`, `AppTypography`, `AppTheme` — un seul endroit à modifier
- Widgets partagés : `AppButton`, `AppLoading`, `AppErrorView`
- `google_fonts ^8.0.1`, `flutter_svg ^2.2.3`, `lottie ^3.3.2`, `flutter_animate ^4.5.2`
- `cached_network_image`, `shimmer`, `animations`, `pinput`, `fl_chart`, `confetti`

#### Internationalisation
- `flutter_localizations` (SDK) — Français (référence) + Anglais
- Fichiers ARB (`app_fr.arb`, `app_en.arb`)
- Extension `context.l10n` pour accès simplifié

#### Injection de dépendances
- `get_it ^9.2.0` + `injectable ^2.7.1+4`
- `@module` pour les services tiers (Chopper, SharedPrefs, Logger)
- Fichier `injection.config.dart` commité (pas de build_runner requis au premier clone)

#### Tests
- `bloc_test ^10.0.0` + `mocktail ^1.0.4`
- **47 tests unitaires** couvrant Domain, Data, Presentation et Core
- `test/helpers/mocks.dart` — mocks centralisés
- `test/helpers/test_data.dart` — données de test réutilisables
- `test/TESTING_POLICY.md` — politique de tests documentée

#### DevOps & Automatisation
- `Makefile` avec 18 cibles (`setup`, `run-dev/staging/prod`, `test`, `build-aab-prod`, etc.)
- Scripts bash : `setup.sh`, `rename_app.sh`, `gen_env.sh`, `build_release.sh`
- Hook pre-commit (`flutter analyze` + `flutter test`)
- `.env.example` avec toutes les variables documentées

#### CI/CD (GitHub Actions)
- `ci.yml` — analyze, tests, build Android/iOS à chaque push/PR
- `release-android.yml` — signature + upload Google Play Store
- `release-ios.yml` — signature + upload TestFlight / App Store
- `code-quality.yml` — lint, format, détection de secrets (GitLeaks)
- `dependency-audit.yml` — audit hebdomadaire des dépendances

#### Documentation
- `README.md` — guide complet d'installation et configuration
- `CONTRIBUTING.md` — guide de contribution détaillé
- `CHANGELOG.md` — ce fichier
- `SECURITY.md` — politique de sécurité et règles
- `CODE_OF_CONDUCT.md` — Contributor Covenant 2.1
- `docs/ARCHITECTURE.md` — Clean Architecture, patterns, guide feature
- `docs/DEPLOYMENT.md` — déploiement Android + iOS, secrets CI/CD
- `docs/TESTING.md` — stratégie de tests, exemples, couverture
- `LICENSE` — MIT

#### GitHub Templates
- 6 templates d'issues (bug, feature, performance, docs, question, security)
- 3 templates de PR (feature, bugfix, hotfix)

#### Sécurité
- `.gitignore` complet — tous les fichiers sensibles exclus
- Politique zéro secret dans le dépôt
- `freerasp` et `sqlcipher_flutter_libs` en commentaire (opt-in pour applications sensibles)
- Commentaires `# TODO: [TEMPLATE]` sur tous les points de personnalisation

### 🔧 Dépendances notables

| Package | Version | Dart requis |
|---------|---------|-------------|
| chopper | ^8.5.1 | >=3.9.0 |
| local_auth | ^3.0.0 | >=3.9.0 |
| lottie | ^3.3.2 | >=3.9.0 |
| shared_preferences | ^2.5.4 | >=3.9.0 |
| **Flutter minimum** | **3.44.0-beta** | **Dart 3.12.0** |

> **Note :** Ce template requiert Flutter beta channel ou la prochaine version stable
> supportant Dart ≥ 3.9.0. Voir [pubspec.yaml](pubspec.yaml) pour les contraintes exactes.
