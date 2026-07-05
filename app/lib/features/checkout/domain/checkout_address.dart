/// Minimal shipping/contact details for checkout (CRO: fewest fields, Parte 2
/// §2). Stored on the order as `shippingAddress`.
class CheckoutAddress {
  const CheckoutAddress({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.street,
    required this.city,
    required this.zip,
    required this.province,
  });

  final String fullName;
  final String email;
  final String phone;
  final String street;
  final String city;
  final String zip;
  final String province;

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'street': street,
    'city': city,
    'zip': zip,
    'province': province,
  };
}
