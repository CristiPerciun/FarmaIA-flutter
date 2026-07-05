import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
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

  // Offline catalog consultation (§9.1). Persistence is on by default on
  // mobile; this also turns it on for web (IndexedDB) so the already-loaded
  // published catalog stays navigable without a connection. Must be set before
  // any Firestore use, including the emulator wiring below.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  if (env.isDev) {
    await _connectEmulators();
    if (_appCheckSupported) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
    }
  } else if (_appCheckSupported) {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
      webProvider: ReCaptchaV3Provider(
        const String.fromEnvironment('RECAPTCHA_SITE_KEY'),
      ),
    );
  }
}

/// Firebase App Check ships native implementations only for Android, iOS,
/// macOS and web. On Windows/Linux desktop the plugin is absent, so calling
/// `activate` throws a [MissingPluginException].
bool get _appCheckSupported =>
    kIsWeb ||
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

Future<void> _connectEmulators() async {
  const host = kIsWeb ? 'localhost' : '10.0.2.2';

  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  await FirebaseStorage.instance.useStorageEmulator(host, 9199);
  FirebaseFunctions.instanceFor(
    region: 'europe-west1',
  ).useFunctionsEmulator(host, 5001);

  if (kDebugMode) {
    debugPrint('Firebase emulators connected ($host)');
  }
}
