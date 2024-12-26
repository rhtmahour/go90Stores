// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyDRPBTt43zYJn3v7OsEPbnw6WAuL9XhxlE',
    appId: '1:369820519327:web:9fa2c05414d4029aab0baa',
    messagingSenderId: '369820519327',
    projectId: 'go90store',
    authDomain: 'go90store.firebaseapp.com',
    storageBucket: 'go90store.firebasestorage.app',
    measurementId: 'G-M6KTQ32W55',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDWnhM4KDiq-VKqHaOODXrErORrXdIAuFE',
    appId: '1:369820519327:android:5b1d7cff03cabbdcab0baa',
    messagingSenderId: '369820519327',
    projectId: 'go90store',
    storageBucket: 'go90store.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCczrU7tEVKPK4GxVDo4btlDrcGv-pjx6M',
    appId: '1:369820519327:ios:1b81fd521f35f495ab0baa',
    messagingSenderId: '369820519327',
    projectId: 'go90store',
    storageBucket: 'go90store.firebasestorage.app',
    iosBundleId: 'com.example.go90stores',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCczrU7tEVKPK4GxVDo4btlDrcGv-pjx6M',
    appId: '1:369820519327:ios:1b81fd521f35f495ab0baa',
    messagingSenderId: '369820519327',
    projectId: 'go90store',
    storageBucket: 'go90store.firebasestorage.app',
    iosBundleId: 'com.example.go90stores',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDRPBTt43zYJn3v7OsEPbnw6WAuL9XhxlE',
    appId: '1:369820519327:web:8d2e79b977eb9cafab0baa',
    messagingSenderId: '369820519327',
    projectId: 'go90store',
    authDomain: 'go90store.firebaseapp.com',
    storageBucket: 'go90store.firebasestorage.app',
    measurementId: 'G-MZ82D6R5MV',
  );
}
