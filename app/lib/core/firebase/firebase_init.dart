import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import '../config/app_env.dart';

/// Initializes Firebase and connects to emulators in dev mode.
Future<void> initializeFirebase(AppEnv env) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (env.isDev) {
    await _connectEmulators();
    if (!kIsWeb) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
    }
  } else {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
      webProvider: ReCaptchaV3Provider(
        const String.fromEnvironment('RECAPTCHA_SITE_KEY'),
      ),
    );
  }
}

Future<void> _connectEmulators() async {
  const host = kIsWeb ? 'localhost' : '10.0.2.2';

  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  await FirebaseStorage.instance.useStorageEmulator(host, 9199);

  if (kDebugMode) {
    debugPrint('Firebase emulators connected ($host)');
  }
}
