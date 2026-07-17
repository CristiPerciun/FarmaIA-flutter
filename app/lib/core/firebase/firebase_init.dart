import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import '../config/app_env.dart';
import '../utils/app_logger.dart';

const _log = AppLogger('firebase.init');

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
    const recaptchaKey = String.fromEnvironment('RECAPTCHA_SITE_KEY');
    // Activating the web reCAPTCHA provider with an EMPTY site key throws
    // "Missing required parameters: sitekey" and cascades into
    // auth/network-request-failed. App Check isn't enforced yet (§8.4), so skip
    // it on web until a real RECAPTCHA_SITE_KEY is passed via --dart-define.
    if (kIsWeb && recaptchaKey.isEmpty) {
      _log.info('App Check skipped on web: no RECAPTCHA_SITE_KEY configured');
    } else {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.appAttest,
        webProvider: ReCaptchaV3Provider(recaptchaKey),
      );
    }
  }

  _log.info('Firebase initialized', {
    'env': env.isDev ? 'dev' : 'prod',
    'appCheck': _appCheckSupported,
    'project': DefaultFirebaseOptions.currentPlatform.projectId,
  });
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
  // 10.0.2.2 is the Android emulator's alias for the host machine's loopback.
  // Every OTHER target — web, iOS simulator, and Windows/macOS/Linux desktop —
  // reaches the host emulators on localhost. Using 10.0.2.2 off Android makes
  // every emulator call hang on an unreachable address (§2.8 desktop support).
  final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  final host = isAndroid ? '10.0.2.2' : 'localhost';

  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  // firebase_storage has no Windows implementation; skip it there (the plugin
  // otherwise logs "Storage Emulator is not available on Windows").
  if (_storageSupported) {
    await FirebaseStorage.instance.useStorageEmulator(host, 9199);
  }
  FirebaseFunctions.instanceFor(
    region: 'europe-west1',
  ).useFunctionsEmulator(host, 5001);

  _log.info('emulators connected', {'host': host, 'storage': _storageSupported});
}

/// firebase_storage ships for Android, iOS, macOS and web — not Windows/Linux.
bool get _storageSupported =>
    kIsWeb ||
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;
