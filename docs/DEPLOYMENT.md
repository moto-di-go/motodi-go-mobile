# Guide de Déploiement

Ce guide couvre le déploiement de bout en bout pour Android et iOS, en environnements manuel et automatisé (CI/CD).

---

## Prérequis

### Android
- **Java 17** : `java -version`
- **Android SDK** avec Build Tools 34+
- **Keystore** de signature : `.jks` ou `.keystore`
- **Google Play Console** avec accès développeur
- **Service Account JSON** pour l'API Google Play (CI/CD)

### iOS (macOS uniquement)
- **Xcode 15+**
- **Apple Developer Program** (99$/an)
- **Certificat de distribution** + **Profil de provisioning**
- **App Store Connect API Key** (pour CI/CD)

---

## Configuration initiale

### Étape 1 — Renommer l'application

```bash
make rename
# Saisir : com.votreentreprise.votreapp
# Saisir : Nom de Votre App
```

Ou manuellement :
- `android/app/build.gradle.kts` → `applicationId`
- `ios/Runner/Info.plist` → `CFBundleDisplayName` + `CFBundleIdentifier`
- `pubspec.yaml` → `name`
- `lib/main.dart` → titre de l'application

### Étape 2 — Firebase

Voir le checklist détaillé : [`docs/FIREBASE_SETUP.md`](FIREBASE_SETUP.md).

```bash
# 1. Installer FlutterFire CLI
dart pub global activate flutterfire_cli

# 2. Configurer Firebase (crée google-services.json et GoogleService-Info.plist)
flutterfire configure --project=VOTRE_PROJET_FIREBASE

# 3. Ou copier le template : lib/firebase_options.dart.example → lib/firebase_options.dart
# 4. Ces fichiers plateforme sont dans .gitignore — NE JAMAIS les commiter
# 5. Décommenter les plugins google-services dans android/*.gradle.kts
```

Dans `lib/main.dart`, préférer :
```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
```

### Étape 3 — Variables d'environnement

```bash
cp .env.example .env
# Éditer .env avec les valeurs de production
```

---

## Déploiement Android

### Configuration de la signature

Créer `android/key.properties` (**ignoré par git**) :

```properties
storePassword=VOTRE_MOT_DE_PASSE_KEYSTORE
keyPassword=VOTRE_MOT_DE_PASSE_CLE
keyAlias=VOTRE_ALIAS
storeFile=../app/release.jks
```

Vérifier que `android/app/build.gradle.kts` lit ce fichier :

```kotlin
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        create("release") {
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

### Build manuel

```bash
# App Bundle (Google Play Store)
make build-aab-prod
# → build/app/outputs/bundle/release/app-release.aab

# APK (distribution directe)
make build-apk-prod
# → build/app/outputs/flutter-apk/app-release.apk
```

### Déploiement CI/CD (GitHub Actions)

Configurer les secrets GitHub :

| Secret | Description |
|--------|-------------|
| `KEYSTORE_BASE64` | Contenu du `.jks` encodé en base64 : `base64 -i release.jks` |
| `KEYSTORE_PASSWORD` | Mot de passe du keystore |
| `KEY_ALIAS` | Alias de la clé de signature |
| `KEY_PASSWORD` | Mot de passe de la clé |
| `PLAY_STORE_SERVICE_ACCOUNT_JSON` | JSON du compte de service Google Play |
| `API_BASE_URL_PROD` | URL de l'API en production |

Variables (non-sensibles) :

| Variable | Description |
|----------|-------------|
| `ANDROID_PACKAGE_NAME` | Ex: `com.votreentreprise.votreapp` |
| `APP_NAME` | Ex: `Mon Application` |

**Déclencher une release :**

```bash
# Créer un tag → déclenche automatiquement release-android.yml
git tag v1.0.0
git push origin v1.0.0

# Ou manuellement depuis GitHub Actions → workflow_dispatch
```

---

## Déploiement iOS

### Configuration Xcode

1. Ouvrir `ios/Runner.xcworkspace` dans Xcode
2. Sélectionner la cible **Runner**
3. Onglet **Signing & Capabilities** :
   - Cocher **Automatically manage signing** (développement)
   - Ou configurer manuellement le profil de provisioning (distribution)
4. `Bundle Identifier` = `com.votreentreprise.votreapp`

### Créer le fichier ExportOptions.plist

Créer `ios/ExportOptions.plist` (**ignoré par git**) :

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>uploadBitcode</key>
    <false/>
    <key>compileBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>teamID</key>
    <string>VOTRE_TEAM_ID</string>
</dict>
</plist>
```

### Build manuel

```bash
# Build IPA
make build-ios-prod
# → ouvrir Xcode Organizer pour uploader vers TestFlight

# Ou directement depuis la ligne de commande (nécessite un Mac)
flutter build ipa --release \
  --obfuscate \
  --split-debug-info=build/symbols/ios \
  --dart-define=APP_ENV=production \
  --export-options-plist=ios/ExportOptions.plist
```

### Déploiement CI/CD (GitHub Actions)

Configurer les secrets GitHub :

| Secret | Description |
|--------|-------------|
| `IOS_CERTIFICATE_BASE64` | Certificat P12 : `base64 -i distribution.p12` |
| `IOS_CERTIFICATE_PASSWORD` | Mot de passe du P12 |
| `IOS_PROVISIONING_PROFILE` | Profil : `base64 -i profile.mobileprovision` |
| `IOS_KEYCHAIN_PASSWORD` | Mot de passe keychain temporaire (aléatoire) |
| `APP_STORE_CONNECT_API_KEY_ID` | Key ID App Store Connect |
| `APP_STORE_CONNECT_API_ISSUER_ID` | Issuer ID App Store Connect |
| `APP_STORE_CONNECT_API_KEY_BASE64` | Clé P8 : `base64 -i AuthKey_XXXXXX.p8` |

---

## Numérotation des versions

Format : `version: MAJOR.MINOR.PATCH+BUILD` dans `pubspec.yaml`

```yaml
version: 1.2.3+45   # 1.2.3 = version affiché · 45 = build number
```

**Convention :**
- `MAJOR` : changement incompatible / refonte majeure
- `MINOR` : nouvelle fonctionnalité
- `PATCH` : correction de bug
- `BUILD` : incrémenté à chaque déploiement CI

Automatiser avec le numéro de run GitHub Actions :

```yaml
- name: Set build number
  run: |
    flutter build appbundle \
      --build-number=${{ github.run_number }} \
      ...
```

---

## Environnements

| Environnement | Commande | `.env` | Firebase |
|---|---|---|---|
| Development | `make run-dev` | `.env` | Projet dev |
| Staging | `make run-staging` | `.env.staging` | Projet staging |
| Production | `make run-prod` | `.env.prod` | Projet prod |

Créer `.env.staging` et `.env.prod` à partir de `.env.example`.

---

## Appareil physique + Docker local (LAN / hotspot)

Objectif : installer un APK release sur un vrai smartphone Android qui parle au stack Docker
tourant sur le PC (gateway `:8080`, MinIO `:9000`).

Ne **pas** modifier `.env` pour l’IP LAN : `make run-dev` / émulateur restent sur `10.0.2.2`.
L’URL appareil est injectée au build via `--dart-define=API_BASE_URL=...`
(`AppConfig.apiBaseUrl` dans `lib/core/config/app_config.dart`).

### 1. Préparer le réseau

1. Démarrer le stack : depuis `motodi-go-devops`, `docker compose up` (gateway healthy).
2. Connecter le PC au hotspot du téléphone (ou même Wi-Fi).
3. Noter l’**IPv4 du PC** (pas celle du téléphone) :

```powershell
Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias 'Wi-Fi' | Select-Object IPAddress
# ou: ipconfig
```

4. Smoke depuis Chrome **sur le téléphone** :

```text
http://<IP_PC>:8080/actuator/health/readiness
```

Doit répondre `{"status":"UP"}`. Si échec : pare-feu Windows (ports TCP 8080 et 9000),
bind Docker (`0.0.0.0` et non seulement `127.0.0.1`), ou isolation hotspot Android.

Règles pare-feu (PowerShell **Administrateur**) si besoin :

```powershell
New-NetFirewallRule -DisplayName 'MotoDiGo-API-Gateway-8080' -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow -Profile Any
New-NetFirewallRule -DisplayName 'MotoDiGo-MinIO-9000' -Direction Inbound -Protocol TCP -LocalPort 9000 -Action Allow -Profile Any
```

### 2. Builder l’APK

```bash
cd motodi-go-mobile
make build-apk-device LAN_IP=192.168.43.12
# → build/app/outputs/flutter-apk/app-release.apk
```

Si l’IP du PC change, **rebuild** obligatoire (URL cuite dans l’APK).

### 3. Installer

USB debugging + sources inconnues, puis :

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Si une version debug est déjà installée : `adb uninstall com.motodigo.app` puis réinstaller
(signatures différentes).

### 4. Fallback USB (`adb reverse`)

Si le hotspot isole le trafic téléphone → clients :

```bash
adb reverse tcp:8080 tcp:8080
adb reverse tcp:9000 tcp:9000
make build-apk-device LAN_IP=127.0.0.1
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

### 5. Smoke fonctionnalités

Rejouer login/OTP, home, urbain, interurbain, cartes offline (MinIO), images KYC/annonces, SSE suivi.

---

## Checklist pré-release

- [ ] `make check` → lint + tests passent
- [ ] Version mise à jour dans `pubspec.yaml`
- [ ] CHANGELOG.md mis à jour
- [ ] Firebase configuré et testé
- [ ] `.env` de production configuré
- [ ] Keystore / certificats à jour
- [ ] Tests de smoke sur un appareil physique
- [ ] Crashlytics activé et fonctionnel
- [ ] Analytics et performance monitoring vérifiés
