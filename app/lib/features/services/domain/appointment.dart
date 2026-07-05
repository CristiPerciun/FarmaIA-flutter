import '../../../core/firebase/firestore_converters.dart';

/// Appointment lifecycle (§16.5). Internal bookings are slot *requests* handled
/// by staff (same logic as consultations, §13.3), to avoid taking time from the
/// counter (§16.4).
enum AppointmentStatus {
  requested,
  confirmed,
  completed,
  cancelled,
  noShow;

  static AppointmentStatus fromStorage(Object? value) {
    if (value == 'no_show') return AppointmentStatus.noShow;
    return enumFromName(
      value,
      AppointmentStatus.values,
      AppointmentStatus.requested,
    );
  }

  String get storageName => this == AppointmentStatus.noShow ? 'no_show' : name;
}

/// A service booking (collection `appointments`, §16.5). Accessible only to the
/// owner; staff manage confirmation/cancellation (§5.5).
class Appointment {
  const Appointment({
    required this.id,
    required this.userRef,
    required this.serviceRef,
    required this.locationRef,
    required this.slotStart,
    required this.slotEnd,
    required this.status,
    this.contactPhone,
    this.notes,
    this.createdAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json, String id) =>
      Appointment(
        id: id,
        userRef: (json['userRef'] as String?) ?? '',
        serviceRef: (json['serviceRef'] as String?) ?? '',
        locationRef: (json['locationRef'] as String?) ?? '',
        slotStart: dateFromJson(json['slotStart']),
        slotEnd: dateFromJson(json['slotEnd']),
        status: AppointmentStatus.fromStorage(json['status']),
        contactPhone: json['contactPhone'] as String?,
        notes: json['notes'] as String?,
        createdAt: dateFromJson(json['createdAt']),
      );

  final String id;
  final String userRef;
  final String serviceRef;
  final String locationRef;
  final DateTime? slotStart;
  final DateTime? slotEnd;
  final AppointmentStatus status;
  final String? contactPhone;
  final String? notes;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
    'userRef': userRef,
    'serviceRef': serviceRef,
    'locationRef': locationRef,
    'slotStart': dateToJson(slotStart),
    'slotEnd': dateToJson(slotEnd),
    'status': status.storageName,
    'contactPhone': contactPhone,
    'notes': notes,
    'createdAt': dateToJson(createdAt),
  };
}
