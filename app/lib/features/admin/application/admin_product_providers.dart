import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../catalog/domain/product.dart';
import '../data/admin_product_repository.dart';

final adminProductRepositoryProvider = Provider<AdminProductRepository>(
  (ref) => AdminProductRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseStorageProvider),
  ),
);

/// All products (every status), newest first — the admin catalog list (§4.5).
final adminProductsProvider = StreamProvider.autoDispose<List<Product>>(
  (ref) => ref.watch(adminProductRepositoryProvider).watchAll(),
);

/// A single product by id, any status (for the admin edit/preview screen).
final adminProductProvider = StreamProvider.autoDispose
    .family<Product?, String>(
      (ref, id) => ref.watch(adminProductRepositoryProvider).watch(id),
    );

/// Groups products by status for the admin list, preserving newest-first order.
final adminProductsByStatusProvider =
    Provider.autoDispose<AsyncValue<Map<ProductStatus, List<Product>>>>((ref) {
      return ref.watch(adminProductsProvider).whenData((products) {
        final map = <ProductStatus, List<Product>>{};
        for (final p in products) {
          map.putIfAbsent(p.status, () => []).add(p);
        }
        return map;
      });
    });
