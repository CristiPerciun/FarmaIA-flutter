import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baganza_app/features/services/data/appointment_repository.dart';
import 'package:baganza_app/features/services/data/location_repository.dart';
import 'package:baganza_app/features/services/data/service_repository.dart';
import 'package:baganza_app/features/services/domain/appointment.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  setUp(() => firestore = FakeFirebaseFirestore());

  group('LocationRepository', () {
    test('watchLocations returns sites ordered by `order`', () async {
      await firestore.collection('locations').doc('b2').set({
        'name': 'Baganza2',
        'order': 2,
      });
      await firestore.collection('locations').doc('b1').set({
        'name': 'Baganza',
        'order': 1,
      });

      final repo = LocationRepository(firestore);
      final locations = await repo.watchLocations().first;

      expect(locations.map((l) => l.id), ['b1', 'b2']);
      expect(locations.first.name, 'Baganza');
    });

    test('parses geo and openingHours', () async {
      await firestore.collection('locations').doc('b1').set({
        'name': 'Baganza',
        'order': 1,
        'geo': {'lat': 44.79, 'lng': 10.31},
        'isCupPoint': true,
        'openingHours': [
          {'weekday': 0, 'open': '08:30', 'close': '19:30', 'closed': false},
          {'weekday': 6, 'open': '', 'close': '', 'closed': true},
        ],
      });

      final repo = LocationRepository(firestore);
      final b1 = (await repo.fetchLocations()).single;

      expect(b1.lat, 44.79);
      expect(b1.isCupPoint, isTrue);
      expect(b1.openingHours, hasLength(2));
      expect(b1.openingHours.last.closed, isTrue);
    });
  });

  group('ServiceRepository', () {
    setUp(() async {
      await firestore.collection('services').doc('ecg').set({
        'name': {'it': 'ECG', 'en': 'ECG'},
        'category': 'telemedicina',
        'bookingType': 'appointment',
        'price': 3500,
        'availableAt': ['locations/baganza2'],
        'active': true,
      });
      await firestore.collection('services').doc('old').set({
        'name': {'it': 'Vecchio', 'en': 'Old'},
        'category': 'altro',
        'bookingType': 'appointment',
        'availableAt': [],
        'active': false,
      });
    });

    test('watchActiveServices excludes inactive services', () async {
      final repo = ServiceRepository(firestore);
      final services = await repo.watchActiveServices().first;

      expect(services.map((s) => s.id), ['ecg']);
      expect(services.single.price, 3500);
    });

    test('watchService streams a single service', () async {
      final repo = ServiceRepository(firestore);
      final service = await repo.watchService('ecg').first;
      expect(service?.name.it, 'ECG');
    });
  });

  group('AppointmentRepository', () {
    test('requestSlot writes a `requested` appointment owned by the user',
        () async {
      final repo = AppointmentRepository(firestore);
      final id = await repo.requestSlot(
        uid: 'uid-1',
        serviceRef: 'services/ecg',
        locationRef: 'locations/baganza2',
        slotStart: DateTime(2026, 8, 1, 9),
        slotEnd: DateTime(2026, 8, 1, 9, 20),
        contactPhone: '333',
      );

      final doc = await firestore.collection('appointments').doc(id).get();
      expect(doc.data()!['userRef'], 'users/uid-1');
      expect(doc.data()!['status'], 'requested');
      expect(doc.data()!['serviceRef'], 'services/ecg');
    });

    test('watchUserAppointments returns only the user\'s, newest slot first',
        () async {
      final repo = AppointmentRepository(firestore);
      await repo.requestSlot(
        uid: 'uid-1',
        serviceRef: 'services/ecg',
        locationRef: 'locations/baganza2',
        slotStart: DateTime(2026, 8, 1, 9),
        slotEnd: DateTime(2026, 8, 1, 9, 20),
      );
      await repo.requestSlot(
        uid: 'uid-1',
        serviceRef: 'services/ecg',
        locationRef: 'locations/baganza2',
        slotStart: DateTime(2026, 9, 1, 9),
        slotEnd: DateTime(2026, 9, 1, 9, 20),
      );
      await repo.requestSlot(
        uid: 'uid-2',
        serviceRef: 'services/ecg',
        locationRef: 'locations/baganza2',
        slotStart: DateTime(2026, 8, 15, 9),
        slotEnd: DateTime(2026, 8, 15, 9, 20),
      );

      final list = await repo.watchUserAppointments('uid-1').first;
      expect(list, hasLength(2));
      expect(list.first.slotStart, DateTime(2026, 9, 1, 9));
    });

    test('updateStatus transitions the appointment', () async {
      final repo = AppointmentRepository(firestore);
      final id = await repo.requestSlot(
        uid: 'uid-1',
        serviceRef: 'services/ecg',
        locationRef: 'locations/baganza2',
        slotStart: DateTime(2026, 8, 1, 9),
        slotEnd: DateTime(2026, 8, 1, 9, 20),
      );

      await repo.updateStatus(id, AppointmentStatus.confirmed);

      final doc = await firestore.collection('appointments').doc(id).get();
      expect(doc.data()!['status'], 'confirmed');
    });
  });
}
