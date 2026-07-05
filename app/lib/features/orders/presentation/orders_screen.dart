import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/application/auth_providers.dart';
import '../application/order_providers.dart';
import '../domain/order.dart';
import 'order_labels.dart';

/// Step 3.5 — the customer's order history. Tap an order for its detail.
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final signedIn = ref.watch(currentUserProvider) != null;
    final orders = ref.watch(userOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ordersTitle)),
      body: !signedIn
          ? _Message(icon: Icons.lock_outline, text: l10n.signInToOrder)
          : orders.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => _Message(
                icon: Icons.error_outline,
                text: l10n.genericErrorRetry,
              ),
              data: (list) => list.isEmpty
                  ? _Message(
                      icon: Icons.receipt_long_outlined,
                      text: l10n.ordersEmpty,
                    )
                  : _OrdersList(orders: list),
            ),
    );
  }
}

class _OrdersList extends ConsumerWidget {
  const _OrdersList({required this.orders});

  final List<Order> orders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final dateFmt = DateFormat.yMMMd(locale.languageCode);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, i) {
            final order = orders[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Text(
                  l10n.orderNumberLabel(order.orderNumber),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (order.createdAt != null)
                      Text(dateFmt.format(order.createdAt!)),
                    const SizedBox(height: 4),
                    _StatusChip(order: order),
                  ],
                ),
                trailing: Text(
                  order.totals.total.formatMoney(
                    localeCode: locale.languageCode,
                  ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.brandGreenDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () => context.push('/orders/${order.id}'),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final paid = order.isPaid;
    return Wrap(
      spacing: 8,
      children: [
        Chip(
          visualDensity: VisualDensity.compact,
          backgroundColor: paid
              ? AppColors.brandGreen.withValues(alpha: 0.12)
              : AppColors.surface,
          label: Text(order.paymentStatus.label(l10n)),
        ),
        Chip(
          visualDensity: VisualDensity.compact,
          backgroundColor: AppColors.surface,
          label: Text(order.status.label(l10n)),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return AmbientBackground(
      hero: true,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: AppColors.brandGreen),
              const SizedBox(height: 16),
              Text(
                text,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
