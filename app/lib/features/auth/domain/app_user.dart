import '../../../core/firebase/firestore_converters.dart';

/// Application role (collection `users`, §5.1, §2.2). Stored server-side and
/// **never** modifiable by the client (§5.5). The Cliente/Admin switch in the
/// Profile only toggles the UI view for users who already hold an elevated role.
enum UserRole {
  customer,
  pharmacist,
  admin;

  static UserRole fromStorage(Object? value) =>
      enumFromName(value, UserRole.values, UserRole.customer);

  /// pharmacist and admin can access the admin area and publish content (§5.5).
  bool get isStaff => this == UserRole.pharmacist || this == UserRole.admin;
}

/// GDPR consents (§1.4, §12.5). Each flag is opt-in and revocable from the
/// Profile; revoking marketing stops that processing accordingly (§9.2).
class UserConsents {
  const UserConsents({
    this.marketing = false,
    this.medicineDataProcessing = false,
    this.aiAssistant = false,
    this.updatedAt,
  });

  factory UserConsents.fromJson(Object? json) {
    final map = json is Map ? json : const {};
    return UserConsents(
      marketing: (map['marketing'] as bool?) ?? false,
      medicineDataProcessing: (map['medicineDataProcessing'] as bool?) ?? false,
      aiAssistant: (map['aiAssistant'] as bool?) ?? false,
      updatedAt: dateFromJson(map['updatedAt']),
    );
  }

  /// Consent to marketing communications.
  final bool marketing;

  /// Consent to process order data for medicines (cf. C-21/23, §1.4).
  final bool medicineDataProcessing;

  /// Explicit Art. 9 consent for health data typed into the AI chat (§12.5).
  final bool aiAssistant;

  final DateTime? updatedAt;

  UserConsents copyWith({
    bool? marketing,
    bool? medicineDataProcessing,
    bool? aiAssistant,
    DateTime? updatedAt,
  }) => UserConsents(
    marketing: marketing ?? this.marketing,
    medicineDataProcessing:
        medicineDataProcessing ?? this.medicineDataProcessing,
    aiAssistant: aiAssistant ?? this.aiAssistant,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'marketing': marketing,
    'medicineDataProcessing': medicineDataProcessing,
    'aiAssistant': aiAssistant,
    'updatedAt': dateToJson(updatedAt),
  };
}

/// A shipping/billing address (§5.1).
class Address {
  const Address({
    required this.label,
    required this.recipient,
    required this.street,
    required this.city,
    required this.zip,
    required this.province,
    this.country = 'IT',
    this.phone,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    label: (json['label'] as String?) ?? '',
    recipient: (json['recipient'] as String?) ?? '',
    street: (json['street'] as String?) ?? '',
    city: (json['city'] as String?) ?? '',
    zip: (json['zip'] as String?) ?? '',
    province: (json['province'] as String?) ?? '',
    country: (json['country'] as String?) ?? 'IT',
    phone: json['phone'] as String?,
  );

  final String label;
  final String recipient;
  final String street;
  final String city;
  final String zip;
  final String province;
  final String country;
  final String? phone;

  Map<String, dynamic> toJson() => {
    'label': label,
    'recipient': recipient,
    'street': street,
    'city': city,
    'zip': zip,
    'province': province,
    'country': country,
    'phone': phone,
  };
}

/// The user profile document (`users/{uid}`, doc id = Firebase Auth uid, §5.1).
class AppUser {
  const AppUser({
    required this.uid,
    required this.role,
    required this.email,
    required this.consents,
    this.displayName,
    this.phone,
    this.locale = 'it',
    this.addresses = const [],
    this.loyaltyPoints = 0,
    this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json, String uid) => AppUser(
    uid: uid,
    role: UserRole.fromStorage(json['role']),
    email: (json['email'] as String?) ?? '',
    displayName: json['displayName'] as String?,
    phone: json['phone'] as String?,
    locale: (json['locale'] as String?) ?? 'it',
    addresses: (json['addresses'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Address.fromJson)
        .toList(),
    consents: UserConsents.fromJson(json['consents']),
    loyaltyPoints: centsFromJson(json['loyaltyPoints']),
    createdAt: dateFromJson(json['createdAt']),
  );

  final String uid;
  final UserRole role;
  final String email;
  final String? displayName;
  final String? phone;
  final String locale;
  final List<Address> addresses;
  final UserConsents consents;
  final int loyaltyPoints;
  final DateTime? createdAt;

  bool get isStaff => role.isStaff;

  AppUser copyWith({
    UserRole? role,
    String? displayName,
    String? phone,
    String? locale,
    List<Address>? addresses,
    UserConsents? consents,
    int? loyaltyPoints,
  }) => AppUser(
    uid: uid,
    role: role ?? this.role,
    email: email,
    displayName: displayName ?? this.displayName,
    phone: phone ?? this.phone,
    locale: locale ?? this.locale,
    addresses: addresses ?? this.addresses,
    consents: consents ?? this.consents,
    loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
    createdAt: createdAt,
  );

  /// Client-writable fields only. `role` is intentionally excluded — it is set
  /// server-side and the security rules reject any client attempt to change it
  /// (§5.5).
  Map<String, dynamic> toJson() => {
    'email': email,
    'displayName': displayName,
    'phone': phone,
    'locale': locale,
    'addresses': addresses.map((a) => a.toJson()).toList(),
    'consents': consents.toJson(),
    'loyaltyPoints': loyaltyPoints,
    'createdAt': dateToJson(createdAt),
  };
}
