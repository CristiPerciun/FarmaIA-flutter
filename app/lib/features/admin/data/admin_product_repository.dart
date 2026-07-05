import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/models/localized_text.dart';
import '../../catalog/domain/product.dart';

/// Admin-side reads/writes for the catalog (§10, §5.5). Unlike the public
/// [ProductRepository], this reads **all** statuses (draft/pendingReview/
/// published/archived) — allowed because the rules grant staff full read.
/// Writes are staff-only (rules); publishing registers the approver (§10).
class AdminProductRepository {
  AdminProductRepository(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection('products');

  /// All products, newest first (every status).
  Stream<List<Product>> watchAll() => _products
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Product.fromJson(d.data(), d.id)).toList());

  Stream<Product?> watch(String id) => _products.doc(id).snapshots().map((s) {
    final data = s.data();
    return data == null ? null : Product.fromJson(data, s.id);
  });

  /// Creates a minimal `draft` from the admin form (§4.1). Returns the new id.
  Future<String> createDraft({
    required LocalizedText name,
    required ProductType type,
    required String categoryRef,
    required int priceList,
    required int priceSale,
    required int vatRate,
  }) async {
    final ref = _products.doc();
    final empty = const LocalizedText(it: '', en: '').toJson();
    await ref.set({
      'sku': '',
      'barcode': '',
      'categoryRef': categoryRef,
      'type': type.storageName,
      'isMedicine': type.isMedicine,
      'name': name.toJson(),
      'shortDescription': empty,
      'description': empty,
      'activeIngredient': empty,
      'posology': empty,
      'contraindications': empty,
      'warnings': empty,
      'ceMarking': false,
      'priceList': priceList,
      'priceSale': priceSale,
      'currency': 'EUR',
      'vatRate': vatRate,
      'stockQty': 0,
      'available': false,
      'images': <Map<String, dynamic>>[],
      'seo': {'slug': empty, 'title': empty, 'metaDescription': empty},
      'status': ProductStatus.draft.storageName,
      'aiGenerated': false,
      'assistantEligible': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  /// Targeted update; always refreshes `updatedAt`.
  Future<void> update(String id, Map<String, dynamic> data) => _products
      .doc(id)
      .update({...data, 'updatedAt': FieldValue.serverTimestamp()});

  /// Uploads a raw product image and records its Storage path so the Vision
  /// pipeline (§4.2) can pick it up. Uses bytes (web-safe). Returns the URL.
  Future<String> uploadRawImage({
    required String productId,
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) async {
    final path = 'products/$productId/raw_$fileName';
    final ref = _storage.ref(path);
    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    final url = await ref.getDownloadURL();
    // Seed images with the raw URL; the Vision function replaces it with the
    // optimized WebP and flips `aiImage.status` (§4.2).
    await update(productId, {
      'rawImagePath': path,
      'images': [
        {'url': url, 'alt': const LocalizedText(it: '', en: '').toJson()},
      ],
      'aiImage': {'status': 'pending'},
    });
    return url;
  }

  /// Publishes a product (§4.4). Registers who approved and when; sets it
  /// available. No automatic publishing happens anywhere else.
  Future<void> publish(String id, String approverUid) => update(id, {
    'status': ProductStatus.published.storageName,
    'available': true,
    'reviewedBy': approverUid,
    'reviewedAt': FieldValue.serverTimestamp(),
    'publishedAt': FieldValue.serverTimestamp(),
  });

  Future<void> unpublish(String id) =>
      update(id, {'status': ProductStatus.draft.storageName});

  Future<void> archive(String id) => update(id, {
    'status': ProductStatus.archived.storageName,
    'available': false,
  });

  Future<void> setAvailable(String id, {required bool available}) =>
      update(id, {'available': available});

  Future<void> setStock(String id, int stockQty) =>
      update(id, {'stockQty': stockQty});
}
