import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/breakpoints.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../l10n/app_localizations.dart';
import '../../assistant/presentation/assistant_search_bar.dart';
import '../../cart/application/cart_providers.dart';
import '../application/catalog_filter.dart';
import '../application/catalog_providers.dart';
import '../domain/category.dart';
import '../domain/product.dart';
import 'widgets/catalog_filter_panel.dart';
import 'widgets/product_card.dart';
import 'widgets/product_card_skeleton.dart';

/// Step 2.2 — the adaptive "Negozio" storefront: ambient header, category chips
/// and a fluid product grid. Filters live in a right-side glass panel on desktop
/// and a bottom-sheet on mobile (§4.4, §7.2–7.4).
///
/// Search is **not** an inline filter here: the search field/lens opens the
/// assistant page (`/assistant`), which is the single search entry point
/// (§12.6). Until the conversational LLM lands it runs the fuzzy catalog search
/// as a bridge (§13.1).
class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final size = Breakpoints.of(context);

    const grid = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SearchEntry(),
        _CategoryChips(),
        Expanded(child: _CatalogGrid()),
      ],
    );

    return AdaptiveScaffold(
      currentTab: AppTab.shop,
      showAssistantPill: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.catalogTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: l10n.scanTitle,
            onPressed: () => context.push('/scan'),
          ),
          if (!size.usesRail)
            IconButton(
              icon: const Icon(Icons.tune),
              tooltip: l10n.catalogFilters,
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const CatalogFilterSheet(),
              ),
            ),
          TextButton(
            onPressed: () => ref.read(localeProvider.notifier).toggleLocale(),
            child: Text(
              ref.watch(localeProvider).languageCode == 'it' ? 'IT' : 'EN',
            ),
          ),
        ],
      ),
      body: size.usesRail
          ? const Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: grid),
                SizedBox(
                  width: 300,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 96, 16, 16),
                    child: CatalogFilterPanel(),
                  ),
                ),
              ],
            )
          : grid,
    );
  }
}

/// Ambient header wrapping the assistant search entry (§12.6): tapping it opens
/// `/assistant`, not an inline filter.
class _SearchEntry extends StatelessWidget {
  const _SearchEntry();

  @override
  Widget build(BuildContext context) {
    return AmbientBackground(
      hero: true,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          MediaQuery.paddingOf(context).top + kToolbarHeight + 8,
          16,
          16,
        ),
        child: const AssistantSearchBar(),
      ),
    );
  }
}

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final categories = ref.watch(categoriesProvider);
    final selected = ref.watch(
      catalogFilterProvider.select((f) => f.categoryRef),
    );

    final items = categories.valueOrNull ?? const <Category>[];
    if (items.isEmpty) return const SizedBox(height: 8);

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(l10n.catalogAllCategories),
              selected: selected == null,
              onSelected: (_) =>
                  ref.read(catalogFilterProvider.notifier).setCategory(null),
            ),
          ),
          for (final category in items)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(category.name.resolve(locale)),
                selected: selected == category.id,
                onSelected: (_) => ref
                    .read(catalogFilterProvider.notifier)
                    .setCategory(category.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _CatalogGrid extends ConsumerWidget {
  const _CatalogGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(filteredProductsProvider);

    return async.when(
      loading: () => const _SkeletonGrid(),
      error: (_, _) => _EmptyState(
        icon: Icons.cloud_off_outlined,
        title: l10n.catalogLoadError,
      ),
      data: (products) {
        if (products.isEmpty) {
          return _EmptyState(
            icon: Icons.search_off_outlined,
            title: l10n.catalogNoProducts,
            subtitle: l10n.catalogEmptyHint,
          );
        }
        return _ProductGrid(products: products);
      },
    );
  }
}

/// Fluid grid — `maxCrossAxisExtent`, never a fixed column count (§4.4).
const _gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 220,
  mainAxisSpacing: 16,
  crossAxisSpacing: 16,
  childAspectRatio: 0.64,
);

class _ProductGrid extends ConsumerWidget {
  const _ProductGrid({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      gridDelegate: _gridDelegate,
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final card = ProductCard(
          product: product,
          onTap: () => context.push('/product/${product.id}'),
          onAdd: () {
            ref.read(cartControllerProvider).add(product);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(l10n.addedToCart)));
          },
        );
        // Staggered entry only for the first screenful (§7.2.4) — later cards
        // (revealed by scrolling) appear without replaying the animation.
        if (index >= 12 || MediaQuery.of(context).disableAnimations) {
          return card;
        }
        return card
            .animate()
            .fadeIn(duration: 260.ms, delay: (index * 40).ms)
            .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic);
      },
    );
  }
}

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      gridDelegate: _gridDelegate,
      itemCount: 8,
      itemBuilder: (context, _) => const ProductCardSkeleton(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.title, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return AmbientBackground(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: AppColors.brandGreen),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
