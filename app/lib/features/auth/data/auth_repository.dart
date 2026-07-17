import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../core/utils/app_logger.dart';
import '../domain/app_user.dart';

const _log = AppLogger('auth.repo');

/// Wraps Firebase Auth + the `users/{uid}` profile document (§2.2, §1.3).
///
/// On registration it creates the profile with `role: customer` — the only
/// role a client may assign; the security rules reject any attempt to set or
/// change `role` to something else (§5.5).
class AuthRepository {
  AuthRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  /// Streams the profile document for [uid] as an [AppUser]. Logs the resolved
  /// role — the quickest way to see why the admin area is (not) unlocked.
  Stream<AppUser?> watchUser(String uid) =>
      _userDoc(uid).snapshots().map((snap) {
        final data = snap.data();
        if (data == null) {
          _log.info('profile snapshot: no doc yet', {'uid': uid});
          return null;
        }
        final user = AppUser.fromJson(data, uid);
        _log.info('profile snapshot', {'uid': uid, 'role': user.role.name});
        return user;
      });

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _log.info('signIn start', {'email': maskEmail(email)});
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _log.info('signIn ok', {'uid': cred.user?.uid});
    } on FirebaseAuthException catch (e) {
      _log.error('signIn failed', data: {'code': e.code});
      rethrow;
    }
  }

  /// Ensures there is a signed-in user, signing in anonymously for guest
  /// checkout when needed (§3.2). Returns the uid. Requires the Anonymous
  /// provider to be enabled in Firebase Auth (see ADR 0003).
  Future<String> ensureSignedIn() async {
    final existing = _auth.currentUser;
    if (existing != null) {
      _log.info('ensureSignedIn: already signed in', {'uid': existing.uid});
      return existing.uid;
    }
    _log.info('ensureSignedIn: signing in anonymously');
    try {
      final cred = await _auth.signInAnonymously();
      _log.info('ensureSignedIn: anonymous ok', {'uid': cred.user!.uid});
      return cred.user!.uid;
    } on FirebaseAuthException catch (e) {
      _log.error('ensureSignedIn failed', data: {'code': e.code});
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    String? displayName,
    String locale = 'it',
  }) async {
    _log.info('register start', {'email': maskEmail(email)});
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = cred.user!.uid;
      if (displayName != null && displayName.trim().isNotEmpty) {
        await cred.user!.updateDisplayName(displayName.trim());
      }
      // Explicit role: 'customer' — required by the create rule (§5.5). Written
      // as a raw map (not AppUser.toJson) because toJson omits the server-owned
      // role field on purpose.
      await _userDoc(uid).set({
        'role': 'customer',
        'email': email.trim(),
        'displayName': displayName?.trim(),
        'locale': locale,
        'addresses': <Map<String, dynamic>>[],
        'consents': {
          'marketing': false,
          'medicineDataProcessing': false,
          'aiAssistant': false,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        'loyaltyPoints': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _log.info('register ok, profile created', {
        'uid': uid,
        'role': 'customer',
      });
    } on FirebaseAuthException catch (e) {
      _log.error('register failed', data: {'code': e.code});
      rethrow;
    }
  }

  /// Google SSO (§1.5). Federated sign-in through Firebase Auth's OAuth flow —
  /// a popup on web, the platform browser tab on mobile (`signInWithProvider`) —
  /// so no extra SDK/plugin is needed. Not supported on desktop/Windows: callers
  /// must guard with `PlatformSupport.federatedSignIn`.
  ///
  /// First sign-in creates the `users/{uid}` profile with `role: customer` (same
  /// shape as [register], §5.5); a returning user reuses the existing doc. With
  /// Firebase's default "one account per email", an email already registered via
  /// password throws `account-exists-with-different-credential` instead of
  /// creating a duplicate — the UI surfaces a localized hint to sign in first.
  Future<void> signInWithGoogle({String locale = 'it'}) async {
    _log.info('google start', {'flow': kIsWeb ? 'popup' : 'provider'});
    try {
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..setCustomParameters({'prompt': 'select_account'});
      final cred = kIsWeb
          ? await _auth.signInWithPopup(provider)
          : await _auth.signInWithProvider(provider);
      final user = cred.user;
      _log.info('google sign-in ok', {
        'uid': user?.uid,
        'newUser': cred.additionalUserInfo?.isNewUser,
      });
      if (user != null) await _ensureProfile(user, locale: locale);
    } on FirebaseAuthException catch (e) {
      _log.error('google sign-in failed', data: {'code': e.code});
      rethrow;
    }
  }

  /// Creates the `users/{uid}` profile on first federated sign-in; a no-op for a
  /// returning user whose doc already exists. Mirrors [register]'s shape so the
  /// create rule (`role == 'customer'`, §5.5) passes.
  Future<void> _ensureProfile(User user, {required String locale}) async {
    final doc = _userDoc(user.uid);
    final snap = await doc.get();
    if (snap.exists) {
      _log.info('profile exists, reusing', {'uid': user.uid});
      return;
    }
    await doc.set({
      'role': 'customer',
      'email': user.email,
      'displayName': user.displayName,
      'locale': locale,
      'addresses': <Map<String, dynamic>>[],
      'consents': {
        'marketing': false,
        'medicineDataProcessing': false,
        'aiAssistant': false,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      'loyaltyPoints': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
    _log.info('profile created', {'uid': user.uid, 'role': 'customer'});
  }

  /// Updates the current user's consents (§1.4). Targeted update so `role`
  /// stays untouched and the update rule passes.
  Future<void> updateConsents({
    required bool marketing,
    required bool medicineDataProcessing,
    required bool aiAssistant,
  }) async {
    final uid = currentUser?.uid;
    if (uid == null) {
      _log.info('updateConsents skipped: signed out');
      return;
    }
    await _userDoc(uid).update({
      'consents': {
        'marketing': marketing,
        'medicineDataProcessing': medicineDataProcessing,
        'aiAssistant': aiAssistant,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    });
    _log.info('consents updated', {
      'uid': uid,
      'marketing': marketing,
      'medicine': medicineDataProcessing,
      'ai': aiAssistant,
    });
  }

  Future<void> signOut() async {
    _log.info('signOut', {'uid': currentUser?.uid});
    await _auth.signOut();
  }
}
