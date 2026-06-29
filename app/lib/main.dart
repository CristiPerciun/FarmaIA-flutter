import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app.dart';
import 'core/config/app_env.dart';
import 'core/firebase/firebase_init.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Path-based URLs on web (no '#') for indexing/SEO and to avoid 404s on the PWA (§3, §6.2).
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  final env = AppEnv.fromDartDefine();
  await initializeFirebase(env);

  runApp(ProviderScope(child: BaganzaApp(env: env)));
}
