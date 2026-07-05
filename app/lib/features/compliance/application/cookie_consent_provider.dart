import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _cookieConsentKey = 'cookie_consent_v1';

/// Cookie banner state (§1.4). `null` = not yet decided (show the banner);
/// true/false = accepted/rejected non-essential cookies. Persisted locally so
/// the banner isn't shown again after a decision.
final cookieConsentProvider = NotifierProvider<CookieConsentNotifier, bool?>(
  CookieConsentNotifier.new,
);

class CookieConsentNotifier extends Notifier<bool?> {
  @override
  bool? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_cookieConsentKey)) {
      state = prefs.getBool(_cookieConsentKey);
    }
  }

  Future<void> _persist(bool accepted) async {
    state = accepted;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cookieConsentKey, accepted);
  }

  Future<void> acceptAll() => _persist(true);

  Future<void> rejectNonEssential() => _persist(false);

  bool get decided => state != null;
}
