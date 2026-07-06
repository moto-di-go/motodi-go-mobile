## ✨ Nouvelle fonctionnalité — [Nom de la fonctionnalité]

<!-- Résumez en une phrase la fonctionnalité ajoutée -->

Closes #<!-- issue -->

---

## 🎯 Objectif

<!-- Pourquoi cette fonctionnalité a-t-elle été ajoutée au template ?
     Quel problème utilisateur résout-elle ? -->

---

## 🏗️ Changements architecturaux

<!-- Décrivez l'impact sur l'architecture Clean Architecture :
     - Nouveaux fichiers Domain / Data / Presentation
     - Nouvelles dépendances ajoutées à pubspec.yaml
     - Impact sur l'injection de dépendances (DI)
     - Nouveaux patterns introduits -->

### Fichiers ajoutés / modifiés

```
lib/features/<feature>/
├── domain/
│   ├── entities/        # Nouvelles entités
│   ├── repositories/    # Nouveaux contrats
│   └── usecases/        # Nouveaux use cases
├── data/
│   ├── datasources/     # Nouvelles sources de données
│   ├── models/          # Nouveaux modèles JSON
│   └── repositories/    # Nouvelles implémentations
└── presentation/
    ├── bloc/            # Nouveaux BLoC / Events / States
    ├── pages/           # Nouvelles pages
    └── widgets/         # Nouveaux widgets
```

---

## 🧪 Tests ajoutés

- [ ] Tests unitaires use case (`test/features/<feature>/domain/`)
- [ ] Tests unitaires repository (`test/features/<feature>/data/`)
- [ ] Tests unitaires BLoC (`test/features/<feature>/presentation/bloc/`)
- [ ] Tests de widget (si applicable)

**Couverture estimée :** ____%

---

## 📖 Documentation mise à jour

- [ ] README.md
- [ ] CHANGELOG.md
- [ ] docs/ARCHITECTURE.md (si nouveau pattern)
- [ ] Commentaires `TODO: [TEMPLATE]` ajoutés aux points de personnalisation

---

## ✅ Checklist

- [ ] `make check` → lint + tests passent
- [ ] La fonctionnalité respecte la Clean Architecture (pas d'import data → domain)
- [ ] Le code est générique — pas de logique métier spécifique à un projet réel
- [ ] Pas de secret ou valeur en dur (tout via `.env` / `TODO: [TEMPLATE]`)
- [ ] Compatible avec les deux plateformes (Android + iOS)
