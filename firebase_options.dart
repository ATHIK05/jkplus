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
    apiKey: 'AIzaSyBpQ7PBOKmMfLJZAJTYS1z1ulLu3RzlPxo',
    appId: '1:538013257530:web:949dde34478baca0120a03',
    messagingSenderId: '538013257530',
    projectId: 'jkplus-94732',
    authDomain: 'jkplus-94732.firebaseapp.com',
    storageBucket: 'jkplus-94732.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAyjzPaIh7G0KIVBy8Yi-IlpY_BtKoNTNw',
    appId: '1:538013257530:android:89582c70b9407ef5120a03',
    messagingSenderId: '538013257530',
    projectId: 'jkplus-94732',
    storageBucket: 'jkplus-94732.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDBnSku3yNjaktIY-js91HoQ6RlYv6YYHk',
    appId: '1:538013257530:ios:58579b83ef316fce120a03',
    messagingSenderId: '538013257530',
    projectId: 'jkplus-94732',
    storageBucket: 'jkplus-94732.firebasestorage.app',
    iosBundleId: 'com.example.jkplus',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDBnSku3yNjaktIY-js91HoQ6RlYv6YYHk',
    appId: '1:538013257530:ios:58579b83ef316fce120a03',
    messagingSenderId: '538013257530',
    projectId: 'jkplus-94732',
    storageBucket: 'jkplus-94732.firebasestorage.app',
    iosBundleId: 'com.example.jkplus',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBpQ7PBOKmMfLJZAJTYS1z1ulLu3RzlPxo',
    appId: '1:538013257530:web:ce1e5e9b45a40db4120a03',
    messagingSenderId: '538013257530',
    projectId: 'jkplus-94732',
    authDomain: 'jkplus-94732.firebaseapp.com',
    storageBucket: 'jkplus-94732.firebasestorage.app',
  );

}