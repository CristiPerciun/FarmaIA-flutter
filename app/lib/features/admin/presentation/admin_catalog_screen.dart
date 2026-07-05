import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money.dart';
import '../../../l10n/app_localizations.dart';
import '../../catalog/domain/product.dart';
import '../application/admin_product_providers.dart';
import 'admin_labels.dart';

/// Step 4.5 — admin catalog management: every product grouped by status, with
/// quick access to edit / stock / publish / archive on the detail form.
class AdminCatalogScreen extends ConsumerWidget {
  const AdminCatalogScreen({super.key});

  // Display order for the status sections.
  static const _order = [
    ProductStatus.pendingReview,
    ProductStatus.draft,
    ProductStatus.published,
    ProductStatus.archived,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final grouped = ref.watch(adminProductsByStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminCatalogTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.brandGreen,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/admin/products/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.adminAddProduct),
      ),
      body: grouped.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.genericErrorRetry)),
        data: (map) {
          if (map.values.every((l) => l.isEmpty)) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.adminNoProducts,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                children: [
                  for (final status in _order)
                    if ((map[status] ?? const []).isNotEmpty)
                      _StatusSection(status: status, products: map[status]!),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatusSection extends StatelessWidget {
  const _StatusSection({required this.status, required this.products});

  final ProductStatus status;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Text(
            '${status.label(l10n)} · ${products.length}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.brandGreenDark,
            ),
          ),
        ),
        for (final p in products) _ProductRow(product: p),
      ],
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          product.name.it.isEmpty ? product.id : product.name.it,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text(product.effectivePrice.formatMoney()),
            const SizedBox(width: 12),
            if (product.aiGenerated)
              const Icon(
                Icons.auto_awesome,
                size: 14,
                color: AppColors.brandGold,
              ),
            if (!product.available)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.visibility_off_outlined,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/admin/products/${product.id}'),
      ),
    );
  }
}
