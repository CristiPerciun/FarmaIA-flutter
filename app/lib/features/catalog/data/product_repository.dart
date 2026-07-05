import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/category.dart';
import '../domain/product.dart';

/// Reads the public catalog from Firestore (§5.1, §5.5).
///
/// Every product query is scoped to `status == published`: the security rules
/// reject public reads of drafts, so the client must never ask for them (§5.5).
/// Category filtering and type filtering rely on the composite indexes declared
/// in `firebase/firestore.indexes.json` (status + categoryRef/type + createdAt).
class ProductRepository {
  ProductRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection('products');

  CollectionReference<Map<String, dynamic>> get _categories =>
      _firestore.collection('categories');

  /// Published products, newest first. Optionally narrowed to a single
  /// [categoryRef] or product [type].
  Query<Map<String, dynamic>> _publishedQuery({
    String? categoryRef,
    ProductType? type,
  }) {
    var query = _products.where(
      'status',
      isEqualTo: ProductStatus.published.storageName,
    );
    if (categoryRef != null) {
      query = query.where('categoryRef', isEqualTo: categoryRef);
    }
    if (type != null) {
      query = query.where('type', isEqualTo: type.storageName);
    }
    return query.orderBy('createdAt', descending: true);
  }

  List<Product> _toProducts(QuerySnapshot<Map<String, dynamic>> snap) =>
      snap.docs.map((doc) => Product.fromJson(doc.data(), doc.id)).toList();

  /// Streams the published catalog, optionally filtered by category or type.
  Stream<List<Product>> watchPublishedProducts({
    String? categoryRef,
    ProductType? type,
  }) => _publishedQuery(
    categoryRef: categoryRef,
    type: type,
  ).snapshots().map(_toProducts);

  /// One-shot read of the published catalog.
  Future<List<Product>> fetchPublishedProducts({
    String? categoryRef,
    ProductType? type,
  }) async => _toProducts(
    await _publishedQuery(categoryRef: categoryRef, type: type).get(),
  );

  /// Streams a single product by id (null when it does not exist).
  Stream<Product?> watchProduct(String id) =>
      _products.doc(id).snapshots().map((snap) {
        final data = snap.data();
        return data == null ? null : Product.fromJson(data, snap.id);
      });

  /// One-shot read of a single product by id (null when it does not exist).
  Future<Product?> fetchProduct(String id) async {
    final snap = await _products.doc(id).get();
    final data = snap.data();
    return data == null ? null : Product.fromJson(data, snap.id);
  }

  /// Looks up a single published product by its EAN/barcode (§2.5). Returns
  /// null when no published product carries that code. Two equality filters
  /// are served without a composite index.
  Future<Product?> fetchPublishedProductByBarcode(String barcode) async {
    final snap = await _products
        .where('status', isEqualTo: ProductStatus.published.storageName)
        .where('barcode', isEqualTo: barcode)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return Product.fromJson(doc.data(), doc.id);
  }

  /// Streams the category tree, ordered by the `order` field (§5.1).
  Stream<List<Category>> watchCategories() => _categories
      .orderBy('order')
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((doc) => Category.fromJson(doc.data(), doc.id))
            .toList(),
      );
}
