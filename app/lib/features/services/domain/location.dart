import '../../../core/firebase/firestore_converters.dart';

/// Opening hours for a single weekday (0 = Monday … 6 = Sunday).
class OpeningHours {
  const OpeningHours({
    required this.weekday,
    required this.open,
    required this.close,
    this.closed = false,
  });

  factory OpeningHours.fromJson(Map<String, dynamic> json) => OpeningHours(
    weekday: centsFromJson(json['weekday']),
    open: (json['open'] as String?) ?? '',
    close: (json['close'] as String?) ?? '',
    closed: (json['closed'] as bool?) ?? false,
  );

  final int weekday;
  final String open;
  final String close;
  final bool closed;

  Map<String, dynamic> toJson() => {
    'weekday': weekday,
    'open': open,
    'close': close,
    'closed': closed,
  };
}

/// A pharmacy location (collection `locations`, §16.5). Baganza has 3 sites in
/// Parma; Baganza2 is the services hub and a CUP point.
class Location {
  const Location({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.province,
    required this.zip,
    required this.phone,
    this.whatsapp,
    this.email,
    this.lat,
    this.lng,
    this.openingHours = const [],
    this.isCupPoint = false,
    this.services = const [],
    this.order = 0,
  });

  factory Location.fromJson(Map<String, dynamic> json, String id) {
    final geo = json['geo'] is Map ? json['geo'] as Map : const {};
    return Location(
      id: id,
      name: (json['name'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      city: (json['city'] as String?) ?? '',
      province: (json['province'] as String?) ?? '',
      zip: (json['zip'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      whatsapp: json['whatsapp'] as String?,
      email: json['email'] as String?,
      lat: (geo['lat'] as num?)?.toDouble(),
      lng: (geo['lng'] as num?)?.toDouble(),
      openingHours: (json['openingHours'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(OpeningHours.fromJson)
          .toList(),
      isCupPoint: (json['isCupPoint'] as bool?) ?? false,
      services: stringListFromJson(json['services']),
      order: centsFromJson(json['order']),
    );
  }

  final String id;
  final String name;
  final String address;
  final String city;
  final String province;
  final String zip;
  final String phone;
  final String? whatsapp;
  final String? email;
  final double? lat;
  final double? lng;
  final List<OpeningHours> openingHours;
  final bool isCupPoint;
  final List<String> services;
  final int order;

  Map<String, dynamic> toJson() => {
    'name': name,
    'address': address,
    'city': city,
    'province': province,
    'zip': zip,
    'phone': phone,
    'whatsapp': whatsapp,
    'email': email,
    'geo': {'lat': lat, 'lng': lng},
    'openingHours': openingHours.map((h) => h.toJson()).toList(),
    'isCupPoint': isCupPoint,
    'services': services,
    'order': order,
  };
}
