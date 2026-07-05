import 'dart:math' as math;

/// Client-side fuzzy matching for the catalog search (§13.1).
///
/// Chosen over a hosted engine (Algolia/Typesense) for the MVP: it runs on the
/// already-loaded published catalog, costs nothing, works offline (§9.1) and is
/// enough for a small/medium catalog. The `products/sync → engine` Cloud
/// Function (ADR in Per step §2.4) is the migration path when the catalog
/// grows. The public contract here (`fuzzyScore`/`fuzzyMatch`) stays stable.
///
/// Normalization strips diacritics, lowercases and drops non-alphanumerics
/// (including spaces) — that is what makes "okitask" match "Oki Task".
abstract final class Fuzzy {
  static const Map<String, String> _diacritics = {
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'å': 'a',
    'è': 'e',
    'é': 'e',
    'ê': 'e',
    'ë': 'e',
    'ì': 'i',
    'í': 'i',
    'î': 'i',
    'ï': 'i',
    'ò': 'o',
    'ó': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'ù': 'u',
    'ú': 'u',
    'û': 'u',
    'ü': 'u',
    'ñ': 'n',
    'ç': 'c',
    'ß': 'ss',
  };

  /// Lowercase, strip diacritics, keep only `[a-z0-9]`.
  static String normalize(String input) {
    final lower = input.toLowerCase();
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      final mapped = _diacritics[char] ?? char;
      for (final c in mapped.codeUnits) {
        final isDigit = c >= 0x30 && c <= 0x39;
        final isLower = c >= 0x61 && c <= 0x7a;
        if (isDigit || isLower) buffer.writeCharCode(c);
      }
    }
    return buffer.toString();
  }

  /// Levenshtein edit distance between two strings.
  static int levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    var previous = List<int>.generate(b.length + 1, (i) => i);
    var current = List<int>.filled(b.length + 1, 0);

    for (var i = 0; i < a.length; i++) {
      current[0] = i + 1;
      for (var j = 0; j < b.length; j++) {
        final cost = a.codeUnitAt(i) == b.codeUnitAt(j) ? 0 : 1;
        current[j + 1] = math.min(
          math.min(current[j] + 1, previous[j + 1] + 1),
          previous[j] + cost,
        );
      }
      final tmp = previous;
      previous = current;
      current = tmp;
    }
    return previous[b.length];
  }

  /// Similarity in `[0, 1]` from edit distance (1 = identical).
  static double _similarity(String a, String b) {
    if (a.isEmpty || b.isEmpty) return 0;
    final maxLen = math.max(a.length, b.length);
    return 1 - levenshtein(a, b) / maxLen;
  }

  /// Relevance score in `[0, 1]` of [target] for the given [query].
  ///
  /// Exact/prefix substring hits score highest; otherwise the best per-token
  /// edit-distance similarity is used, so single-word typos still match.
  static double fuzzyScore(String query, String target) {
    final q = normalize(query);
    if (q.isEmpty) return 0;
    final t = normalize(target);
    if (t.isEmpty) return 0;

    if (t.startsWith(q)) return 1;
    if (t.contains(q)) return 0.85 + 0.15 * (q.length / t.length);

    var best = _similarity(q, t);
    for (final token in target.split(RegExp(r'\s+'))) {
      final nt = normalize(token);
      if (nt.isEmpty) continue;
      if (nt.startsWith(q)) return 0.95;
      if (nt.contains(q)) return 0.9;
      final s = _similarity(q, nt);
      if (s > best) best = s;
    }
    return best;
  }

  /// Best score of [query] across several [targets] (name, ingredient, sku…).
  static double bestScore(String query, Iterable<String> targets) {
    var best = 0.0;
    for (final target in targets) {
      final s = fuzzyScore(query, target);
      if (s > best) best = s;
      if (best >= 1) break;
    }
    return best;
  }

  /// Whether [target] matches [query] at or above [threshold].
  static bool fuzzyMatch(
    String query,
    String target, {
    double threshold = 0.62,
  }) => fuzzyScore(query, target) >= threshold;
}
