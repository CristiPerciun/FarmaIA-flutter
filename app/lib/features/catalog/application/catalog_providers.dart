import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/product_repository.dart';
import '../domain/category.dart';
import '../domain/product.dart';

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepository(ref.watch(firestoreProvider)),
);

/// The full published catalog, newest first. Auto-disposed so the Firestore
/// listener is dropped when no screen is watching it.
final publishedProductsProvider = StreamProvider.autoDispose<List<Product>>(
  (ref) => ref.watch(productRepositoryProvider).watchPublishedProducts(),
);

/// Published products in a single category (used by the category views, 2.2).
final productsByCategoryProvider = StreamProvider.autoDispose
    .family<List<Product>, String>(
      (ref, categoryRef) => ref
          .watch(productRepositoryProvider)
          .watchPublishedProducts(categoryRef: categoryRef),
    );

/// A single product by id (null when it does not exist).
final productProvider = StreamProvider.autoDispose.family<Product?, String>(
  (ref, id) => ref.watch(productRepositoryProvider).watchProduct(id),
);

/// The category tree, ordered by `order`.
final categoriesProvider = StreamProvider.autoDispose<List<Category>>(
  (ref) => ref.watch(productRepositoryProvider).watchCategories(),
);
