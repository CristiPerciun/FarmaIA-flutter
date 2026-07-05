import 'package:flutter_test/flutter_test.dart';

import 'package:baganza_app/core/utils/fuzzy.dart';

void main() {
  group('Fuzzy.normalize', () {
    test('lowercases, strips diacritics and non-alphanumerics', () {
      expect(Fuzzy.normalize('Oki Task'), 'okitask');
      expect(Fuzzy.normalize('Acidò-Folìco 400'), 'acidofolico400');
      expect(Fuzzy.normalize('  Über/Straße  '), 'uberstrasse');
    });
  });

  group('Fuzzy.levenshtein', () {
    test('counts edits', () {
      expect(Fuzzy.levenshtein('kitten', 'sitting'), 3);
      expect(Fuzzy.levenshtein('oki', 'oki'), 0);
    });
  });

  group('Fuzzy.fuzzyScore / fuzzyMatch', () {
    test('okitask matches "Oki Task" (acceptance criterion 2.4)', () {
      // Space-stripping normalization makes the query a prefix of the target.
      expect(Fuzzy.fuzzyScore('okitask', 'Oki Task'), 1.0);
      expect(Fuzzy.fuzzyMatch('okitask', 'Oki Task'), isTrue);
    });

    test('tolerates a single-character typo', () {
      expect(Fuzzy.fuzzyMatch('tachpirina', 'Tachipirina'), isTrue);
      expect(Fuzzy.fuzzyMatch('ibuprofene', 'Ibuprofen'), isTrue);
    });

    test('prefix query scores highest', () {
      expect(Fuzzy.fuzzyScore('oki', 'Oki Task'), 1.0);
    });

    test('rejects unrelated terms', () {
      expect(Fuzzy.fuzzyMatch('aspirina', 'Crema mani'), isFalse);
    });

    test('empty query never matches', () {
      expect(Fuzzy.fuzzyScore('', 'anything'), 0.0);
    });

    test('bestScore takes the strongest field match', () {
      final score = Fuzzy.bestScore('paracetamolo', [
        'Tachipirina',
        'Paracetamolo',
        '8000000000000',
      ]);
      expect(score, 1.0);
    });
  });
}
