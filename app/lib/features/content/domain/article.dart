import '../../../core/firebase/firestore_converters.dart';
import '../../../core/models/localized_text.dart';

/// Publication state for blog/E-E-A-T articles (§6.3).
enum ArticleStatus {
  draft,
  published;

  static ArticleStatus fromStorage(Object? value) =>
      enumFromName(value, ArticleStatus.values, ArticleStatus.draft);
}

/// A blog/health-guide article (collection `articles`, §5.1). YMYL content:
/// authored and reviewed by the pharmacist with a review date (§6.3). Public
/// reads allowed only for [published] (§5.5).
class Article {
  const Article({
    required this.id,
    required this.slug,
    required this.title,
    required this.body,
    required this.authorRef,
    required this.status,
    this.reviewedBy,
    this.lastReviewedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json, String id) => Article(
    id: id,
    slug: LocalizedText.fromJson(json['slug']),
    title: LocalizedText.fromJson(json['title']),
    body: LocalizedText.fromJson(json['body']),
    authorRef: (json['authorRef'] as String?) ?? '',
    reviewedBy: json['reviewedBy'] as String?,
    lastReviewedAt: dateFromJson(json['lastReviewedAt']),
    status: ArticleStatus.fromStorage(json['status']),
  );

  final String id;
  final LocalizedText slug;
  final LocalizedText title;
  final LocalizedText body;
  final String authorRef;
  final String? reviewedBy;
  final DateTime? lastReviewedAt;
  final ArticleStatus status;

  bool get isPublished => status == ArticleStatus.published;

  Map<String, dynamic> toJson() => {
    'slug': slug.toJson(),
    'title': title.toJson(),
    'body': body.toJson(),
    'authorRef': authorRef,
    'reviewedBy': reviewedBy,
    'lastReviewedAt': dateToJson(lastReviewedAt),
    'status': status.name,
  };
}
