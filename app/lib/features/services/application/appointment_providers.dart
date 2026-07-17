import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../auth/application/auth_providers.dart';
import '../data/appointment_repository.dart';
import '../domain/appointment.dart';

final appointmentRepositoryProvider = Provider<AppointmentRepository>(
  (ref) => AppointmentRepository(ref.watch(firestoreProvider)),
);

/// The signed-in user's appointments, newest first. Empty when signed out.
final userAppointmentsProvider =
    StreamProvider.autoDispose<List<Appointment>>((ref) {
      final user = ref.watch(currentUserProvider);
      if (user == null) return Stream.value(const []);
      return ref
          .watch(appointmentRepositoryProvider)
          .watchUserAppointments(user.uid);
    });

/// All appointments at a site, earliest first — the staff queue (§5.5). Gated
/// to staff by the security rules; the admin screen watches this per site.
final locationAppointmentsProvider =
    StreamProvider.autoDispose.family<List<Appointment>, String>(
      (ref, locationRef) => ref
          .watch(appointmentRepositoryProvider)
          .watchByLocation(locationRef),
    );

/// Creates slot requests and, for staff, transitions their status.
final appointmentControllerProvider = Provider<AppointmentController>(
  (ref) => AppointmentController(ref),
);

class AppointmentController {
  AppointmentController(this._ref);
  final Ref _ref;

  /// Requests a slot for the signed-in user. Throws [StateError] when signed
  /// out (the UI guards this earlier). Returns the new appointment id.
  Future<String> requestSlot({
    required String serviceRef,
    required String locationRef,
    required DateTime slotStart,
    required DateTime slotEnd,
    String? contactPhone,
    String? notes,
  }) {
    final user = _ref.read(currentUserProvider);
    if (user == null) {
      throw StateError('Cannot request a slot while signed out');
    }
    return _ref
        .read(appointmentRepositoryProvider)
        .requestSlot(
          uid: user.uid,
          serviceRef: serviceRef,
          locationRef: locationRef,
          slotStart: slotStart,
          slotEnd: slotEnd,
          contactPhone: contactPhone,
          notes: notes,
        );
  }

  /// Staff transition (confirm / cancel / complete / no-show).
  Future<void> setStatus(String id, AppointmentStatus status) => _ref
      .read(appointmentRepositoryProvider)
      .updateStatus(id, status);
}
