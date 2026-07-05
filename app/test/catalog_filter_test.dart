import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baganza_app/features/catalog/application/catalog_filter.dart';
import 'package:baganza_app/features/catalog/application/catalog_providers.dart';
import 'package:baganza_app/features/catalog/domain/product.dart';

Product _product({
  required String id,
  required String name,
  String type = 'parafarmaco',
  String category = 'cat-a',
  int priceList = 1000,
  int priceSale = 0,
  String ingredient = '',
}) => Product.fromJson({
  'sku': id,
  'barcode': '',
  'categoryRef': category,
  'type': type,
  'name': {'it': name, 'en': name},
  'activeIngredient': {'it': ingredient, 'en': ingredient},
  'priceList': priceList,
  'priceSale': priceSale,
  'status': 'published',
  'available': true,
}, id);

void main() {
  final catalog = [
    _product(id: 'oki', name: 'Oki Task', type: 'otc', category: 'cat-med'),
    _product(
      id: 'crema',
      name: 'Crema mani',
      type: 'cosmetico',
      category: 'cat-cosm',
      priceList: 500,
      priceSale: 400,
    ),
    _product(
      id: 'tachi',
      name: 'Tachipirina',
      type: 'sop',
      category: 'cat-med',
      ingredient: 'Paracetamolo',
    ),
  ];

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        publishedProductsProvider.overrideWith((ref) => Stream.value(catalog)),
      ],
    );
    addTearDown(container.dispose);
    // Keep the autoDispose providers alive for the test.
    container.listen(filteredProductsProvider, (_, _) {});
    return container;
  }

  Future<List<Product>> results(ProviderContainer c) async {
    await c.read(publishedProductsProvider.future);
    return c.read(filteredProductsProvider).value ?? const [];
  }

  test('no filter returns the whole catalog', () async {
    final c = makeContainer();
    expect((await results(c)).map((p) => p.id), ['oki', 'crema', 'tachi']);
  });

  test('category filter narrows to one category', () async {
    final c = makeContainer();
    c.read(catalogFilterProvider.notifier).setCategory('cat-cosm');
    expect((await results(c)).map((p) => p.id), ['crema']);
  });

  test('medicines-only keeps SOP/OTC', () async {
    final c = makeContainer();
    c.read(catalogFilterProvider.notifier).toggleMedicinesOnly();
    expect((await results(c)).map((p) => p.id), ['oki', 'tachi']);
  });

  test('on-sale keeps discounted products', () async {
    final c = makeContainer();
    c.read(catalogFilterProvider.notifier).toggleOnSale();
    expect((await results(c)).map((p) => p.id), ['crema']);
  });

  test('fuzzy query "okitask" finds and ranks "Oki Task" first', () async {
    final c = makeContainer();
    c.read(catalogFilterProvider.notifier).setQuery('okitask');
    final ids = (await results(c)).map((p) => p.id).toList();
    expect(ids.first, 'oki');
    expect(ids, isNot(contains('crema')));
  });

  test('fuzzy query matches on active ingredient', () async {
    final c = makeContainer();
    c.read(catalogFilterProvider.notifier).setQuery('paracetamolo');
    expect((await results(c)).map((p) => p.id), ['tachi']);
  });
}
