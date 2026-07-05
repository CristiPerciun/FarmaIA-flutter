import 'dart:ui' show Locale;

/// A user-facing text stored bilingually (IT/EN) as a Firestore map
/// `{ "it": "...", "en": "..." }` (§5, §8).
///
/// The same document therefore serves both locales; the AI pipeline (§10)
/// generates both languages and the pharmacist validates both.
class LocalizedText {
  const LocalizedText({required this.it, required this.en});

  const LocalizedText.empty() : it = '', en = '';

  /// A value present only in Italian (EN falls back to IT until translated).
  const LocalizedText.it(this.it) : en = '';

  factory LocalizedText.fromJson(Object? json) {
    if (json is Map) {
      return LocalizedText(
        it: (json['it'] as String?) ?? '',
        en: (json['en'] as String?) ?? '',
      );
    }
    // Tolerate legacy/plain-string values.
    if (json is String) return LocalizedText(it: json, en: json);
    return const LocalizedText.empty();
  }

  final String it;
  final String en;

  Map<String, dynamic> toJson() => {'it': it, 'en': en};

  /// Resolves the string for [locale], falling back to Italian (the default
  /// language) when the English value is missing.
  String resolve(Locale locale) => resolveCode(locale.languageCode);

  String resolveCode(String languageCode) {
    if (languageCode == 'en' && en.isNotEmpty) return en;
    return it.isNotEmpty ? it : en;
  }

  bool get isEmpty => it.isEmpty && en.isEmpty;
  bool get isNotEmpty => !isEmpty;

  /// True when both languages carry a value — required before a medicine can
  /// be published (validation rule, §9.2).
  bool get isComplete => it.isNotEmpty && en.isNotEmpty;

  LocalizedText copyWith({String? it, String? en}) =>
      LocalizedText(it: it ?? this.it, en: en ?? this.en);

  @override
  bool operator ==(Object other) =>
      other is LocalizedText && other.it == it && other.en == en;

  @override
  int get hashCode => Object.hash(it, en);

  @override
  String toString() => 'LocalizedText(it: "$it", en: "$en")';
}
