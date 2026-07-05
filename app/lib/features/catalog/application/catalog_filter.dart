import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/fuzzy.dart';
import '../domain/product.dart';
import 'catalog_providers.dart';

/// Active catalog filters + search query (§2.2, §2.4). Filtering is done
/// client-side over the already-streamed published catalog, so it keeps working
/// offline (§9.1) and powers fuzzy search without a round-trip.
class CatalogFilter {
  const CatalogFilter({
    this.categoryRef,
    this.medicinesOnly = false,
    this.onSale = false,
    this.query = '',
  });

  final String? categoryRef;
  final bool medicinesOnly;
  final bool onSale;
  final String query;

  bool get isActive =>
      categoryRef != null || medicinesOnly || onSale || query.trim().isNotEmpty;

  CatalogFilter copyWith({
    Object? categoryRef = _sentinel,
    bool? medicinesOnly,
    bool? onSale,
    String? query,
  }) => CatalogFilter(
    categoryRef: categoryRef == _sentinel
        ? this.categoryRef
        : categoryRef as String?,
    medicinesOnly: medicinesOnly ?? this.medicinesOnly,
    onSale: onSale ?? this.onSale,
    query: query ?? this.query,
  );

  static const _sentinel = Object();
}

class CatalogFilterNotifier extends Notifier<CatalogFilter> {
  @override
  CatalogFilter build() => const CatalogFilter();

  void setCategory(String? categoryRef) =>
      state = state.copyWith(categoryRef: categoryRef);
  void toggleMedicinesOnly() =>
      state = state.copyWith(medicinesOnly: !state.medicinesOnly);
  void toggleOnSale() => state = state.copyWith(onSale: !state.onSale);
  void setQuery(String query) => state = state.copyWith(query: query);
  void clear() => state = const CatalogFilter();
}

final catalogFilterProvider =
    NotifierProvider<CatalogFilterNotifier, CatalogFilter>(
      CatalogFilterNotifier.new,
    );

/// Minimum fuzzy relevance to keep a product in the results (§2.4).
const _searchThreshold = 0.62;

/// The published catalog after applying the active filter and fuzzy search.
/// When a query is present, results are ranked by relevance; otherwise the
/// repository's newest-first order is preserved.
final filteredProductsProvider =
    Provider.autoDispose<AsyncValue<List<Product>>>((ref) {
      final async = ref.watch(publishedProductsProvider);
      final filter = ref.watch(catalogFilterProvider);

      return async.whenData((products) {
        var result = products.where((p) {
          if (filter.categoryRef != null &&
              p.categoryRef != filter.categoryRef) {
            return false;
          }
          if (filter.medicinesOnly && !p.isMedicine) return false;
          if (filter.onSale && !p.isOnSale) return false;
          return true;
        }).toList();

        final query = filter.query.trim();
        if (query.isNotEmpty) {
          final scored = <(Product, double)>[];
          for (final p in result) {
            final score = Fuzzy.bestScore(query, [
              p.name.it,
              p.name.en,
              p.activeIngredient.it,
              p.activeIngredient.en,
              p.sku,
              p.barcode,
            ]);
            if (score >= _searchThreshold) scored.add((p, score));
          }
          scored.sort((a, b) => b.$2.compareTo(a.$2));
          result = scored.map((e) => e.$1).toList();
        }

        return result;
      });
    });
