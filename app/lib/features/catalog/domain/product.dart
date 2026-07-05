import '../../../core/firebase/firestore_converters.dart';
import '../../../core/models/localized_text.dart';

/// Product classification (§5.1). `isMedicine` (derived) governs the
/// medicine/non-medicine page separation and the ministerial logo (§9.2, §16.8).
enum ProductType {
  sop,
  otc,
  parafarmaco,
  integratore,
  cosmetico,
  dispositivoMedico;

  /// The value as stored in Firestore (matches the doc's snake_case for the
  /// two-word type; single words map to themselves).
  String get storageName => switch (this) {
    ProductType.dispositivoMedico => 'dispositivo_medico',
    _ => name,
  };

  static ProductType fromStorage(Object? value) {
    if (value == 'dispositivo_medico') return ProductType.dispositivoMedico;
    return enumFromName(value, ProductType.values, ProductType.parafarmaco);
  }

  /// SOP and OTC are medicines → separated pages + ministerial logo.
  bool get isMedicine => this == ProductType.sop || this == ProductType.otc;
}

/// Publication lifecycle. Public reads are allowed only for [published] (§5.5);
/// the AI pipeline creates drafts that stay invisible until the pharmacist
/// clicks "Pubblica" (§10).
enum ProductStatus {
  draft,
  pendingReview,
  published,
  archived;

  static ProductStatus fromStorage(Object? value) {
    if (value == 'pending_review') return ProductStatus.pendingReview;
    return enumFromName(value, ProductStatus.values, ProductStatus.draft);
  }

  String get storageName => switch (this) {
    ProductStatus.pendingReview => 'pending_review',
    _ => name,
  };
}

/// A single product image with bilingual alt text.
class ProductImage {
  const ProductImage({required this.url, required this.alt});

  factory ProductImage.fromJson(Map<String, dynamic> json) => ProductImage(
    url: (json['url'] as String?) ?? '',
    alt: LocalizedText.fromJson(json['alt']),
  );

  final String url;
  final LocalizedText alt;

  Map<String, dynamic> toJson() => {'url': url, 'alt': alt.toJson()};
}

/// SEO metadata, bilingual (§6.2).
class ProductSeo {
  const ProductSeo({
    required this.slug,
    required this.title,
    required this.metaDescription,
  });

  factory ProductSeo.fromJson(Object? json) {
    final map = json is Map ? json : const {};
    return ProductSeo(
      slug: LocalizedText.fromJson(map['slug']),
      title: LocalizedText.fromJson(map['title']),
      metaDescription: LocalizedText.fromJson(map['metaDescription']),
    );
  }

  final LocalizedText slug;
  final LocalizedText title;
  final LocalizedText metaDescription;

  Map<String, dynamic> toJson() => {
    'slug': slug.toJson(),
    'title': title.toJson(),
    'metaDescription': metaDescription.toJson(),
  };
}

/// A catalog product (collection `products`, §5.1). Textual user-facing fields
/// are [LocalizedText]; monetary amounts are integer cents.
class Product {
  const Product({
    required this.id,
    required this.sku,
    required this.barcode,
    required this.categoryRef,
    required this.type,
    required this.name,
    required this.shortDescription,
    required this.description,
    required this.activeIngredient,
    required this.posology,
    required this.contraindications,
    required this.warnings,
    required this.ceMarking,
    required this.priceList,
    required this.priceSale,
    required this.currency,
    required this.vatRate,
    required this.stockQty,
    required this.available,
    required this.images,
    required this.seo,
    required this.status,
    required this.aiGenerated,
    required this.assistantEligible,
    this.reviewedBy,
    this.reviewedAt,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json, String id) => Product(
    id: id,
    sku: (json['sku'] as String?) ?? '',
    barcode: (json['barcode'] as String?) ?? '',
    categoryRef: (json['categoryRef'] as String?) ?? '',
    type: ProductType.fromStorage(json['type']),
    name: LocalizedText.fromJson(json['name']),
    shortDescription: LocalizedText.fromJson(json['shortDescription']),
    description: LocalizedText.fromJson(json['description']),
    activeIngredient: LocalizedText.fromJson(json['activeIngredient']),
    posology: LocalizedText.fromJson(json['posology']),
    contraindications: LocalizedText.fromJson(json['contraindications']),
    warnings: LocalizedText.fromJson(json['warnings']),
    ceMarking: (json['ceMarking'] as bool?) ?? false,
    priceList: centsFromJson(json['priceList']),
    priceSale: centsFromJson(json['priceSale']),
    currency: (json['currency'] as String?) ?? 'EUR',
    vatRate: centsFromJson(json['vatRate']),
    stockQty: centsFromJson(json['stockQty']),
    available: (json['available'] as bool?) ?? false,
    images: (json['images'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(ProductImage.fromJson)
        .toList(),
    seo: ProductSeo.fromJson(json['seo']),
    status: ProductStatus.fromStorage(json['status']),
    aiGenerated: (json['aiGenerated'] as bool?) ?? false,
    // Defaults to true so newly created products are suggestible by the AI
    // assistant unless the pharmacist opts them out (§12.3).
    assistantEligible: (json['assistantEligible'] as bool?) ?? true,
    reviewedBy: json['reviewedBy'] as String?,
    reviewedAt: dateFromJson(json['reviewedAt']),
    publishedAt: dateFromJson(json['publishedAt']),
    createdAt: dateFromJson(json['createdAt']),
    updatedAt: dateFromJson(json['updatedAt']),
  );

  final String id;
  final String sku;
  final String barcode;
  final String categoryRef;
  final ProductType type;
  final LocalizedText name;
  final LocalizedText shortDescription;
  final LocalizedText description;
  final LocalizedText activeIngredient;
  final LocalizedText posology;
  final LocalizedText contraindications;
  final LocalizedText warnings;
  final bool ceMarking;
  final int priceList;
  final int priceSale;
  final String currency;
  final int vatRate;
  final int stockQty;
  final bool available;
  final List<ProductImage> images;
  final ProductSeo seo;
  final ProductStatus status;
  final bool aiGenerated;
  final bool assistantEligible;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Whether this product carries the medicine treatment (page separation +
  /// ministerial logo, §9.2, §16.8).
  bool get isMedicine => type.isMedicine;

  bool get isPublished => status == ProductStatus.published;

  bool get isOnSale => priceSale > 0 && priceSale < priceList;

  /// The price actually charged (sale price when discounted, else list price).
  int get effectivePrice => isOnSale ? priceSale : priceList;

  /// A medicine cannot be published without posology and contraindications in
  /// both languages (validation rule, §9.2). Non-medicines skip this check.
  bool get meetsMedicinePublishingRule {
    if (!isMedicine) return true;
    return posology.isComplete && contraindications.isComplete;
  }

  Map<String, dynamic> toJson() => {
    'sku': sku,
    'barcode': barcode,
    'categoryRef': categoryRef,
    'type': type.storageName,
    'isMedicine': isMedicine,
    'name': name.toJson(),
    'shortDescription': shortDescription.toJson(),
    'description': description.toJson(),
    'activeIngredient': activeIngredient.toJson(),
    'posology': posology.toJson(),
    'contraindications': contraindications.toJson(),
    'warnings': warnings.toJson(),
    'ceMarking': ceMarking,
    'priceList': priceList,
    'priceSale': priceSale,
    'currency': currency,
    'vatRate': vatRate,
    'stockQty': stockQty,
    'available': available,
    'images': images.map((i) => i.toJson()).toList(),
    'seo': seo.toJson(),
    'status': status.storageName,
    'aiGenerated': aiGenerated,
    'assistantEligible': assistantEligible,
    'reviewedBy': reviewedBy,
    'reviewedAt': dateToJson(reviewedAt),
    'publishedAt': dateToJson(publishedAt),
    'createdAt': dateToJson(createdAt),
    'updatedAt': dateToJson(updatedAt),
  };
}
