import 'package:flutter/foundation.dart';

/// Lightweight, PII-safe structured logging. Emits one line per event via
/// [debugPrint], so entries show up in the browser console (web) and device
/// logs — **including release builds**, which is what makes it useful for
/// diagnosing the deployed app.
///
/// Rule (GDPR, §9.2): log events, uids, roles and error *codes* — never
/// passwords, tokens or raw personal data. Use [maskEmail] when an email must
/// appear in a log line.
class AppLogger {
  const AppLogger(this.name);

  /// Source tag, e.g. `auth.repo`, `auth.state`, `router`.
  final String name;

  void info(String message, [Map<String, Object?>? data]) {
    debugPrint('[$name] $message${_fmt(data)}');
  }

  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) {
    debugPrint('[$name] ERROR $message${_fmt(data)}');
    if (error != null) debugPrint('[$name]   cause: $error');
    if (stackTrace != null) debugPrint('[$name]   $stackTrace');
  }

  String _fmt(Map<String, Object?>? data) {
    if (data == null || data.isEmpty) return '';
    return ' | ${data.entries.map((e) => '${e.key}=${e.value}').join(' ')}';
  }
}

/// Masks an email for logs: `mario.rossi@example.com` -> `m***@example.com`.
/// Keeps enough to correlate accounts without storing the full address.
String maskEmail(String? email) {
  if (email == null || email.isEmpty) return '(none)';
  final at = email.indexOf('@');
  if (at <= 0) return '***';
  return '${email[0]}***${email.substring(at)}';
}
