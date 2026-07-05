import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baganza_app/features/catalog/data/product_repository.dart';
import 'package:baganza_app/features/catalog/domain/product.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ProductRepository repo;

  /// Minimal product document as written by the seed / admin pipeline.
  Map<String, dynamic> productDoc({
    required String name,
    required String status,
    String categoryRef = 'cat-otc',
    String type = 'otc',
    required DateTime createdAt,
  }) => {
    'sku': name,
    'barcode': '',
    'categoryRef': categoryRef,
    'type': type,
    'name': {'it': name, 'en': name},
    'status': status,
    'available': true,
    'priceList': 999,
    'priceSale': 0,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    repo = ProductRepository(firestore);

    await firestore
        .collection('products')
        .doc('p-old')
        .set(
          productDoc(
            name: 'Oki',
            status: 'published',
            createdAt: DateTime(2026, 1, 1),
          ),
        );
    await firestore
        .collection('products')
        .doc('p-new')
        .set(
          productDoc(
            name: 'Tachipirina',
            status: 'published',
            categoryRef: 'cat-sop',
            type: 'sop',
            createdAt: DateTime(2026, 6, 1),
          ),
        );
    await firestore
        .collection('products')
        .doc('p-draft')
        .set(
          productDoc(
            name: 'Bozza',
            status: 'draft',
            createdAt: DateTime(2026, 5, 1),
          ),
        );
  });

  group('ProductRepository.watchPublishedProducts', () {
    test('returns only published products, newest first', () async {
      final products = await repo.watchPublishedProducts().first;

      expect(
        products.map((p) => p.id),
        ['p-new', 'p-old'],
        reason: 'draft excluded, ordered by createdAt desc',
      );
      expect(products.every((p) => p.isPublished), isTrue);
    });

    test('filters by category', () async {
      final products = await repo
          .watchPublishedProducts(categoryRef: 'cat-sop')
          .first;

      expect(products.map((p) => p.id), ['p-new']);
    });

    test('filters by product type', () async {
      final products = await repo
          .watchPublishedProducts(type: ProductType.otc)
          .first;

      expect(products.map((p) => p.id), ['p-old']);
    });
  });

  group('ProductRepository single reads', () {
    test('fetchProduct returns the product', () async {
      final product = await repo.fetchProduct('p-new');
      expect(product?.name.it, 'Tachipirina');
    });

    test('fetchProduct returns null for a missing id', () async {
      expect(await repo.fetchProduct('nope'), isNull);
    });

    test('watchProduct streams the product', () async {
      final product = await repo.watchProduct('p-old').first;
      expect(product?.name.it, 'Oki');
    });
  });

  group('ProductRepository.fetchPublishedProductByBarcode', () {
    test('finds a published product by its EAN', () async {
      await firestore
          .collection('products')
          .doc('p-ean')
          .set(
            productDoc(
              name: 'Oki Task',
              status: 'published',
              createdAt: DateTime(2026, 3, 1),
            )..['barcode'] = '8000000012345',
          );

      final product = await repo.fetchPublishedProductByBarcode(
        '8000000012345',
      );
      expect(product?.id, 'p-ean');
      expect(product?.name.it, 'Oki Task');
    });

    test('returns null for an unknown code', () async {
      expect(await repo.fetchPublishedProductByBarcode('0000'), isNull);
    });

    test('does not return a draft even if the barcode matches', () async {
      await firestore
          .collection('products')
          .doc('p-draft-ean')
          .set(
            productDoc(
              name: 'Bozza EAN',
              status: 'draft',
              createdAt: DateTime(2026, 3, 1),
            )..['barcode'] = '8000000099999',
          );

      expect(
        await repo.fetchPublishedProductByBarcode('8000000099999'),
        isNull,
      );
    });
  });

  group('ProductRepository.watchCategories', () {
    test('returns categories ordered by `order`', () async {
      await firestore.collection('categories').doc('c2').set({
        'name': {'it': 'Seconda', 'en': 'Second'},
        'order': 2,
      });
      await firestore.collection('categories').doc('c1').set({
        'name': {'it': 'Prima', 'en': 'First'},
        'order': 1,
      });

      final categories = await repo.watchCategories().first;
      expect(categories.map((c) => c.id), ['c1', 'c2']);
    });
  });
}
