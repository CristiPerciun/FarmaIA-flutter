import '../firebase/firestore_converters.dart';

/// Operational parameters (collection `config`, §5.1) — e.g. free-shipping
/// threshold, shipping cost, default VAT rate. Publicly readable, admin-writable
/// (§5.5). All monetary amounts are integer cents.
class AppConfig {
  const AppConfig({
    this.freeShippingThreshold = 4900,
    this.shippingCost = 490,
    this.defaultVatRate = 22,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) => AppConfig(
    freeShippingThreshold: centsFromJson(
      json['freeShippingThreshold'],
      fallback: 4900,
    ),
    shippingCost: centsFromJson(json['shippingCost'], fallback: 490),
    defaultVatRate: centsFromJson(json['defaultVatRate'], fallback: 22),
  );

  /// Order subtotal (cents) at/above which shipping is free.
  final int freeShippingThreshold;

  /// Flat shipping cost (cents) below the free-shipping threshold.
  final int shippingCost;

  /// Default VAT rate (percent) when a product doesn't specify one.
  final int defaultVatRate;

  int shippingFor(int subtotal) =>
      subtotal >= freeShippingThreshold ? 0 : shippingCost;

  Map<String, dynamic> toJson() => {
    'freeShippingThreshold': freeShippingThreshold,
    'shippingCost': shippingCost,
    'defaultVatRate': defaultVatRate,
  };
}
