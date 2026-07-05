import '../../../l10n/app_localizations.dart';
import '../domain/order.dart';

/// Localized labels for the order lifecycle enums (§5.3).
extension OrderStatusL10n on OrderStatus {
  String label(AppLocalizations l10n) => switch (this) {
    OrderStatus.created => l10n.orderStatusCreated,
    OrderStatus.confirmed => l10n.orderStatusConfirmed,
    OrderStatus.preparing => l10n.orderStatusPreparing,
    OrderStatus.shipped => l10n.orderStatusShipped,
    OrderStatus.delivered => l10n.orderStatusDelivered,
    OrderStatus.cancelled => l10n.orderStatusCancelled,
  };
}

extension PaymentStatusL10n on PaymentStatus {
  String label(AppLocalizations l10n) => switch (this) {
    PaymentStatus.pending => l10n.paymentStatusPending,
    PaymentStatus.paid => l10n.paymentStatusPaid,
    PaymentStatus.failed => l10n.paymentStatusFailed,
    PaymentStatus.refunded => l10n.paymentStatusRefunded,
  };
}

extension ShippingStatusL10n on ShippingStatus {
  String label(AppLocalizations l10n) => switch (this) {
    ShippingStatus.processing => l10n.shippingStatusProcessing,
    ShippingStatus.shipped => l10n.shippingStatusShipped,
    ShippingStatus.delivered => l10n.shippingStatusDelivered,
    ShippingStatus.returned => l10n.shippingStatusReturned,
  };
}
