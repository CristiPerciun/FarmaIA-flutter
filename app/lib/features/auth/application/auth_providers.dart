import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../../core/utils/app_logger.dart';
import '../data/auth_repository.dart';
import '../domain/app_user.dart';

const _log = AppLogger('auth.state');

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  ),
);

/// Firebase auth state. Emits null when signed out or when the session expires
/// (§9.2) — the router listens to this to guard protected routes.
final authStateChangesProvider = StreamProvider<User?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges().map((user) {
    _log.info(
      user == null ? 'signed out' : 'signed in',
      {'uid': user?.uid, 'anon': user?.isAnonymous},
    );
    return user;
  }),
);

/// The signed-in Firebase user, or null. Synchronous read for guards.
final currentUserProvider = Provider<User?>(
  (ref) => ref.watch(authStateChangesProvider).valueOrNull,
);

/// The current user's profile document (role, consents, …). Null when signed
/// out or while the doc doesn't exist yet.
final appUserProvider = StreamProvider<AppUser?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream<AppUser?>.value(null);
  return ref.watch(authRepositoryProvider).watchUser(user.uid);
});

/// Whether the current user is staff (pharmacist/admin) — gates the admin area.
final isStaffProvider = Provider<bool>(
  (ref) => ref.watch(appUserProvider).valueOrNull?.isStaff ?? false,
);

/// The Cliente/Admin view toggle shown in the Profile for staff users (§2.2).
/// It only changes the UI view; it never grants privileges (those come from
/// `role` + security rules).
enum ViewMode { customer, admin }

final viewModeProvider = NotifierProvider<ViewModeNotifier, ViewMode>(
  ViewModeNotifier.new,
);

class ViewModeNotifier extends Notifier<ViewMode> {
  @override
  ViewMode build() => ViewMode.customer;

  void set(ViewMode mode) => state = mode;

  void toggle() =>
      state = state == ViewMode.customer ? ViewMode.admin : ViewMode.customer;
}
