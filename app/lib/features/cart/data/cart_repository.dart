import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/cart.dart';

/// Reads and writes the per-user cart (`carts/{uid}`, §5.1). The document id is
/// the uid; the security rules grant the owner full read/write (§5.5).
class CartRepository {
  CartRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection('carts').doc(uid);

  /// Streams the cart, emitting an empty cart when the doc doesn't exist yet.
  Stream<Cart> watch(String uid) => _doc(uid).snapshots().map((snap) {
    final data = snap.data();
    return data == null ? Cart(userRef: uid) : Cart.fromJson(data, uid);
  });

  Future<Cart> fetch(String uid) async {
    final snap = await _doc(uid).get();
    final data = snap.data();
    return data == null ? Cart(userRef: uid) : Cart.fromJson(data, uid);
  }

  /// Persists the whole cart for [uid], stamping `updatedAt` server-side.
  Future<void> save(String uid, Cart cart) => _doc(uid).set({
    ...cart.toJson(),
    'userRef': uid,
    'updatedAt': FieldValue.serverTimestamp(),
  });

  Future<void> clear(String uid) => _doc(uid).delete();
}
