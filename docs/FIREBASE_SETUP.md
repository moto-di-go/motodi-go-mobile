# Firebase setup (W0) — Moto'di Go mobile

Checklist to enable FCM push and Crashlytics/Perf for the Flutter app.

## 1. Firebase console

1. Create (or select) a Firebase project.
2. Add an **Android** app with package `com.motodigo.app`.
3. Add an **iOS** app with bundle id `com.motodigo.app` (adjust if renamed).
4. Download:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
5. These files are **gitignored** — do not commit them.

## 2. FlutterFire options

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=YOUR_FIREBASE_PROJECT
```

This generates `lib/firebase_options.dart`.

Alternatively, copy the template:

```bash
cp lib/firebase_options.dart.example lib/firebase_options.dart
# then replace REPLACE_ME_* with values from the Firebase console / flutterfire output
```

## 3. Android (Gradle)

With `android/app/google-services.json` present, the Google Services plugin is applied:

- root `android/settings.gradle.kts` — `com.google.gms.google-services` `4.5.0`, Crashlytics `3.0.8`, Perf `2.0.2` (`apply false`)
- app `android/app/build.gradle.kts` — `id("com.google.gms.google-services")` (+ Crashlytics / Perf)
- Firebase BoM `34.17.0` + `firebase-analytics` in the app module (must match FlutterFire: `firebase_core` ≥ 4.13.0). FlutterFire still owns Messaging / Auth / etc.

Building without `google-services.json` will fail while these plugins are enabled.

## 3b. iOS

Flutter resolves the Firebase iOS SDK via **CocoaPods** (`pod install` after `flutter pub get`), not Swift Package Manager. Prefer that path to avoid duplicate Firebase modules with FlutterFire.

1. Place `ios/Runner/GoogleService-Info.plist` (gitignored).
2. `AppDelegate` calls `FirebaseApp.configure()` once at launch (safe if Dart also calls `Firebase.initializeApp()`).
3. If you still follow the Firebase console SPM steps (`https://github.com/firebase/firebase-ios-sdk`), do **not** also let CocoaPods pull the same products — pick one integration style.

## 4. Wire `main.dart`

Prefer initializing with generated options:

```dart
import 'package:motodi_go_mobile/firebase_options.dart';

await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

Without `firebase_options.dart`, `Firebase.initializeApp()` still works on Android if `google-services.json` is present; iOS usually needs options or `GoogleService-Info.plist`.

## 5. Device token → backend

After login / session restore, call:

```dart
await getIt<NotificationService>().registerTokenWithBackend();
```

This POSTs to `POST /api/v1/notifications/devices` with `{ token, platform: ANDROID|IOS }`.

Hooked from `SessionCubit.setAuthenticated` and cold-start `bootstrap()` when a session exists.

## 6. Backend env

Align with `motodi-go-backend-core` / `motodi-go-devops`:

| Variable | Purpose |
|----------|---------|
| `FCM_ENABLED` | `false` = inbox only (QUEUED→SENT, no FCM call) |
| `FCM_PROJECT_ID` | Firebase project id |
| `FCM_CREDENTIALS_PATH` | Path to service account JSON on the API host |

## 7. Smoke test

1. Log in on a physical device / emulator with Google Play services.
2. Confirm `NotificationService.getToken()` returns a non-null token (debug log).
3. Confirm `POST /notifications/devices` returns 201.
4. Trigger a booking event; check inbox `GET /notifications` and (if `FCM_ENABLED=true`) a push.
