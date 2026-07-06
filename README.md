# Flutter Template App

[![CI](https://github.com/BorisGautier/flutter_template_app/actions/workflows/ci.yml/badge.svg)](https://github.com/BorisGautier/flutter_template_app/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/BorisGautier/flutter_template_app/branch/main/graph/badge.svg)](https://codecov.io/gh/BorisGautier/flutter_template_app)
[![Flutter](https://img.shields.io/badge/Flutter-3.44%2B-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%E2%89%A53.9.0-0175C2?logo=dart)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

Template Flutter **production-ready** basé sur la **Clean Architecture**, **BLoC**, **Chopper**, **Drift** et **Firebase**. Opérationnel dès le `git clone`.

---

## 🚀 Installation en 4 commandes

```bash
git clone https://github.com/BorisGautier/flutter_template_app
cd flutter_template_app
make setup        # installation complète automatique
make run-dev      # l'app tourne
```

> **Prérequis :** Flutter ≥ 3.44 (channel beta) — Dart ≥ 3.9.0

---

## ✨ Présentation

Ce template fournit un socle Flutter de niveau production, prêt à l'emploi dès le `git clone`. Il intègre :

| Catégorie | Solution |
|-----------|----------|
| **Architecture** | Clean Architecture (Domain / Data / Presentation) feature-first |
| **État** | BLoC avec pattern loading / success / failure |
| **Navigation** | GoRouter — deep links, guards, routes imbriquées |
| **HTTP** | Chopper — intercepteurs JWT, refresh token automatique (401) |
| **Base de données** | Drift (ORM SQLite) + flutter_secure_storage |
| **DI** | GetIt + Injectable — singletons, modules, code généré committé |
| **Firebase** | Crashlytics, Messaging, Auth, Performance |
| **i18n** | flutter_localizations — ARB, Français + Anglais |
| **Thème** | Material 3 clair/sombre — police Outfit, palette centralisée |
| **Tests** | bloc_test + mocktail — 58 tests (unit + widget), politique de couverture |
| **CI/CD** | GitHub Actions — analyze, test, release Android/iOS |
| **Automatisation** | Makefile 20 cibles, scripts bash, hook pre-commit |

---

## 🏗️ Architecture

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

```
lib/
├── core/               # Infrastructure transversale (réseau, thème, DI, erreurs)
├── di/                 # GetIt + Injectable
├── features/
│   └── example/        # Feature d'exemple complète — dupliquer pour chaque feature
│       ├── data/        # Models JSON · DataSources · Repository implementations
│       ├── domain/      # Entities · Repository interfaces · Use cases
│       └── presentation/# BLoC · Pages · Widgets
├── l10n/               # Fichiers ARB (fr, en) + classes générées
├── routes/             # GoRouter centralisé
└── main.dart
```

→ Voir [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) pour le guide complet.

---

## 📦 Stack technique

| Catégorie | Package | Version |
|-----------|---------|----------|
| State management | flutter_bloc | ^9.1.1 |
| Navigation | go_router | ^17.1.0 |
| DI | get_it + injectable | ^9.2.0 / ^2.7.1+4 |
| HTTP | chopper | ^8.5.1 |
| Base de données | drift + drift_flutter | ^2.21.0 |
| Stockage sécurisé | flutter_secure_storage | ^10.0.0 |
| Firebase | firebase_core/auth/crashlytics/messaging | ^4.3.0… |
| Auth sociale | google_sign_in / sign_in_with_apple | ^7.2.0 / ^6.1.1 |
| Biométrie | local_auth | ^3.0.0 |
| UI | google_fonts / lottie / flutter_animate | ^8.0.1 / ^3.3.2 / ^4.5.2 |
| Graphiques | fl_chart / confetti | ^0.68.0 / ^0.8.0 |
| Programmation fonctionnelle | fpdart | ^1.2.0 |
| Variables d'env | flutter_dotenv | ^6.0.0 |
| Télémétrie | opentelemetry | any |
| Tests | bloc_test + mocktail | ^10.0.0 / ^1.0.4 |

---

## ⚙️ Prérequis

| Outil | Version minimale | Vérification |
|-------|-----------------|-------------|
| Flutter | 3.44.0+ (channel beta) | `flutter --version` |
| Dart | 3.9.0+ | `dart --version` |
| Android Studio / VS Code | Dernière version | — |
| Xcode | 15+ (macOS, build iOS) | `xcode-select -p` |
| Java | 17 (build Android) | `java -version` |

> **Pourquoi Flutter beta ?** Les dépendances de ce template (chopper 8.5+, local_auth 3.0+, etc.)
> requièrent Dart ≥ 3.9.0, disponible depuis Flutter 3.44.0 (channel beta).
> La prochaine version stable Flutter inclura Dart 3.9+.

---

## 🛠️ Configuration pas à pas

### 1 — Variables d'environnement

```bash
make set-env
# Éditer .env avec vos valeurs
```

> Ne **jamais** commiter `.env`. Voir [SECURITY.md](SECURITY.md).

### 2 — Renommer l'application

```bash
make rename
# Saisir : com.votreentreprise.votreapp
# Saisir : Nom de Votre App
```

### 3 — Installer les dépendances

```bash
make install
```

### 4 — Générer le code

```bash
make codegen
# Régénère : *.g.dart, injection.config.dart
```

### 5 — Configurer Firebase (optionnel)

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=VOTRE_PROJET_FIREBASE
# Décommenter les imports Firebase dans lib/main.dart
```

→ Voir [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) pour le guide complet.

---

## 🌍 Internationalisation

Langues supportées : **Français** (référence), **Anglais**.

```dart
// Accès aux traductions depuis n'importe quel widget
Text(context.l10n.welcomeTitle)
```

**Ajouter une clé de traduction :**
1. `lib/l10n/app_fr.arb` → ajouter la clé
2. `lib/l10n/app_en.arb` → ajouter la traduction
3. `lib/l10n/app_localizations.dart` → ajouter le getter abstrait
4. Implémenter dans `app_localizations_fr.dart` et `app_localizations_en.dart`

---

## 🎨 Personnalisation du thème

Toute la palette dans un seul fichier : `lib/core/theme/app_colors.dart`

```dart
static const Color primary = Color(0xFF059669);   // → votre couleur principale
static const Color secondary = Color(0xFFD4AF37); // → votre couleur secondaire
```

Mode clair/sombre configuré dans `main.dart` via `themeMode: ThemeMode.system`.

---

## 🔀 Environnements

| Commande | Environnement |
|----------|--------------|
| `make run-dev` | Développement |
| `make run-staging` | Staging |
| `make run-prod` | Production (release) |
| `make build-aab-prod` | AAB → Google Play |
| `make build-ios-prod` | IPA → App Store |

---

## 🧪 Tests

```bash
make test              # Tests unitaires + widget + couverture
make test-watch        # Mode watch
make check             # lint + format + tests (pipeline CI local)
make coverage          # Rapport HTML de couverture (nécessite lcov)
make coverage-open     # Tests + rapport + ouverture navigateur

# Tests d'intégration (nécessite un émulateur/appareil + .env configuré)
flutter test integration_test/ --dart-define=APP_ENV=development
```

**État actuel : 58/58 tests unitaires et widget ✅** (47 unit + 11 widget)

→ Voir [docs/TESTING.md](docs/TESTING.md) pour la stratégie complète et les exemples.

---

## 🚀 CI/CD

| Workflow | Déclencheur | Description |
|----------|-------------|-------------|
| `ci.yml` | push/PR → main, develop | analyze + tests + build Android/iOS |
| `release-android.yml` | tag `v*.*.*` ou manuel | Signature + Google Play Store |
| `release-ios.yml` | tag `v*.*.*` ou manuel | Signature + TestFlight / App Store |
| `code-quality.yml` | PR + hebdomadaire | lint, format, détection secrets |
| `dependency-audit.yml` | hebdomadaire | audit packages + pana score |

Configurer les secrets GitHub nécessaires → [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md#déploiement-cicd-github-actions).

---

## 📋 Makefile — commandes disponibles

```bash
make help           # Lister toutes les commandes
make setup          # Installation complète
make rename         # Renommer l'app
make set-env        # Créer .env depuis .env.example
make install        # flutter pub get
make codegen        # Génération de code (one-shot)
make run-dev        # Lancer en développement
make analyze        # Analyse statique
make format         # Formater le code
make test           # Tests + couverture
make coverage       # Rapport HTML de couverture
make coverage-open  # Tests + rapport + ouverture navigateur
make check          # lint + tests (CI local)
make build-aab-prod # Android App Bundle production
make clean          # flutter clean
make clean-full     # clean + install + codegen
```

---

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Clean Architecture, patterns, guide feature |
| [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) | Android + iOS, secrets CI/CD, numérotation |
| [docs/TESTING.md](docs/TESTING.md) | Stratégie, couverture, exemples BLoC/Repository |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contribuer au template |
| [SECURITY.md](SECURITY.md) | Politique de sécurité, zéro secret |
| [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) | Code de conduite |
| [CHANGELOG.md](CHANGELOG.md) | Historique des versions |

---

## 🔒 Sécurité

Ce template applique une politique **zéro secret** :
- `.env`, `google-services.json`, `*.jks`, `key.properties` → dans `.gitignore`
- Uniquement des `.env.example` avec valeurs fictives dans le dépôt
- Audit de dépendances hebdomadaire via GitHub Actions

→ Voir [SECURITY.md](SECURITY.md) pour signaler une vulnérabilité.

---

## 🤝 Contribuer

Les contributions sont les bienvenues ! Lire [CONTRIBUTING.md](CONTRIBUTING.md).

**Types de contributions appréciées :**
- 🐛 Corrections de bugs → [template bug](.github/ISSUE_TEMPLATE/bug_report.yml)
- ✨ Nouvelles fonctionnalités → [template feature](.github/ISSUE_TEMPLATE/feature_request.yml)
- 📖 Améliorations de documentation → [template docs](.github/ISSUE_TEMPLATE/documentation.yml)
- ⚡ Optimisations → [template perf](.github/ISSUE_TEMPLATE/performance.yml)

---

## 📄 Licence

[MIT](LICENSE) — 2026 Boris Gautier

---

*Template maintenu avec ❤️ — [Signaler un bug](https://github.com/BorisGautier/flutter_template_app/issues/new?template=bug_report.yml) · [Proposer une fonctionnalité](https://github.com/BorisGautier/flutter_template_app/issues/new?template=feature_request.yml) · [Discussions](https://github.com/BorisGautier/flutter_template_app/discussions)*
