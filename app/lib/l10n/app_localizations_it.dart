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

  @override
  String get signIn => 'Accedi';

  @override
  String get createAccount => 'Crea un account';

  @override
  String get alreadyHaveAccount => 'Hai già un account? Accedi';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get displayNameLabel => 'Nome';

  @override
  String get fieldRequired => 'Campo obbligatorio';

  @override
  String get invalidEmail => 'Inserisci un\'email valida';

  @override
  String get passwordTooShort => 'La password deve avere almeno 6 caratteri';

  @override
  String get authErrorGeneric => 'Si è verificato un errore. Riprova.';

  @override
  String get authErrorInvalidCredentials => 'Email o password non corretti.';

  @override
  String get authErrorTooManyRequests => 'Troppi tentativi. Riprova più tardi.';

  @override
  String get authErrorEmailInUse => 'Esiste già un account con questa email.';

  @override
  String get profileTitle => 'Profilo';

  @override
  String get guestProfileMessage =>
      'Accedi o registrati per gestire ordini, indirizzi e consensi.';

  @override
  String get signOut => 'Esci';

  @override
  String get viewModeLabel => 'Vista';

  @override
  String get viewAsCustomer => 'Cliente';

  @override
  String get viewAsAdmin => 'Admin';

  @override
  String get roleCustomer => 'Cliente';

  @override
  String get rolePharmacist => 'Farmacista';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get ordersTitle => 'I miei ordini';

  @override
  String get comingSoonPhase3 => 'Disponibile nella Fase 3';

  @override
  String get comingSoonPhase4 => 'Disponibile nella Fase 4';

  @override
  String get adminAreaTitle => 'Area amministrazione';

  @override
  String adminWelcome(String name) {
    return 'Benvenuto, $name';
  }

  @override
  String get adminAddProduct => 'Aggiungi prodotto (AI)';

  @override
  String get adminManageCatalog => 'Gestione catalogo';

  @override
  String get adminManageOrders => 'Gestione ordini';

  @override
  String get consentsTitle => 'Consensi e privacy';

  @override
  String get consentsIntro =>
      'Gestisci i tuoi consensi. Puoi modificarli o revocarli in qualsiasi momento.';

  @override
  String get consentsSaved => 'Consensi aggiornati';

  @override
  String get saveConsents => 'Salva consensi';

  @override
  String get consentMarketingTitle => 'Comunicazioni marketing';

  @override
  String get consentMarketingBody => 'Ricevi offerte e novità via email.';

  @override
  String get consentMedicineDataTitle => 'Trattamento dati dei medicinali';

  @override
  String get consentMedicineDataBody =>
      'Necessario per ordinare medicinali SOP/OTC (dato sanitario).';

  @override
  String get consentAiAssistantTitle => 'Assistente AI (dati sanitari)';

  @override
  String get consentAiAssistantBody =>
      'Consenso esplicito al trattamento dei sintomi digitati nella chat (art. 9 GDPR).';

  @override
  String get ministerialLogoTitle => 'Vendita online di medicinali';

  @override
  String get ministerialLogoSemantics =>
      'Logo identificativo nazionale per la vendita online di medicinali';

  @override
  String get ministerialLogoAuthorized =>
      'Farmacia autorizzata dal Ministero della Salute.';

  @override
  String get ministerialLogoPending =>
      'Autorizzazione ministeriale da confermare prima della vendita.';

  @override
  String get cookieBannerTitle => 'Cookie e privacy';

  @override
  String get cookieBannerBody =>
      'Usiamo cookie tecnici e, previo consenso, cookie di analisi per migliorare il servizio.';

  @override
  String get cookieAccept => 'Accetta tutti';

  @override
  String get cookieReject => 'Solo essenziali';

  @override
  String get withdrawalButton => 'Richiedi recesso';

  @override
  String get withdrawalConfirm => 'Conferma recesso';

  @override
  String get withdrawalConfirmBody =>
      'Vuoi esercitare il diritto di recesso per questo ordine (art. 54-bis)? La richiesta verrà registrata.';

  @override
  String get withdrawalRequested =>
      'Recesso richiesto. Ti contatteremo per completare la procedura.';

  @override
  String get cancel => 'Annulla';
}
