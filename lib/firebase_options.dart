// GENERATED EXAMPLE — do not use as-is in production.
// 1. Run: dart pub global activate flutterfire_cli
// 2. Run: flutterfire configure --project=YOUR_FIREBASE_PROJECT
// 3. Copy the generated lib/firebase_options.dart (or replace placeholders below).
// See docs/FIREBASE_SETUP.md
//
// Copy this file to lib/firebase_options.dart after flutterfire configure,
// or keep firebase_options.dart gitignored if your team prefers secrets out of VCS.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web is not configured for Moto\'di Go. Run flutterfire configure.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform. '
          'See docs/FIREBASE_SETUP.md',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyANTMxg0NY25Hi_Ty8Virru2ahyc5soc4I',
    appId: '1:219457898678:android:70149a800b5aa8fca63e17',
    messagingSenderId: '219457898678',
    projectId: 'motodigo-acefd',
    storageBucket: 'motodigo-acefd.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME_IOS_API_KEY',
    appId: '1:219457898678:ios:bd553c2d7566e8e8a63e17',
    messagingSenderId: 'REPLACE_ME_SENDER_ID',
    projectId: 'motodigo-acefd',
    storageBucket: 'REPLACE_ME_PROJECT_ID.appspot.com',
    iosBundleId: 'com.motodigo.app',
  );
}
