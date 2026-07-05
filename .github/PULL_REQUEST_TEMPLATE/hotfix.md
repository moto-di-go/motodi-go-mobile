## 🚨 Hotfix — [Description du problème critique]

> ⚠️ **HOTFIX** — Cette PR corrige un problème critique en production.
> Elle doit être mergée et déployée le plus rapidement possible.

Fixes #<!-- issue critique -->

---

## 🔥 Problème critique

**Sévérité :** [ ] P0 — Application inutilisable / [ ] P1 — Fonctionnalité critique cassée

**Impact :** <!-- Combien d'utilisateurs / projets sont affectés ? -->

**Symptôme :** <!-- Ce que voient les utilisateurs -->

---

## 🔧 Correction appliquée

<!-- Description CONCISE de la correction.
     Un hotfix doit être minimal — corriger UNIQUEMENT le problème critique. -->

**Changements :**
- [ ] Modifié : `[fichier]` — [raison]

**Cette PR ne contient PAS :**
- Refactoring
- Nouvelles fonctionnalités
- Optimisations non liées au bug

---

## 🧪 Tests de validation

- [ ] Le bug critique est corrigé
- [ ] Testé en mode `release` (pas seulement debug)
- [ ] Tests de régression ajoutés
- [ ] `make test` → tous les tests passent

---

## 🚀 Plan de déploiement post-merge

1. [ ] Merger vers `main`
2. [ ] Créer un tag `v[X.Y.Z+1]`
3. [ ] Déclencher le workflow `release-android` / `release-ios`
4. [ ] Vérifier en production
5. [ ] Back-port vers `develop` si nécessaire

---

## ✅ Approbations requises

- [ ] Revue de code par au moins 1 maintainer
- [ ] Tests CI verts
