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
    apiKey: 'AIzaSyArAmgZAMrl07NIeaeEbQKSpzfYVEA0SUw',
    appId: '1:264072799541:web:fbbc9e3b868fb9b885d87c',
    messagingSenderId: '264072799541',
    projectId: 'plantchat-c6299',
    authDomain: 'plantchat-c6299.firebaseapp.com',
    storageBucket: 'plantchat-c6299.firebasestorage.app',
    measurementId: 'G-WJMH2ZBVY2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDO_5DcDbcd2JdKwGuuxmnROKllcsEZqzE',
    appId: '1:264072799541:android:0390426bd8ea3e5385d87c',
    messagingSenderId: '264072799541',
    projectId: 'plantchat-c6299',
    storageBucket: 'plantchat-c6299.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCuR0Oe9gHUQ4Z9ENNaIpQV3GGGHrmDG3U',
    appId: '1:264072799541:ios:177bec60576e077185d87c',
    messagingSenderId: '264072799541',
    projectId: 'plantchat-c6299',
    storageBucket: 'plantchat-c6299.firebasestorage.app',
    iosBundleId: 'com.example.chatapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCuR0Oe9gHUQ4Z9ENNaIpQV3GGGHrmDG3U',
    appId: '1:264072799541:ios:177bec60576e077185d87c',
    messagingSenderId: '264072799541',
    projectId: 'plantchat-c6299',
    storageBucket: 'plantchat-c6299.firebasestorage.app',
    iosBundleId: 'com.example.chatapp',
  );

} 