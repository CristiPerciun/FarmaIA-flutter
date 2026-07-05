import '../../../core/firebase/firestore_converters.dart';
import '../../../core/models/localized_text.dart';

/// Service category (§16.5).
enum ServiceCategory {
  autoanalisi,
  telemedicina,
  consulenza,
  tampone,
  cup,
  altro;

  static ServiceCategory fromStorage(Object? value) =>
      enumFromName(value, ServiceCategory.values, ServiceCategory.altro);
}

/// How a service is booked (§16.5). `externalLink` deep-links to regional
/// systems (CUPWeb/ER Salute) which the app cannot book natively (§16.6).
enum BookingType {
  freeAccess,
  appointment,
  externalLink;

  static BookingType fromStorage(Object? value) {
    return switch (value) {
      'free_access' => BookingType.freeAccess,
      'appointment' => BookingType.appointment,
      'external_link' => BookingType.externalLink,
      _ => BookingType.appointment,
    };
  }

  String get storageName => switch (this) {
    BookingType.freeAccess => 'free_access',
    BookingType.appointment => 'appointment',
    BookingType.externalLink => 'external_link',
  };
}

/// A pharmacy service (collection `services`, §16.5). `price` is nullable when
/// free or quote-based; amounts are integer cents.
class Service {
  const Service({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.category,
    required this.bookingType,
    required this.availableAt,
    required this.prep,
    this.price,
    this.externalUrl,
    this.durationMin,
    this.requiresFasting = false,
    this.active = true,
  });

  factory Service.fromJson(Map<String, dynamic> json, String id) => Service(
    id: id,
    slug: LocalizedText.fromJson(json['slug']),
    name: LocalizedText.fromJson(json['name']),
    description: LocalizedText.fromJson(json['description']),
    category: ServiceCategory.fromStorage(json['category']),
    price: json['price'] == null ? null : centsFromJson(json['price']),
    bookingType: BookingType.fromStorage(json['bookingType']),
    externalUrl: json['externalUrl'] as String?,
    availableAt: stringListFromJson(json['availableAt']),
    prep: LocalizedText.fromJson(json['prep']),
    durationMin: json['durationMin'] == null
        ? null
        : centsFromJson(json['durationMin']),
    requiresFasting: (json['requiresFasting'] as bool?) ?? false,
    active: (json['active'] as bool?) ?? true,
  );

  final String id;
  final LocalizedText slug;
  final LocalizedText name;
  final LocalizedText description;
  final ServiceCategory category;
  final int? price;
  final BookingType bookingType;
  final String? externalUrl;
  final List<String> availableAt;
  final LocalizedText prep;
  final int? durationMin;
  final bool requiresFasting;
  final bool active;

  bool get isFree => price == null || price == 0;

  Map<String, dynamic> toJson() => {
    'slug': slug.toJson(),
    'name': name.toJson(),
    'description': description.toJson(),
    'category': category.name,
    'price': price,
    'bookingType': bookingType.storageName,
    'externalUrl': externalUrl,
    'availableAt': availableAt,
    'prep': prep.toJson(),
    'durationMin': durationMin,
    'requiresFasting': requiresFasting,
    'active': active,
  };
}
