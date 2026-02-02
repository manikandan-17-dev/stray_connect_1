// Manually created Firebase options from user-provided config.
// For multi-platform support, extend this as needed.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        // Fall back to Android options for non-mobile in dev; adjust if needed.
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC-DGxiPLrqeIXxZFCI8uRQZfp0uoI8SuQ',
    appId: '1:790257403484:android:7c62d96063a3e18f2b0899',
    messagingSenderId: '790257403484',
    projectId: 'bih20-75780',
    storageBucket: 'bih20-75780.firebasestorage.app',
  );
}
