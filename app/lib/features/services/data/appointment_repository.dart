import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/appointment.dart';

/// Reads and writes appointments (collection `appointments`, §16.5). The owner
/// creates a *request* (`status == 'requested'`); staff manage the lifecycle
/// (confirm / cancel / complete) — enforced by the security rules (§5.5). No
/// Cloud Function is needed: the client create is a plain, rule-gated write.
class AppointmentRepository {
  AppointmentRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _appointments =>
      _firestore.collection('appointments');

  /// The `userRef` value stored on appointments — matches the rule check.
  static String userRefFor(String uid) => 'users/$uid';

  List<Appointment> _toList(QuerySnapshot<Map<String, dynamic>> snap) =>
      snap.docs.map((d) => Appointment.fromJson(d.data(), d.id)).toList();

  /// Creates a slot *request* for [uid]. Returns the new document id. `status`
  /// is forced to `requested` so the write passes the create rule; `createdAt`
  /// is a server timestamp.
  Future<String> requestSlot({
    required String uid,
    required String serviceRef,
    required String locationRef,
    required DateTime slotStart,
    required DateTime slotEnd,
    String? contactPhone,
    String? notes,
  }) async {
    final ref = await _appointments.add({
      'userRef': userRefFor(uid),
      'serviceRef': serviceRef,
      'locationRef': locationRef,
      'slotStart': Timestamp.fromDate(slotStart),
      'slotEnd': Timestamp.fromDate(slotEnd),
      'status': AppointmentStatus.requested.storageName,
      'contactPhone': contactPhone,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  /// The signed-in user's appointments, newest slot first.
  Stream<List<Appointment>> watchUserAppointments(String uid) => _appointments
      .where('userRef', isEqualTo: userRefFor(uid))
      .orderBy('slotStart', descending: true)
      .snapshots()
      .map(_toList);

  /// All appointments at a site, earliest slot first (staff queue, §5.5).
  Stream<List<Appointment>> watchByLocation(String locationRef) =>
      _appointments
          .where('locationRef', isEqualTo: locationRef)
          .orderBy('slotStart')
          .snapshots()
          .map(_toList);

  /// Staff transition of an appointment's status.
  Future<void> updateStatus(String id, AppointmentStatus status) =>
      _appointments.doc(id).update({'status': status.storageName});
}
