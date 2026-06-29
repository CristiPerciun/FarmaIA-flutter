// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Baganza Pharmacies';

  @override
  String get homeTitle => 'Home';

  @override
  String get catalogTitle => 'Shop';

  @override
  String get styleGuideTitle => 'Style Guide';

  @override
  String get navToCatalog => 'Go to shop';

  @override
  String get navToHome => 'Back to home';

  @override
  String get navToStyleGuide => 'Style guide';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageEnglish => 'English';

  @override
  String get welcomeMessage => 'Welcome to Baganza Pharmacies';

  @override
  String get welcomeSubtitle => 'More than medicines — Parma';

  @override
  String get demoCounterLabel => 'Demo counter (Riverpod)';

  @override
  String get incrementButton => 'Increment';

  @override
  String get catalogPlaceholder =>
      'The product catalog will be available in Phase 2.';

  @override
  String get logoPlaceholder => 'Baganza Pharmacies';

  @override
  String notFound(String path) {
    return 'Page not found: $path';
  }
}
