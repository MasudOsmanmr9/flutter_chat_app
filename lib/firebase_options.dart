// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD-ttRu4U9r7YRO_2ANDWxzl5xwUF7AHiQ',
    appId: '1:145409158738:web:34805e7cd3d3d0ef7a398b',
    messagingSenderId: '145409158738',
    projectId: 'test-chat-app-307f1',
    authDomain: 'test-chat-app-307f1.firebaseapp.com',
    storageBucket: 'test-chat-app-307f1.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCxpcZwx1MUuRuSxv_y5EgyJl1JP1QuARA',
    appId: '1:145409158738:android:9ab966edaa91a34c7a398b',
    messagingSenderId: '145409158738',
    projectId: 'test-chat-app-307f1',
    storageBucket: 'test-chat-app-307f1.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCCXf-Gb1LjcOUJ-Y2oIGfD0-9Unr8-gow',
    appId: '1:145409158738:ios:cf34124f482ee1ee7a398b',
    messagingSenderId: '145409158738',
    projectId: 'test-chat-app-307f1',
    storageBucket: 'test-chat-app-307f1.appspot.com',
    iosClientId: '145409158738-ip0mmq31c49fr9m2uitfm1pskr88i5h7.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterApplication1',
  );
}
