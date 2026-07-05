import '../../../core/firebase/firestore_converters.dart';
import '../../../core/models/localized_text.dart';

/// A catalog category (collection `categories`, §5.1). `isMedicineCategory`
/// keeps medicines and non-medicines on separate pages (§9.2).
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.isMedicineCategory,
    required this.order,
    this.parentRef,
  });

  factory Category.fromJson(Map<String, dynamic> json, String id) => Category(
    id: id,
    name: LocalizedText.fromJson(json['name']),
    slug: LocalizedText.fromJson(json['slug']),
    isMedicineCategory: (json['isMedicineCategory'] as bool?) ?? false,
    order: centsFromJson(json['order']),
    parentRef: json['parentRef'] as String?,
  );

  final String id;
  final LocalizedText name;
  final LocalizedText slug;
  final bool isMedicineCategory;
  final int order;
  final String? parentRef;

  bool get isRoot => parentRef == null;

  Map<String, dynamic> toJson() => {
    'name': name.toJson(),
    'slug': slug.toJson(),
    'isMedicineCategory': isMedicineCategory,
    'order': order,
    'parentRef': parentRef,
  };
}
