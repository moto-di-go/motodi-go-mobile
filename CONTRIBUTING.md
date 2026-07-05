# Guide de Contribution

Merci de votre intérêt pour ce template Flutter production-ready !
Ce guide explique comment contribuer efficacement.

---

## Table des matières

- [Code de Conduite](#code-de-conduite)
- [Démarrage rapide](#démarrage-rapide)
- [Signaler un bug](#signaler-un-bug)
- [Proposer une fonctionnalité](#proposer-une-fonctionnalité)
- [Développer une contribution](#développer-une-contribution)
- [Conventions de code](#conventions-de-code)
- [Process de review](#process-de-review)

---

## Code de Conduite

Ce projet adhère au [Code de Conduite des Contributeurs](CODE_OF_CONDUCT.md).
En participant, vous acceptez de respecter ces règles.

---

## Démarrage rapide

```bash
# 1. Forker le dépôt sur GitHub

# 2. Cloner votre fork
git clone https://github.com/VOTRE_USERNAME/flutter_template_app
cd flutter_template_app

# 3. Configurer l'upstream
git remote add upstream https://github.com/BorisGautier/flutter_template_app

# 4. Setup complet
make setup

# 5. Créer une branche de travail
git checkout -b feature/ma-fonctionnalite
```

---

## Signaler un bug

1. Vérifier qu'une [issue similaire](https://github.com/BorisGautier/flutter_template_app/issues) n'existe pas déjà
2. Utiliser le [template de rapport de bug](.github/ISSUE_TEMPLATE/bug_report.yml)
3. Inclure : description, étapes de reproduction, comportement attendu/observé, environnement

---

## Proposer une fonctionnalité

1. Ouvrir d'abord une [issue de demande de fonctionnalité](.github/ISSUE_TEMPLATE/feature_request.yml) pour discussion
2. Attendre validation d'un mainteneur avant de commencer l'implémentation
3. Pour les changements mineurs (typo, fix évident), une PR directe est acceptable

---

## Développer une contribution

### Conventions de branches

| Préfixe | Usage | Exemple |
|---------|-------|----------|
| `feature/` | Nouvelle fonctionnalité | `feature/ajout-auth-biometrique` |
| `fix/` | Correction de bug | `fix/crash-ios-14-dark-mode` |
| `docs/` | Documentation uniquement | `docs/amelioration-architecture` |
| `chore/` | Maintenance, dépendances | `chore/bump-flutter-3-44` |
| `refactor/` | Refactoring sans changement comportement | `refactor/simplification-di` |
| `perf/` | Amélioration de performance | `perf/optimisation-build-time` |

### Convention des commits (Conventional Commits)

Format : `<type>(<scope>): <description en minuscules>`

| Type | Usage |
|------|-------|
| `feat` | Nouvelle fonctionnalité |
| `fix` | Correction de bug |
| `docs` | Documentation |
| `refactor` | Refactoring |
| `test` | Ajout/modification de tests |
| `chore` | Maintenance, dépendances, configuration |
| `style` | Formatage, lint (sans changement logique) |
| `perf` | Amélioration de performance |
| `ci` | Changements CI/CD |

Exemples :
```
feat(auth): add Google Sign-In support
fix(network): handle token refresh race condition on 401
docs(architecture): add clean architecture diagram
test(example): add repository unit tests for offline mode
chore(deps): bump flutter_bloc to 9.1.1
ci: add iOS build step to main workflow
```

### Checklist de développement

Avant d'ouvrir une PR, vérifier :

```bash
# 1. Format du code
dart format . --line-length 100

# 2. Analyse statique (zéro warning)
flutter analyze

# 3. Tests passants
flutter test --coverage

# Ou tout en une commande :
make check
```

- [ ] `make check` → vert
- [ ] Architecture respectée (pas d'import `data → domain`)
- [ ] Nouveaux fichiers couverts par des tests unitaires
- [ ] `CHANGELOG.md` mis à jour dans la section `[Non publié]`
- [ ] Pas de secrets ou valeurs en dur (tout via `.env`)
- [ ] Les `TODO: [TEMPLATE]` sont justifiés et documentés

---

## Conventions de code

### Architecture

- **Domain** : 0 dépendance Flutter/tierce. Entités `Equatable`, repositories `Either<Failure, T>`
- **Data** : implémentations `@LazySingleton(as: Interface)`, try/catch → Failure
- **Presentation** : BLoC `@injectable`, state avec `enum Status + copyWith`
- Ne jamais faire remonter d'exception au-delà d'un repository

### Dart / Flutter

- Préférer `const` dès que possible
- Utiliser `fpdart` (`Either`, `right()`, `left()`) — pas de `null` pour les erreurs
- Extensions dans `core/utils/extensions.dart`
- Imports absolus (`package:flutter_template_app/...`) pour le code production, imports relatifs autorisés dans les tests

### Tests

- Un fichier de test par fichier source
- Toujours `setUp()` + `tearDown()` pour les BLoC
- Nommer les tests : `'should <résultat> when <condition>'`
- Tous les mocks dans `test/helpers/mocks.dart`
- Toutes les données de test dans `test/helpers/test_data.dart`

### Commentaires

- **Uniquement si le POURQUOI est non-évident**
- Jamais de commentaires qui décrivent CE QUE fait le code (les identifiants le font déjà)
- Les `TODO: [TEMPLATE]` sont réservés aux points de personnalisation pour les utilisateurs

---

## Process de review

1. Ouvrir une PR vers `develop` (ou `main` pour les hotfixes)
2. Remplir le template de PR adapté (feature / bugfix / hotfix)
3. Au moins **1 approbation** de mainteneur requise
4. CI verte obligatoire (analyze + tests)
5. Tous les commentaires de review résolus
6. Merge via **Squash and Merge** (historique propre)

### Ce qu'on regarde en review

- ✅ Architecture respectée
- ✅ Tests couvrant les nouveaux cas
- ✅ Code lisible sans commentaire superflu
- ✅ Pas de régression de performance
- ✅ Compatibilité Android + iOS
- ✅ Pas de secret ou credential

---

## Synchroniser avec l'upstream

```bash
git fetch upstream
git checkout main
git merge upstream/main
git checkout feature/ma-fonctionnalite
git rebase main
```

---

*Des questions ? Ouvrez une [discussion](https://github.com/BorisGautier/flutter_template_app/discussions) ou une [issue question](.github/ISSUE_TEMPLATE/question.yml).*
