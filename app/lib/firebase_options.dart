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
    apiKey: 'AIzaSyBiW7U40QsMTHudbNEIvK6Zt97_aEQnF1E',
    appId: '1:180695762418:web:019982fc4129250b44576b',
    messagingSenderId: '180695762418',
    projectId: 'dbfarmacia-e6536',
    authDomain: 'dbfarmacia.firebaseapp.com',
    storageBucket: 'dbfarmacia-e6536.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBiW7U40QsMTHudbNEIvK6Zt97_aEQnF1E',
    appId: '1:180695762418:web:019982fc4129250b44576b',
    messagingSenderId: '180695762418',
    projectId: 'dbfarmacia-e6536',
    storageBucket: 'dbfarmacia-e6536.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBiW7U40QsMTHudbNEIvK6Zt97_aEQnF1E',
    appId: '1:180695762418:web:019982fc4129250b44576b',
    messagingSenderId: '180695762418',
    projectId: 'dbfarmacia-e6536',
    storageBucket: 'dbfarmacia.appspot.com',
    iosBundleId: 'dbfarmacia-e6536.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBiW7U40QsMTHudbNEIvK6Zt97_aEQnF1E',
    appId: '1:180695762418:web:019982fc4129250b44576b',
    messagingSenderId: '180695762418',
    projectId: 'dbfarmacia-e6536',
    storageBucket: 'dbfarmacia.appspot.com',
    iosBundleId: 'dbfarmacia-e6536.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBiW7U40QsMTHudbNEIvK6Zt97_aEQnF1E',
    appId: '1:180695762418:web:019982fc4129250b44576b',
    messagingSenderId: '180695762418',
    projectId: 'dbfarmacia-e6536',
    authDomain: 'dbfarmacia.firebaseapp.com',
    storageBucket: 'dbfarmacia-e6536.firebasestorage.app',
  );
}
