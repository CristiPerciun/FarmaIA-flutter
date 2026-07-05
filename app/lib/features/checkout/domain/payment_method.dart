import '../../../l10n/app_localizations.dart';

/// Supported payment methods (§3.3, Parte 2 §3). The actual charge runs through
/// the gateway server-side (keys never in the client); in the MVP a sandbox
/// provider simulates the flow — see ADR 0003.
enum PaymentMethod {
  card,
  paypal,
  satispay,
  bnpl;

  String get storageName => name;

  String label(AppLocalizations l10n) => switch (this) {
    PaymentMethod.card => l10n.paymentMethodCard,
    PaymentMethod.paypal => l10n.paymentMethodPaypal,
    PaymentMethod.satispay => l10n.paymentMethodSatispay,
    PaymentMethod.bnpl => l10n.paymentMethodBnpl,
  };
}
