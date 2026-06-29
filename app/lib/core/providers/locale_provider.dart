import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localeKey = 'app_locale';

/// Persists locale override; defaults to device locale (IT or EN).
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    _loadSavedLocale();
    return _deviceLocale();
  }

  Locale _deviceLocale() {
    final code = PlatformDispatcher.instance.locale.languageCode;
    return Locale(code == 'en' ? 'en' : 'it');
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_localeKey);
    if (saved != null && (saved == 'it' || saved == 'en')) {
      state = Locale(saved);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  Future<void> toggleLocale() async {
    final next = state.languageCode == 'it'
        ? const Locale('en')
        : const Locale('it');
    await setLocale(next);
  }
}
