import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/fuzzy.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/domain/product.dart';

/// The assistant's current search text. Kept separate from the catalog filter
/// so the two entry points don't interfere.
final assistantQueryProvider = NotifierProvider<AssistantQueryNotifier, String>(
  AssistantQueryNotifier.new,
);

class AssistantQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String q) => state = q;
  void clear() => state = '';
}

/// Minimum fuzzy relevance to keep a result (matches the catalog, §2.4).
const _threshold = 0.62;

/// "Results-only" search over the published catalog (§12.6 bridge / §13.1).
/// This is the fuzzy fallback the assistant uses until the conversational LLM
/// lands (gate 4B.8) — and, later, when consent is refused / offline / LLM
/// down. Ranked by relevance; empty when the query is blank.
final assistantResultsProvider = Provider.autoDispose<List<Product>>((ref) {
  final query = ref.watch(assistantQueryProvider).trim();
  if (query.isEmpty) return const [];
  final products = ref.watch(publishedProductsProvider).valueOrNull ?? const [];

  final scored = <(Product, double)>[];
  for (final p in products) {
    final score = Fuzzy.bestScore(query, [
      p.name.it,
      p.name.en,
      p.activeIngredient.it,
      p.activeIngredient.en,
      p.sku,
      p.barcode,
    ]);
    if (score >= _threshold) scored.add((p, score));
  }
  scored.sort((a, b) => b.$2.compareTo(a.$2));
  return scored.map((e) => e.$1).toList();
});
