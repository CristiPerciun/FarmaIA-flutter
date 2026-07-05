import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/connectivity_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../l10n/app_localizations.dart';
import '../application/cart_providers.dart';
import 'widgets/order_summary.dart';

/// Step 3.1 — the cart: line items with quantity steppers, live totals and a
/// checkout CTA. Transactional actions are disabled offline (§9.1).
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lines = ref.watch(cartLinesProvider);

    return AdaptiveScaffold(
      currentTab: AppTab.cart,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.cartTitle),
      ),
      body: lines.isEmpty ? _EmptyCart(l10n: l10n) : _CartBody(),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.l10n});

  final AppLocalizations l10n;

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
              const Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: AppColors.brandGreen,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.cartEmpty,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.cartEmptyHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandGreen,
                ),
                icon: const Icon(Icons.storefront_outlined),
                label: Text(l10n.navShop),
                onPressed: () => context.go('/catalog'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartBody extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lines = ref.watch(cartLinesProvider);
    final pricing = ref.watch(cartPricingProvider);
    final online = ref.watch(isOnlineProvider).valueOrNull ?? true;
    final locale = ref.watch(localeProvider);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              for (final line in lines)
                _CartLineTile(
                  line: line,
                  locale: locale,
                  onDec: online
                      ? () => ref
                            .read(cartControllerProvider)
                            .setQty(line.item.productRef, line.item.qty - 1)
                      : null,
                  onInc: online
                      ? () => ref
                            .read(cartControllerProvider)
                            .setQty(line.item.productRef, line.item.qty + 1)
                      : null,
                  onRemove: online
                      ? () => ref
                            .read(cartControllerProvider)
                            .remove(line.item.productRef)
                      : null,
                ),
              const SizedBox(height: 16),
              OrderSummary(pricing: pricing),
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandGreen,
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: online ? () => context.push('/checkout') : null,
                child: Text(
                  online ? l10n.cartCheckout : l10n.offlineActionDisabled,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({
    required this.line,
    required this.locale,
    required this.onDec,
    required this.onInc,
    required this.onRemove,
  });

  final CartLine line;
  final Locale locale;
  final VoidCallback? onDec;
  final VoidCallback? onInc;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final product = line.product;
    final name = product?.name.resolve(locale) ?? line.item.productRef;
    final imageUrl = (product != null && product.images.isNotEmpty)
        ? product.images.first.url
        : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: imageUrl.isEmpty
                  ? const Icon(
                      Icons.medication_outlined,
                      color: AppColors.border,
                    )
                  : CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.contain),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (product == null)
                    Text(
                      l10n.cartItemUnavailable,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.alert),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    line.item.lineTotal.formatMoney(
                      localeCode: locale.languageCode,
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.brandGreenDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                _QtyStepper(qty: line.item.qty, onDec: onDec, onInc: onInc),
                TextButton(onPressed: onRemove, child: Text(l10n.cartRemove)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.qty,
    required this.onDec,
    required this.onInc,
  });

  final int qty;
  final VoidCallback? onDec;
  final VoidCallback? onInc;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: onDec,
        ),
        Text('$qty', style: Theme.of(context).textTheme.titleMedium),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.add_circle_outline),
          color: AppColors.brandGreen,
          onPressed: onInc,
        ),
      ],
    );
  }
}
