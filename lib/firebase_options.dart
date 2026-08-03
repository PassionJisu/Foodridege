// Firebase 설정 파일
//
// 아래 명령어로 Firebase 프로젝트와 연결하세요:
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// 설정 완료 후 이 파일이 자동으로 덮어씌워집니다.

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
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // TODO: flutterfire configure 실행 후 실제 값으로 교체하세요

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC7ApxCrvUYQ0oDnwValqhyHgBGPBGoA0M',
    appId: '1:706548889762:web:5b5c8a61a103f3f921bffb',
    messagingSenderId: '706548889762',
    projectId: 'project-6ce78',
    authDomain: 'project-6ce78.firebaseapp.com',
    storageBucket: 'project-6ce78.firebasestorage.app',
    measurementId: 'G-ZX0EYDC3ZB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBHoNdNER-pbc0hc-T1c2o5zZhk7Z8YGhg',
    appId: '1:706548889762:android:1e0b9c04e611a75921bffb',
    messagingSenderId: '706548889762',
    projectId: 'project-6ce78',
    storageBucket: 'project-6ce78.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB_9TW1dIrUf8I8Olg8TqdXuL7xio9RYeg',
    appId: '1:706548889762:ios:1d9e5c6104fd1c5c21bffb',
    messagingSenderId: '706548889762',
    projectId: 'project-6ce78',
    storageBucket: 'project-6ce78.firebasestorage.app',
    iosBundleId: 'com.example.flutterApp',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB_9TW1dIrUf8I8Olg8TqdXuL7xio9RYeg',
    appId: '1:706548889762:ios:1d9e5c6104fd1c5c21bffb',
    messagingSenderId: '706548889762',
    projectId: 'project-6ce78',
    storageBucket: 'project-6ce78.firebasestorage.app',
    iosBundleId: 'com.example.flutterApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC7ApxCrvUYQ0oDnwValqhyHgBGPBGoA0M',
    appId: '1:706548889762:web:84ff7028368c598f21bffb',
    messagingSenderId: '706548889762',
    projectId: 'project-6ce78',
    authDomain: 'project-6ce78.firebaseapp.com',
    storageBucket: 'project-6ce78.firebasestorage.app',
    measurementId: 'G-B6D6W8YEE8',
  );
  static bool get isConfigured =>
      web.apiKey != 'YOUR_API_KEY' && web.projectId != 'YOUR_PROJECT_ID';
}
