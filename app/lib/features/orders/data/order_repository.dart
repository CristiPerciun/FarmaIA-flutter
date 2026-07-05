import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import '../domain/order.dart';

/// Reads orders (collection `orders`, §5.1/§5.5). Orders are created and
/// mutated only by Cloud Functions; the client can read its own (rules gate on
/// `userRef == "users/<uid>"`).
class OrderRepository {
  OrderRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection('orders');

  /// The `userRef` value stored on orders — matches the security-rule check.
  static String userRefFor(String uid) => 'users/$uid';

  Stream<List<Order>> watchUserOrders(String uid) => _orders
      .where('userRef', isEqualTo: userRefFor(uid))
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snap) => snap.docs.map((d) => Order.fromJson(d.data(), d.id)).toList(),
      );

  Stream<Order?> watchOrder(String id) => _orders.doc(id).snapshots().map((s) {
    final data = s.data();
    return data == null ? null : Order.fromJson(data, s.id);
  });
}
