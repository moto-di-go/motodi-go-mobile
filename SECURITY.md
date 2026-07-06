# Politique de Sécurité

## Versions supportées

| Version | Supportée |
|---------|----------|
| 1.x.x   | ✅ Oui |
| < 1.0   | ❌ Non |

---

## Signaler une vulnérabilité

> ⚠️ **Ne créez PAS d'issue GitHub publique pour signaler une vulnérabilité de sécurité.**

### Comment signaler

1. **Envoyez un e-mail** à l'adresse de sécurité du mainteneur du projet.
2. Incluez dans votre message :
   - Une description détaillée de la vulnérabilité
   - Les étapes pour la reproduire
   - L'impact potentiel estimé
   - Votre identifiant GitHub (pour vous créditer dans le fix)

### Ce à quoi vous pouvez vous attendre

- **Accusé de réception** sous 48 heures
- **Évaluation préliminaire** sous 5 jours ouvrés
- **Correction et divulgation coordonnée** sous 30 jours selon la sévérité

---

## Règles de sécurité du projet

### 🚫 Zéro secret dans le dépôt

Les fichiers suivants ne doivent **jamais** être commités :

| Fichier | Raison |
|---------|--------|
| `.env` | Variables d'environnement (clés API, tokens) |
| `google-services.json` | Configuration Firebase Android |
| `GoogleService-Info.plist` | Configuration Firebase iOS |
| `*.keystore` / `*.jks` | Keystore de signature Android |
| `key.properties` | Propriétés de signature Android |
| `AuthKey_*.p8` | Clé API App Store Connect |
| `*.p12` / `*.cer` | Certificats iOS |

Ces fichiers sont dans `.gitignore`. Toute PR qui tente de les inclure sera **immédiatement rejetée**.

### Variables d'environnement

Utilisez toujours `.env.example` avec des valeurs fictives pour documenter les variables requises. La vraie valeur va dans `.env` (ignoré par git) ou dans les secrets GitHub Actions.

### Dépendances tierces

- Les dépendances sont auditées chaque semaine via le workflow `dependency-audit.yml`
- Toute vulnérabilité critique dans une dépendance doit être corrigée sous 72h
- Évitez d'ajouter des dépendances sans justification claire dans la PR

### Code généré

Les fichiers générés (`*.g.dart`, `injection.config.dart`) sont commités intentionnellement pour éviter que les contributeurs aient besoin de Dart 3.9+ pour faire tourner les tests. Ils doivent être régénérés lors de toute modification des annotations.

---

## Bonnes pratiques de sécurité pour les utilisateurs du template

### Stockage des tokens

```dart
// ✅ BON — Stockage chiffré avec flutter_secure_storage
await _storage.write(key: 'access_token', value: token);

// ❌ MAUVAIS — SharedPreferences (non chiffré)
await prefs.setString('access_token', token);
```

### Validation des entrées

Toujours valider les données à la frontière du système (entrées utilisateur, réponses API) :

```dart
// Utiliser ValidationFailure pour les erreurs de validation
if (input.isEmpty) return left(const ValidationFailure('Champ requis'));
```

### Authentification biométrique

Le package `local_auth` est intégré. Activez-le dans les écrans sensibles :

```dart
// TODO: [TEMPLATE] Activer la biométrie sur les écrans sensibles
final isAuthenticated = await localAuth.authenticate(
  localizedReason: 'Confirmez votre identité',
  options: const AuthenticationOptions(biometricOnly: true),
);
```

### Protection root / jailbreak

`freerasp` est disponible en commentaire dans `pubspec.yaml`. Décommentez-le pour les applications financières ou médicales.
