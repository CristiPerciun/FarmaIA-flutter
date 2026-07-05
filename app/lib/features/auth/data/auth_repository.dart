import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/app_user.dart';

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

  /// Streams the profile document for [uid] as an [AppUser].
  Stream<AppUser?> watchUser(String uid) =>
      _userDoc(uid).snapshots().map((snap) {
        final data = snap.data();
        if (data == null) return null;
        return AppUser.fromJson(data, uid);
      });

  Future<void> signIn({required String email, required String password}) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  /// Ensures there is a signed-in user, signing in anonymously for guest
  /// checkout when needed (§3.2). Returns the uid. Requires the Anonymous
  /// provider to be enabled in Firebase Auth (see ADR 0003).
  Future<String> ensureSignedIn() async {
    final existing = _auth.currentUser;
    if (existing != null) return existing.uid;
    final cred = await _auth.signInAnonymously();
    return cred.user!.uid;
  }

  Future<void> register({
    required String email,
    required String password,
    String? displayName,
    String locale = 'it',
  }) async {
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
  }

  /// Updates the current user's consents (§1.4). Targeted update so `role`
  /// stays untouched and the update rule passes.
  Future<void> updateConsents({
    required bool marketing,
    required bool medicineDataProcessing,
    required bool aiAssistant,
  }) async {
    final uid = currentUser?.uid;
    if (uid == null) return;
    await _userDoc(uid).update({
      'consents': {
        'marketing': marketing,
        'medicineDataProcessing': medicineDataProcessing,
        'aiAssistant': aiAssistant,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    });
  }

  Future<void> signOut() => _auth.signOut();
}
