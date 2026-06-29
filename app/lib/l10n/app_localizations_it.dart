// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Baganza Farmacie';

  @override
  String get homeTitle => 'Home';

  @override
  String get catalogTitle => 'Negozio';

  @override
  String get styleGuideTitle => 'Style Guide';

  @override
  String get navToCatalog => 'Vai al negozio';

  @override
  String get navToHome => 'Torna alla home';

  @override
  String get navToStyleGuide => 'Style guide';

  @override
  String get languageLabel => 'Lingua';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageEnglish => 'English';

  @override
  String get welcomeMessage => 'Benvenuto in Baganza Farmacie';

  @override
  String get welcomeSubtitle => 'Non solo farmaci — Parma';

  @override
  String get demoCounterLabel => 'Contatore demo (Riverpod)';

  @override
  String get incrementButton => 'Incrementa';

  @override
  String get catalogPlaceholder =>
      'Il catalogo prodotti sarà disponibile nella Fase 2.';

  @override
  String get logoPlaceholder => 'Baganza Farmacie';

  @override
  String notFound(String path) {
    return 'Pagina non trovata: $path';
  }
}
