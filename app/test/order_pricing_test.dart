import 'package:flutter_test/flutter_test.dart';

import 'package:baganza_app/core/models/app_config.dart';
import 'package:baganza_app/features/checkout/domain/order_pricing.dart';

void main() {
  const config = AppConfig(); // threshold 4900, shipping 490, default VAT 22

  group('OrderPricing.compute', () {
    test('adds shipping below the free-shipping threshold', () {
      final p = OrderPricing.compute([
        const PricingLine(qty: 1, unitPrice: 1000, vatRate: 22),
      ], config);
      expect(p.totals.subtotal, 1000);
      expect(p.totals.shipping, 490);
      expect(p.totals.total, 1490);
    });

    test('free shipping at/above the threshold', () {
      final p = OrderPricing.compute([
        const PricingLine(qty: 1, unitPrice: 5000, vatRate: 10),
      ], config);
      expect(p.totals.shipping, 0);
      expect(p.totals.total, 5000);
    });

    test('VAT is the embedded portion of the gross price (22%)', () {
      final p = OrderPricing.compute([
        const PricingLine(qty: 1, unitPrice: 1000, vatRate: 22),
      ], config);
      // round(1000 * 22 / 122) = 180
      expect(p.totals.vat, 180);
      expect(p.vatByRate, {22: 180});
    });

    test('groups VAT by rate across lines (IVA per categoria)', () {
      final p = OrderPricing.compute([
        const PricingLine(qty: 1, unitPrice: 1000, vatRate: 22),
        const PricingLine(qty: 1, unitPrice: 2000, vatRate: 10),
      ], config);
      expect(p.totals.subtotal, 3000);
      expect(p.vatByRate[22], 180);
      expect(p.vatByRate[10], 182); // round(2000 * 10 / 110)
      expect(p.totals.vat, 362);
    });

    test('quantity multiplies the line total', () {
      final p = OrderPricing.compute([
        const PricingLine(qty: 3, unitPrice: 1000, vatRate: 22),
      ], config);
      expect(p.totals.subtotal, 3000);
    });

    test('zero VAT rate contributes no VAT and no rate bucket', () {
      final p = OrderPricing.compute([
        const PricingLine(qty: 1, unitPrice: 1000, vatRate: 0),
      ], config);
      expect(p.totals.vat, 0);
      expect(p.vatByRate.isEmpty, isTrue);
    });

    test('empty cart prices to zero + shipping', () {
      final p = OrderPricing.compute([], config);
      expect(p.totals.subtotal, 0);
      expect(p.totals.vat, 0);
      // shippingFor(0) = 490 (below threshold); total = 490.
      expect(p.totals.total, 490);
    });
  });
}
