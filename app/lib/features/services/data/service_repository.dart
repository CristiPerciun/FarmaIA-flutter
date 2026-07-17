import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/service.dart';

/// Reads the pharmacy services (collection `services`, §16.5). Public read,
/// staff write. Only `active` services are exposed to the client; category and
/// location filtering is done client-side over the streamed list (the catalog
/// pattern, §2.4) since the set is small.
class ServiceRepository {
  ServiceRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _services =>
      _firestore.collection('services');

  List<Service> _toServices(QuerySnapshot<Map<String, dynamic>> snap) =>
      snap.docs.map((d) => Service.fromJson(d.data(), d.id)).toList();

  /// Streams the active services (unordered by Firestore; the UI groups them
  /// by category).
  Stream<List<Service>> watchActiveServices() => _services
      .where('active', isEqualTo: true)
      .snapshots()
      .map(_toServices);

  /// One-shot read of the active services.
  Future<List<Service>> fetchActiveServices() async => _toServices(
    await _services.where('active', isEqualTo: true).get(),
  );

  /// A single service by id (null when it does not exist).
  Stream<Service?> watchService(String id) =>
      _services.doc(id).snapshots().map((s) {
        final data = s.data();
        return data == null ? null : Service.fromJson(data, s.id);
      });
}
