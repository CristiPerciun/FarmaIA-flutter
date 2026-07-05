import '../../catalog/domain/product.dart';

/// Enforces the rule that a listing/page must never mix medicines and
/// non-medicines (§9.2, §16.8). Fase 2 catalog screens call these helpers when
/// composing product lists.
abstract final class MedicineSeparation {
  /// True when the set contains both a medicine and a non-medicine.
  static bool isMixed(Iterable<Product> products) {
    var hasMedicine = false;
    var hasNonMedicine = false;
    for (final p in products) {
      hasMedicine |= p.isMedicine;
      hasNonMedicine |= !p.isMedicine;
      if (hasMedicine && hasNonMedicine) return true;
    }
    return false;
  }

  /// True when every product shares the same medicine/non-medicine nature (or
  /// the list is empty) — the condition a single page must satisfy.
  static bool isHomogeneous(Iterable<Product> products) => !isMixed(products);

  /// Debug-time guard: throws in debug builds if a page would mix the two.
  /// A no-op cost in release (assert is stripped).
  static void assertHomogeneous(Iterable<Product> products) {
    assert(
      isHomogeneous(products),
      'Medicine/non-medicine separation violated (§9.2): a page must not mix '
      'medicines and non-medicines.',
    );
  }
}
