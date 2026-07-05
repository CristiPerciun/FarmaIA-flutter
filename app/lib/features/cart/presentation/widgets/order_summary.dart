import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../checkout/domain/order_pricing.dart';

/// Price breakdown shown on the cart and checkout (§5.3): subtotal, shipping,
/// per-rate VAT (informational, prices are VAT-inclusive) and total. Rendered on
/// a solid surface — prices are critical content (§7.2.3).
class OrderSummary extends StatelessWidget {
  const OrderSummary({super.key, required this.pricing, this.currency = 'EUR'});

  final OrderPricing pricing;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final code = Localizations.localeOf(context).languageCode;
    final t = pricing.totals;
    String money(int cents) =>
        cents.formatMoney(localeCode: code, currency: currency);

    final rates = pricing.vatByRate.keys.toList()..sort((a, b) => b - a);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _row(context, l10n.summarySubtotal, money(t.subtotal)),
          const SizedBox(height: 8),
          _row(
            context,
            l10n.summaryShipping,
            t.shipping == 0 ? l10n.summaryShippingFree : money(t.shipping),
          ),
          for (final rate in rates) ...[
            const SizedBox(height: 6),
            _row(
              context,
              l10n.summaryVatRate(rate),
              money(pricing.vatByRate[rate]!),
              muted: true,
            ),
          ],
          const Divider(height: 24),
          _row(context, l10n.summaryTotal, money(t.total), emphasize: true),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    bool emphasize = false,
    bool muted = false,
  }) {
    final style = emphasize
        ? Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.brandGreenDark,
            fontWeight: FontWeight.bold,
          )
        : Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: muted ? AppColors.textSecondary : AppColors.textPrimary,
          );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
