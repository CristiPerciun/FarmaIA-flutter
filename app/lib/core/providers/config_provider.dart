import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase/firebase_providers.dart';
import '../models/app_config.dart';

/// Operational config (`config/app`, §5.1): free-shipping threshold, shipping
/// cost, default VAT. Publicly readable. Falls back to [AppConfig] defaults
/// while loading or if the doc is missing, so pricing never blocks the UI.
final appConfigProvider = StreamProvider<AppConfig>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore.collection('config').doc('app').snapshots().map((snap) {
    final data = snap.data();
    return data == null ? const AppConfig() : AppConfig.fromJson(data);
  });
});

/// Synchronous best-effort config for pure calculations (defaults until loaded).
final appConfigValueProvider = Provider<AppConfig>(
  (ref) => ref.watch(appConfigProvider).valueOrNull ?? const AppConfig(),
);
