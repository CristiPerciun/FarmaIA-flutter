import 'package:cloud_firestore/cloud_firestore.dart';

/// Shared helpers to translate Firestore raw values into typed model fields
/// and back. Kept in one place so every model reads/writes dates, money and
/// enums consistently (§5).

/// Reads a Firestore date value, tolerating [Timestamp], ISO strings, epoch
/// millis and [DateTime].
DateTime? dateFromJson(Object? value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  return null;
}

/// Writes a [DateTime] as a Firestore [Timestamp] (null-safe).
Object? dateToJson(DateTime? value) =>
    value == null ? null : Timestamp.fromDate(value);

/// Reads an integer amount in cents, tolerating num/string inputs. Amounts are
/// always stored as integer cents to avoid rounding errors (§5).
int centsFromJson(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

/// Reads a `List<String>` from a Firestore array (null-safe).
List<String> stringListFromJson(Object? value) {
  if (value is Iterable) {
    return value.whereType<Object?>().map((e) => e.toString()).toList();
  }
  return const [];
}

/// Parses an enum from its stored `name`, returning [fallback] when the stored
/// value is unknown (forward-compatible with values added later).
T enumFromName<T extends Enum>(Object? value, List<T> values, T fallback) {
  if (value is String) {
    for (final v in values) {
      if (v.name == value) return v;
    }
  }
  return fallback;
}
