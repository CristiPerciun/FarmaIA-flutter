/// Firebase configuration for project dbFarmacia.
///
/// Run `flutterfire configure --project=dbfarmacia` to regenerate with
/// platform-specific credentials from the Firebase console.
library;

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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyReplaceViaFlutterfireConfigure',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'dbfarmacia',
    authDomain: 'dbfarmacia.firebaseapp.com',
    storageBucket: 'dbfarmacia.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyReplaceViaFlutterfireConfigure',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'dbfarmacia',
    storageBucket: 'dbfarmacia.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyReplaceViaFlutterfireConfigure',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'dbfarmacia',
    storageBucket: 'dbfarmacia.appspot.com',
    iosBundleId: 'com.farmaciabaganza.baganzaApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyReplaceViaFlutterfireConfigure',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'dbfarmacia',
    storageBucket: 'dbfarmacia.appspot.com',
    iosBundleId: 'com.farmaciabaganza.baganzaApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyReplaceViaFlutterfireConfigure',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'dbfarmacia',
    authDomain: 'dbfarmacia.firebaseapp.com',
    storageBucket: 'dbfarmacia.appspot.com',
  );
}
