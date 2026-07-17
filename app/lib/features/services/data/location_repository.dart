import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/location.dart';

/// Reads the pharmacy sites (collection `locations`, §16.5). Public read,
/// staff write (security rules) — the client only ever reads here.
class LocationRepository {
  LocationRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _locations =>
      _firestore.collection('locations');

  List<Location> _toLocations(QuerySnapshot<Map<String, dynamic>> snap) =>
      snap.docs.map((d) => Location.fromJson(d.data(), d.id)).toList();

  /// Streams the sites ordered by their `order` field (§16.1).
  Stream<List<Location>> watchLocations() =>
      _locations.orderBy('order').snapshots().map(_toLocations);

  /// One-shot read of all sites, ordered.
  Future<List<Location>> fetchLocations() async =>
      _toLocations(await _locations.orderBy('order').get());

  /// A single site by id (null when it does not exist).
  Stream<Location?> watchLocation(String id) =>
      _locations.doc(id).snapshots().map((s) {
        final data = s.data();
        return data == null ? null : Location.fromJson(data, s.id);
      });
}
