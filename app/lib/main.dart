import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app.dart';
import 'core/config/app_env.dart';
import 'core/firebase/firebase_init.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();

  // Keep the native splash up until the in-app reveal renders its first frame
  // (step 6.2/6.3, §16.3): same white background + emblem on both sides, so
  // the hand-off is seamless — no "double splash", no flicker.
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  // Path-based URLs on web (no '#') for indexing/SEO and to avoid 404s on the PWA (§3, §6.2).
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  final env = AppEnv.fromDartDefine();
  await initializeFirebase(env);

  runApp(ProviderScope(child: BaganzaApp(env: env)));
}
