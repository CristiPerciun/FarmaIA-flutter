import '../../../core/models/app_config.dart';
import '../../orders/domain/order.dart';

/// One priced line for the pricing calculator: [unitPrice] is the VAT-inclusive
/// retail price in cents (Italian B2C prices are shown gross), [vatRate] the
/// applicable VAT percentage for that product's category (§5.3).
class PricingLine {
  const PricingLine({
    required this.qty,
    required this.unitPrice,
    required this.vatRate,
  });

  final int qty;
  final int unitPrice;
  final int vatRate;

  int get lineTotal => qty * unitPrice;

  /// VAT portion embedded in the gross line total: `gross * rate / (100 + rate)`.
  int get vatAmount =>
      vatRate <= 0 ? 0 : (lineTotal * vatRate / (100 + vatRate)).round();
}

/// Result of pricing a cart: the [OrderTotals] plus a VAT breakdown grouped by
/// rate (the "IVA per categoria" summary, §5.3 / Parte 2 §2).
class OrderPricing {
  const OrderPricing({required this.totals, required this.vatByRate});

  final OrderTotals totals;

  /// Embedded VAT (cents) grouped by rate (%). E.g. `{22: 180, 10: 45}`.
  final Map<int, int> vatByRate;

  /// Prices [lines] against [config]. Subtotal is the gross sum; VAT is the
  /// embedded portion (informational); shipping comes from config; total is
  /// subtotal + shipping (VAT already included in the gross subtotal).
  factory OrderPricing.compute(List<PricingLine> lines, AppConfig config) {
    var subtotal = 0;
    var vat = 0;
    final vatByRate = <int, int>{};
    for (final line in lines) {
      subtotal += line.lineTotal;
      final lineVat = line.vatAmount;
      vat += lineVat;
      if (line.vatRate > 0) {
        vatByRate.update(
          line.vatRate,
          (v) => v + lineVat,
          ifAbsent: () => lineVat,
        );
      }
    }
    final shipping = config.shippingFor(subtotal);
    return OrderPricing(
      totals: OrderTotals(
        subtotal: subtotal,
        shipping: shipping,
        vat: vat,
        total: subtotal + shipping,
      ),
      vatByRate: vatByRate,
    );
  }
}
