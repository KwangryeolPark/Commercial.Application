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
    apiKey: 'AIzaSyANTa41_Z99etiEeZm5QqPAnbX_ygHOQgU',
    appId: '1:65926409161:web:53f1426b9beff98afb1618',
    messagingSenderId: '65926409161',
    projectId: 'fir-test-158a3',
    authDomain: 'fir-test-158a3.firebaseapp.com',
    databaseURL: 'https://fir-test-158a3-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'fir-test-158a3.appspot.com',
    measurementId: 'G-70JG4VZ60W',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBizaUwKHiKztwwTOXKAPyPpF1GLKfOSoo',
    appId: '1:65926409161:android:fd296ebffddd9cccfb1618',
    messagingSenderId: '65926409161',
    projectId: 'fir-test-158a3',
    databaseURL: 'https://fir-test-158a3-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'fir-test-158a3.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAqLnO3zHwlrFCHfrzRnv_AedLj4K44B-0',
    appId: '1:65926409161:ios:0f7feefd3120560dfb1618',
    messagingSenderId: '65926409161',
    projectId: 'fir-test-158a3',
    databaseURL: 'https://fir-test-158a3-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'fir-test-158a3.appspot.com',
    iosClientId: '65926409161-f4esvebfs9rh6u4r7enha670v0kfblhu.apps.googleusercontent.com',
    iosBundleId: 'com.kmongproject.myApplication',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAqLnO3zHwlrFCHfrzRnv_AedLj4K44B-0',
    appId: '1:65926409161:ios:0f7feefd3120560dfb1618',
    messagingSenderId: '65926409161',
    projectId: 'fir-test-158a3',
    databaseURL: 'https://fir-test-158a3-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'fir-test-158a3.appspot.com',
    iosClientId: '65926409161-f4esvebfs9rh6u4r7enha670v0kfblhu.apps.googleusercontent.com',
    iosBundleId: 'com.kmongproject.myApplication',
  );
}