import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/location_repository.dart';
import '../domain/location.dart';

final locationRepositoryProvider = Provider<LocationRepository>(
  (ref) => LocationRepository(ref.watch(firestoreProvider)),
);

/// The pharmacy sites, ordered (§16.1). Auto-disposed so the listener is
/// dropped when no screen watches it.
final locationsProvider = StreamProvider.autoDispose<List<Location>>(
  (ref) => ref.watch(locationRepositoryProvider).watchLocations(),
);

/// A single site by id.
final locationProvider = StreamProvider.autoDispose.family<Location?, String>(
  (ref, id) => ref.watch(locationRepositoryProvider).watchLocation(id),
);

/// The site the user has selected as their reference (Home selector, §16.7).
/// Held in memory; null means "not chosen yet" and the UI defaults to the
/// first site. Kept as a non-disposed provider so the choice survives
/// navigation.
final selectedLocationIdProvider = NotifierProvider<SelectedLocation, String?>(
  SelectedLocation.new,
);

class SelectedLocation extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String id) => state = id;
}

/// Resolves the currently-selected [Location] against the streamed list,
/// defaulting to the first site when nothing is chosen yet.
final selectedLocationProvider = Provider.autoDispose<Location?>((ref) {
  final locations = ref.watch(locationsProvider).valueOrNull ?? const [];
  if (locations.isEmpty) return null;
  final id = ref.watch(selectedLocationIdProvider);
  if (id == null) return locations.first;
  return locations.firstWhere(
    (l) => l.id == id,
    orElse: () => locations.first,
  );
});
