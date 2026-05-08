/// Firebase Options - PLACEHOLDER FILE
///
/// ⚠️ IMPORTANT: This file is a placeholder.
/// You MUST replace it by running:
///
///     flutterfire configure
///
/// in your project root after setting up Firebase.
/// See README.md for full Firebase setup instructions.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform. '
          'Run `flutterfire configure` to generate this file.',
        );
    }
  }

  // ⚠️ Replace these placeholder values with your real Firebase config.
  // Run `flutterfire configure` from the project root and it will
  // overwrite this file automatically.

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBqoxzfPG7fw5Pu5TwmO4ARX1wC0x1gN34',
    appId: '1:836453068263:web:e37404ad3181f2af062142',
    messagingSenderId: '836453068263',
    projectId: 'braindump-ai-6376f',
    authDomain: 'braindump-ai-6376f.firebaseapp.com',
    storageBucket: 'braindump-ai-6376f.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBcmJerts5k32N-pmbCQppObWrNynl2HK4',
    appId: '1:836453068263:android:f0cdf24d9a193aba062142',
    messagingSenderId: '836453068263',
    projectId: 'braindump-ai-6376f',
    storageBucket: 'braindump-ai-6376f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCYBoCG1QC6nQLAFgi1UITfZLzfbRo3waE',
    appId: '1:836453068263:ios:dc6714671fad29b7062142',
    messagingSenderId: '836453068263',
    projectId: 'braindump-ai-6376f',
    storageBucket: 'braindump-ai-6376f.firebasestorage.app',
    iosBundleId: 'com.example.braindumpPreview',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCYBoCG1QC6nQLAFgi1UITfZLzfbRo3waE',
    appId: '1:836453068263:ios:dc6714671fad29b7062142',
    messagingSenderId: '836453068263',
    projectId: 'braindump-ai-6376f',
    storageBucket: 'braindump-ai-6376f.firebasestorage.app',
    iosBundleId: 'com.example.braindumpPreview',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBqoxzfPG7fw5Pu5TwmO4ARX1wC0x1gN34',
    appId: '1:836453068263:web:0c4c0eaf291f7134062142',
    messagingSenderId: '836453068263',
    projectId: 'braindump-ai-6376f',
    authDomain: 'braindump-ai-6376f.firebaseapp.com',
    storageBucket: 'braindump-ai-6376f.firebasestorage.app',
  );

}