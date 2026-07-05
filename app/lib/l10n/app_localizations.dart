import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// Application title
  ///
  /// In it, this message translates to:
  /// **'Baganza Farmacie'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In it, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @catalogTitle.
  ///
  /// In it, this message translates to:
  /// **'Negozio'**
  String get catalogTitle;

  /// No description provided for @styleGuideTitle.
  ///
  /// In it, this message translates to:
  /// **'Style Guide'**
  String get styleGuideTitle;

  /// No description provided for @navToCatalog.
  ///
  /// In it, this message translates to:
  /// **'Vai al negozio'**
  String get navToCatalog;

  /// No description provided for @navToHome.
  ///
  /// In it, this message translates to:
  /// **'Torna alla home'**
  String get navToHome;

  /// No description provided for @navToStyleGuide.
  ///
  /// In it, this message translates to:
  /// **'Style guide'**
  String get navToStyleGuide;

  /// No description provided for @languageLabel.
  ///
  /// In it, this message translates to:
  /// **'Lingua'**
  String get languageLabel;

  /// No description provided for @languageItalian.
  ///
  /// In it, this message translates to:
  /// **'Italiano'**
  String get languageItalian;

  /// No description provided for @languageEnglish.
  ///
  /// In it, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @welcomeMessage.
  ///
  /// In it, this message translates to:
  /// **'Benvenuto in Baganza Farmacie'**
  String get welcomeMessage;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Non solo farmaci — Parma'**
  String get welcomeSubtitle;

  /// No description provided for @demoCounterLabel.
  ///
  /// In it, this message translates to:
  /// **'Contatore demo (Riverpod)'**
  String get demoCounterLabel;

  /// No description provided for @incrementButton.
  ///
  /// In it, this message translates to:
  /// **'Incrementa'**
  String get incrementButton;

  /// No description provided for @catalogPlaceholder.
  ///
  /// In it, this message translates to:
  /// **'Il catalogo prodotti sarà disponibile nella Fase 2.'**
  String get catalogPlaceholder;

  /// No description provided for @logoPlaceholder.
  ///
  /// In it, this message translates to:
  /// **'Baganza Farmacie'**
  String get logoPlaceholder;

  /// Messaggio mostrato per una rotta inesistente
  ///
  /// In it, this message translates to:
  /// **'Pagina non trovata: {path}'**
  String notFound(String path);

  /// No description provided for @signIn.
  ///
  /// In it, this message translates to:
  /// **'Accedi'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In it, this message translates to:
  /// **'Crea un account'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In it, this message translates to:
  /// **'Hai già un account? Accedi'**
  String get alreadyHaveAccount;

  /// No description provided for @emailLabel.
  ///
  /// In it, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In it, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @displayNameLabel.
  ///
  /// In it, this message translates to:
  /// **'Nome'**
  String get displayNameLabel;

  /// No description provided for @fieldRequired.
  ///
  /// In it, this message translates to:
  /// **'Campo obbligatorio'**
  String get fieldRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In it, this message translates to:
  /// **'Inserisci un\'email valida'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In it, this message translates to:
  /// **'La password deve avere almeno 6 caratteri'**
  String get passwordTooShort;

  /// No description provided for @authErrorGeneric.
  ///
  /// In it, this message translates to:
  /// **'Si è verificato un errore. Riprova.'**
  String get authErrorGeneric;

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In it, this message translates to:
  /// **'Email o password non corretti.'**
  String get authErrorInvalidCredentials;

  /// No description provided for @authErrorTooManyRequests.
  ///
  /// In it, this message translates to:
  /// **'Troppi tentativi. Riprova più tardi.'**
  String get authErrorTooManyRequests;

  /// No description provided for @authErrorEmailInUse.
  ///
  /// In it, this message translates to:
  /// **'Esiste già un account con questa email.'**
  String get authErrorEmailInUse;

  /// No description provided for @profileTitle.
  ///
  /// In it, this message translates to:
  /// **'Profilo'**
  String get profileTitle;

  /// No description provided for @guestProfileMessage.
  ///
  /// In it, this message translates to:
  /// **'Accedi o registrati per gestire ordini, indirizzi e consensi.'**
  String get guestProfileMessage;

  /// No description provided for @signOut.
  ///
  /// In it, this message translates to:
  /// **'Esci'**
  String get signOut;

  /// No description provided for @viewModeLabel.
  ///
  /// In it, this message translates to:
  /// **'Vista'**
  String get viewModeLabel;

  /// No description provided for @viewAsCustomer.
  ///
  /// In it, this message translates to:
  /// **'Cliente'**
  String get viewAsCustomer;

  /// No description provided for @viewAsAdmin.
  ///
  /// In it, this message translates to:
  /// **'Admin'**
  String get viewAsAdmin;

  /// No description provided for @roleCustomer.
  ///
  /// In it, this message translates to:
  /// **'Cliente'**
  String get roleCustomer;

  /// No description provided for @rolePharmacist.
  ///
  /// In it, this message translates to:
  /// **'Farmacista'**
  String get rolePharmacist;

  /// No description provided for @roleAdmin.
  ///
  /// In it, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @ordersTitle.
  ///
  /// In it, this message translates to:
  /// **'I miei ordini'**
  String get ordersTitle;

  /// No description provided for @comingSoonPhase3.
  ///
  /// In it, this message translates to:
  /// **'Disponibile nella Fase 3'**
  String get comingSoonPhase3;

  /// No description provided for @comingSoonPhase4.
  ///
  /// In it, this message translates to:
  /// **'Disponibile nella Fase 4'**
  String get comingSoonPhase4;

  /// No description provided for @adminAreaTitle.
  ///
  /// In it, this message translates to:
  /// **'Area amministrazione'**
  String get adminAreaTitle;

  /// Saluto nella dashboard admin
  ///
  /// In it, this message translates to:
  /// **'Benvenuto, {name}'**
  String adminWelcome(String name);

  /// No description provided for @adminAddProduct.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi prodotto (AI)'**
  String get adminAddProduct;

  /// No description provided for @adminManageCatalog.
  ///
  /// In it, this message translates to:
  /// **'Gestione catalogo'**
  String get adminManageCatalog;

  /// No description provided for @adminManageOrders.
  ///
  /// In it, this message translates to:
  /// **'Gestione ordini'**
  String get adminManageOrders;

  /// No description provided for @consentsTitle.
  ///
  /// In it, this message translates to:
  /// **'Consensi e privacy'**
  String get consentsTitle;

  /// No description provided for @consentsIntro.
  ///
  /// In it, this message translates to:
  /// **'Gestisci i tuoi consensi. Puoi modificarli o revocarli in qualsiasi momento.'**
  String get consentsIntro;

  /// No description provided for @consentsSaved.
  ///
  /// In it, this message translates to:
  /// **'Consensi aggiornati'**
  String get consentsSaved;

  /// No description provided for @saveConsents.
  ///
  /// In it, this message translates to:
  /// **'Salva consensi'**
  String get saveConsents;

  /// No description provided for @consentMarketingTitle.
  ///
  /// In it, this message translates to:
  /// **'Comunicazioni marketing'**
  String get consentMarketingTitle;

  /// No description provided for @consentMarketingBody.
  ///
  /// In it, this message translates to:
  /// **'Ricevi offerte e novità via email.'**
  String get consentMarketingBody;

  /// No description provided for @consentMedicineDataTitle.
  ///
  /// In it, this message translates to:
  /// **'Trattamento dati dei medicinali'**
  String get consentMedicineDataTitle;

  /// No description provided for @consentMedicineDataBody.
  ///
  /// In it, this message translates to:
  /// **'Necessario per ordinare medicinali SOP/OTC (dato sanitario).'**
  String get consentMedicineDataBody;

  /// No description provided for @consentAiAssistantTitle.
  ///
  /// In it, this message translates to:
  /// **'Assistente AI (dati sanitari)'**
  String get consentAiAssistantTitle;

  /// No description provided for @consentAiAssistantBody.
  ///
  /// In it, this message translates to:
  /// **'Consenso esplicito al trattamento dei sintomi digitati nella chat (art. 9 GDPR).'**
  String get consentAiAssistantBody;

  /// No description provided for @ministerialLogoTitle.
  ///
  /// In it, this message translates to:
  /// **'Vendita online di medicinali'**
  String get ministerialLogoTitle;

  /// No description provided for @ministerialLogoSemantics.
  ///
  /// In it, this message translates to:
  /// **'Logo identificativo nazionale per la vendita online di medicinali'**
  String get ministerialLogoSemantics;

  /// No description provided for @ministerialLogoAuthorized.
  ///
  /// In it, this message translates to:
  /// **'Farmacia autorizzata dal Ministero della Salute.'**
  String get ministerialLogoAuthorized;

  /// No description provided for @ministerialLogoPending.
  ///
  /// In it, this message translates to:
  /// **'Autorizzazione ministeriale da confermare prima della vendita.'**
  String get ministerialLogoPending;

  /// No description provided for @cookieBannerTitle.
  ///
  /// In it, this message translates to:
  /// **'Cookie e privacy'**
  String get cookieBannerTitle;

  /// No description provided for @cookieBannerBody.
  ///
  /// In it, this message translates to:
  /// **'Usiamo cookie tecnici e, previo consenso, cookie di analisi per migliorare il servizio.'**
  String get cookieBannerBody;

  /// No description provided for @cookieAccept.
  ///
  /// In it, this message translates to:
  /// **'Accetta tutti'**
  String get cookieAccept;

  /// No description provided for @cookieReject.
  ///
  /// In it, this message translates to:
  /// **'Solo essenziali'**
  String get cookieReject;

  /// No description provided for @withdrawalButton.
  ///
  /// In it, this message translates to:
  /// **'Richiedi recesso'**
  String get withdrawalButton;

  /// No description provided for @withdrawalConfirm.
  ///
  /// In it, this message translates to:
  /// **'Conferma recesso'**
  String get withdrawalConfirm;

  /// No description provided for @withdrawalConfirmBody.
  ///
  /// In it, this message translates to:
  /// **'Vuoi esercitare il diritto di recesso per questo ordine (art. 54-bis)? La richiesta verrà registrata.'**
  String get withdrawalConfirmBody;

  /// No description provided for @withdrawalRequested.
  ///
  /// In it, this message translates to:
  /// **'Recesso richiesto. Ti contatteremo per completare la procedura.'**
  String get withdrawalRequested;

  /// No description provided for @cancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get cancel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
