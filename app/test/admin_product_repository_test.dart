import 'dart:typed_data';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baganza_app/core/models/localized_text.dart';
import 'package:baganza_app/features/admin/data/admin_product_repository.dart';
import 'package:baganza_app/features/catalog/domain/product.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late AdminProductRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repo = AdminProductRepository(firestore, MockFirebaseStorage());
  });

  Future<String> seedDraft({String name = 'Oki', String type = 'otc'}) =>
      repo.createDraft(
        name: LocalizedText(it: name, en: name),
        type: ProductType.fromStorage(type),
        categoryRef: 'cat-med',
        priceList: 800,
        priceSale: 0,
        vatRate: 10,
      );

  test('createDraft writes a hidden draft with the given basics', () async {
    final id = await seedDraft();
    final product = await repo.watch(id).first;

    expect(product, isNotNull);
    expect(product!.status, ProductStatus.draft);
    expect(product.available, isFalse);
    expect(product.name.it, 'Oki');
    expect(product.priceList, 800);
    expect(product.vatRate, 10);
    expect(product.type, ProductType.otc);
  });

  test('watchAll returns every status, newest first', () async {
    await seedDraft(name: 'A');
    final id2 = await seedDraft(name: 'B');
    await repo.publish(id2, 'staff-1');

    final all = await repo.watchAll().first;
    expect(all.length, 2);
    // Both statuses present (draft + published).
    expect(all.map((p) => p.status).toSet(), {
      ProductStatus.draft,
      ProductStatus.published,
    });
  });

  test('publish sets published + available and records the approver', () async {
    final id = await seedDraft();
    await repo.publish(id, 'pharmacist-42');

    final product = await repo.watch(id).first;
    expect(product!.status, ProductStatus.published);
    expect(product.available, isTrue);
    expect(product.reviewedBy, 'pharmacist-42');
    expect(product.publishedAt, isNotNull);
  });

  test('archive hides the product', () async {
    final id = await seedDraft();
    await repo.publish(id, 'staff');
    await repo.archive(id);

    final product = await repo.watch(id).first;
    expect(product!.status, ProductStatus.archived);
    expect(product.available, isFalse);
  });

  test(
    'uploadRawImage seeds the image and marks the Vision step pending',
    () async {
      final id = await seedDraft();
      await repo.uploadRawImage(
        productId: id,
        bytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'photo.jpg',
        contentType: 'image/jpeg',
      );

      final product = await repo.watch(id).first;
      expect(product!.images, isNotEmpty);
      expect(product.aiImageStatus, 'pending');
    },
  );
}
