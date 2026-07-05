import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../l10n/app_localizations.dart';
import '../../compliance/presentation/withdrawal_button.dart';
import '../application/order_providers.dart';
import '../domain/order.dart';
import 'order_labels.dart';

/// Step 3.5 — order detail: items, totals, payment/shipping status, tracking,
/// and the tracked right-of-withdrawal request (art. 54-bis, §16.8).
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(orderProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/orders'),
        ),
        title: Text(l10n.ordersTitle),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _NotFound(text: l10n.genericErrorRetry),
        data: (order) => order == null
            ? _NotFound(text: l10n.productNotFound)
            : _OrderBody(order: order),
      ),
    );
  }
}

class _OrderBody extends ConsumerWidget {
  const _OrderBody({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final code = ref.watch(localeProvider).languageCode;
    String money(int c) => c.formatMoney(localeCode: code);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.orderNumberLabel(order.orderNumber),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            _StatusRow(
              label: l10n.orderPaymentLabel,
              value: order.paymentStatus.label(l10n),
            ),
            _StatusRow(
              label: l10n.orderShippingLabel,
              value: order.shippingStatus.label(l10n),
            ),
            _StatusRow(
              label: l10n.orderStatusCreated,
              value: order.status.label(l10n),
            ),
            if (order.carrier != null)
              _StatusRow(label: l10n.orderCarrierLabel, value: order.carrier!),
            if (order.trackingNumber != null)
              _StatusRow(
                label: l10n.orderTrackingLabel,
                value: order.trackingNumber!,
              ),
            const Divider(height: 32),
            Text(
              l10n.orderItemsLabel,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (final item in order.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(child: Text('${item.qty}× ${item.nameSnapshot}')),
                    Text(money(item.lineTotal)),
                  ],
                ),
              ),
            const Divider(height: 32),
            _StatusRow(
              label: l10n.summarySubtotal,
              value: money(order.totals.subtotal),
            ),
            _StatusRow(
              label: l10n.summaryShipping,
              value: order.totals.shipping == 0
                  ? l10n.summaryShippingFree
                  : money(order.totals.shipping),
            ),
            _StatusRow(
              label: l10n.summaryTotal,
              value: money(order.totals.total),
              emphasize: true,
            ),
            const SizedBox(height: 24),
            // Withdrawal is available once paid and not already requested.
            if (order.isPaid)
              WithdrawalButton(
                alreadyRequested: order.recessoRequested,
                onConfirmed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final l = l10n;
                  try {
                    await ref.read(withdrawalServiceProvider).request(order.id);
                    messenger.showSnackBar(
                      SnackBar(content: Text(l.withdrawalRequested)),
                    );
                  } catch (_) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(l.genericErrorRetry)),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.brandGreenDark,
            fontWeight: FontWeight.bold,
          )
        : Theme.of(context).textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return AmbientBackground(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
    );
  }
}
