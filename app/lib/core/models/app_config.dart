import '../firebase/firestore_converters.dart';

/// Operational parameters (collection `config`, §5.1) — e.g. free-shipping
/// threshold, shipping cost, default VAT rate. Publicly readable, admin-writable
/// (§5.5). All monetary amounts are integer cents.
class AppConfig {
  const AppConfig({
    this.freeShippingThreshold = 4900,
    this.shippingCost = 490,
    this.defaultVatRate = 22,
    this.assistantChatEnabled = false,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) => AppConfig(
    freeShippingThreshold: centsFromJson(
      json['freeShippingThreshold'],
      fallback: 4900,
    ),
    shippingCost: centsFromJson(json['shippingCost'], fallback: 490),
    defaultVatRate: centsFromJson(json['defaultVatRate'], fallback: 22),
    assistantChatEnabled: (json['assistantChatEnabled'] as bool?) ?? false,
  );

  /// Order subtotal (cents) at/above which shipping is free.
  final int freeShippingThreshold;

  /// Flat shipping cost (cents) below the free-shipping threshold.
  final int shippingCost;

  /// Default VAT rate (percent) when a product doesn't specify one.
  final int defaultVatRate;

  /// Feature flag for the conversational assistant (step 4B.6b): ships OFF
  /// and turns on only after the 4B.8 red-team gate. While OFF, `/assistant`
  /// runs in "results-only" mode (fuzzy search) and the backend rejects
  /// non-staff calls. Staff always see the chat, to red-team it.
  final bool assistantChatEnabled;

  int shippingFor(int subtotal) =>
      subtotal >= freeShippingThreshold ? 0 : shippingCost;

  Map<String, dynamic> toJson() => {
    'freeShippingThreshold': freeShippingThreshold,
    'shippingCost': shippingCost,
    'defaultVatRate': defaultVatRate,
    'assistantChatEnabled': assistantChatEnabled,
  };
}
