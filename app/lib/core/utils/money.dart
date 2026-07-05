import 'package:intl/intl.dart';

/// Formatting helpers for monetary amounts stored as integer cents (§5).
extension CentsFormatting on int {
  /// Formats this amount (in cents) as localized currency, e.g. `6,99 €` (IT)
  /// or `€6.99` (EN). Defaults to EUR.
  String formatMoney({String localeCode = 'it', String currency = 'EUR'}) {
    final format = NumberFormat.currency(
      locale: localeCode == 'en' ? 'en' : 'it',
      symbol: currency == 'EUR' ? '€' : currency,
      decimalDigits: 2,
    );
    return format.format(this / 100).trim();
  }
}
