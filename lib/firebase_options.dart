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
        return macos;
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
    apiKey: 'AIzaSyAgz1DCBIbpfwgk3Tcp_yNuNVVegHhGRVM',
    appId: '1:801703702253:web:f4a55627a38f00040f66e4',
    messagingSenderId: '801703702253',
    projectId: 'mess-management-system-3f0cb',
    authDomain: 'mess-management-system-3f0cb.firebaseapp.com',
    storageBucket: 'mess-management-system-3f0cb.appspot.com',
    measurementId: 'G-ZP5P9BJYXK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBeZiNFLk11mBt-Jb8yWEDYSvhW6RlUwl0',
    appId: '1:801703702253:android:3824157444c6daa20f66e4',
    messagingSenderId: '801703702253',
    projectId: 'mess-management-system-3f0cb',
    storageBucket: 'mess-management-system-3f0cb.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDRjTDJgXbq1m868z4vjjkXtr_5Xd_Uw9U',
    appId: '1:801703702253:ios:c2bda162c6186d370f66e4',
    messagingSenderId: '801703702253',
    projectId: 'mess-management-system-3f0cb',
    storageBucket: 'mess-management-system-3f0cb.appspot.com',
    iosBundleId: 'com.example.messManagementSystem',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDRjTDJgXbq1m868z4vjjkXtr_5Xd_Uw9U',
    appId: '1:801703702253:ios:e9a74c20a777e4e70f66e4',
    messagingSenderId: '801703702253',
    projectId: 'mess-management-system-3f0cb',
    storageBucket: 'mess-management-system-3f0cb.appspot.com',
    iosBundleId: 'com.example.messManagementSystem.RunnerTests',
  );
}