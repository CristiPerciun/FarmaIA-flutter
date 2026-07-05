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

  /// No description provided for @adminAssistantTitle.
  ///
  /// In it, this message translates to:
  /// **'Assistente AI — supervisione'**
  String get adminAssistantTitle;

  /// No description provided for @adminAssistantSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Registro conversazioni, escalation, red-flag'**
  String get adminAssistantSubtitle;

  /// No description provided for @adminAssistantGuardrails.
  ///
  /// In it, this message translates to:
  /// **'Liste red-flag e ricetta'**
  String get adminAssistantGuardrails;

  /// No description provided for @adminAssistantNoSessions.
  ///
  /// In it, this message translates to:
  /// **'Nessuna conversazione registrata.'**
  String get adminAssistantNoSessions;

  /// No description provided for @adminAssistantFilterAll.
  ///
  /// In it, this message translates to:
  /// **'Tutte'**
  String get adminAssistantFilterAll;

  /// No description provided for @adminAssistantFilterRedFlag.
  ///
  /// In it, this message translates to:
  /// **'Red-flag'**
  String get adminAssistantFilterRedFlag;

  /// No description provided for @adminAssistantFilterFlagged.
  ///
  /// In it, this message translates to:
  /// **'Segnalate'**
  String get adminAssistantFilterFlagged;

  /// No description provided for @adminAssistantFilterEscalations.
  ///
  /// In it, this message translates to:
  /// **'Escalation da gestire'**
  String get adminAssistantFilterEscalations;

  /// No description provided for @adminAssistantUser.
  ///
  /// In it, this message translates to:
  /// **'Utente'**
  String get adminAssistantUser;

  /// No description provided for @adminAssistantTurns.
  ///
  /// In it, this message translates to:
  /// **'turni'**
  String get adminAssistantTurns;

  /// No description provided for @adminAssistantTagRedFlag.
  ///
  /// In it, this message translates to:
  /// **'RED-FLAG'**
  String get adminAssistantTagRedFlag;

  /// No description provided for @adminAssistantTagFlagged.
  ///
  /// In it, this message translates to:
  /// **'SEGNALATA'**
  String get adminAssistantTagFlagged;

  /// No description provided for @adminAssistantTagEscalated.
  ///
  /// In it, this message translates to:
  /// **'ESCALATION'**
  String get adminAssistantTagEscalated;

  /// No description provided for @adminAssistantSession.
  ///
  /// In it, this message translates to:
  /// **'Conversazione'**
  String get adminAssistantSession;

  /// No description provided for @adminAssistantFlagWrong.
  ///
  /// In it, this message translates to:
  /// **'Risposta scorretta'**
  String get adminAssistantFlagWrong;

  /// No description provided for @adminAssistantUnflag.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi segnalazione'**
  String get adminAssistantUnflag;

  /// No description provided for @adminAssistantMarkHandled.
  ///
  /// In it, this message translates to:
  /// **'Escalation gestita'**
  String get adminAssistantMarkHandled;

  /// No description provided for @adminAssistantReviewNote.
  ///
  /// In it, this message translates to:
  /// **'Nota di revisione'**
  String get adminAssistantReviewNote;

  /// No description provided for @adminAssistantReviewNoteHint.
  ///
  /// In it, this message translates to:
  /// **'Cosa c\'era di sbagliato? (alimenta la revisione di prompt e red-flag)'**
  String get adminAssistantReviewNoteHint;

  /// No description provided for @adminAssistantRedFlagList.
  ///
  /// In it, this message translates to:
  /// **'Red-flag aggiuntive (della farmacia)'**
  String get adminAssistantRedFlagList;

  /// No description provided for @adminAssistantRxList.
  ///
  /// In it, this message translates to:
  /// **'Termini con ricetta aggiuntivi'**
  String get adminAssistantRxList;

  /// No description provided for @adminAssistantAddTerm.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi termine…'**
  String get adminAssistantAddTerm;

  /// No description provided for @adminAssistantBuiltinNote.
  ///
  /// In it, this message translates to:
  /// **'Le liste di base integrate nel sistema restano sempre attive: qui aggiungi solo termini specifici della farmacia. Le modifiche valgono dal prossimo messaggio, senza deploy.'**
  String get adminAssistantBuiltinNote;

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

  /// No description provided for @navHome.
  ///
  /// In it, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navShop.
  ///
  /// In it, this message translates to:
  /// **'Negozio'**
  String get navShop;

  /// No description provided for @navChatAi.
  ///
  /// In it, this message translates to:
  /// **'Chat AI'**
  String get navChatAi;

  /// No description provided for @navCart.
  ///
  /// In it, this message translates to:
  /// **'Carrello'**
  String get navCart;

  /// No description provided for @navProfile.
  ///
  /// In it, this message translates to:
  /// **'Profilo'**
  String get navProfile;

  /// No description provided for @catalogAllCategories.
  ///
  /// In it, this message translates to:
  /// **'Tutti'**
  String get catalogAllCategories;

  /// No description provided for @catalogFilters.
  ///
  /// In it, this message translates to:
  /// **'Filtri'**
  String get catalogFilters;

  /// No description provided for @catalogFilterCategory.
  ///
  /// In it, this message translates to:
  /// **'Categoria'**
  String get catalogFilterCategory;

  /// No description provided for @catalogFilterMedicinesOnly.
  ///
  /// In it, this message translates to:
  /// **'Solo medicinali'**
  String get catalogFilterMedicinesOnly;

  /// No description provided for @catalogFilterOnSale.
  ///
  /// In it, this message translates to:
  /// **'In offerta'**
  String get catalogFilterOnSale;

  /// No description provided for @catalogClearFilters.
  ///
  /// In it, this message translates to:
  /// **'Azzera filtri'**
  String get catalogClearFilters;

  /// No description provided for @catalogApplyFilters.
  ///
  /// In it, this message translates to:
  /// **'Applica'**
  String get catalogApplyFilters;

  /// No description provided for @catalogNoProducts.
  ///
  /// In it, this message translates to:
  /// **'Nessun prodotto trovato'**
  String get catalogNoProducts;

  /// No description provided for @catalogEmptyHint.
  ///
  /// In it, this message translates to:
  /// **'Prova a rimuovere qualche filtro o a cambiare ricerca.'**
  String get catalogEmptyHint;

  /// No description provided for @catalogResultsCount.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =0{Nessun prodotto} =1{1 prodotto} other{{count} prodotti}}'**
  String catalogResultsCount(int count);

  /// No description provided for @catalogLoadError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile caricare il catalogo.'**
  String get catalogLoadError;

  /// No description provided for @productAddToCart.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi'**
  String get productAddToCart;

  /// No description provided for @addToCartComingSoon.
  ///
  /// In it, this message translates to:
  /// **'Il carrello arriva nella Fase 3.'**
  String get addToCartComingSoon;

  /// No description provided for @priceWas.
  ///
  /// In it, this message translates to:
  /// **'Prezzo di listino {price}'**
  String priceWas(String price);

  /// No description provided for @productDescription.
  ///
  /// In it, this message translates to:
  /// **'Descrizione'**
  String get productDescription;

  /// No description provided for @productActiveIngredient.
  ///
  /// In it, this message translates to:
  /// **'Principio attivo'**
  String get productActiveIngredient;

  /// No description provided for @productPosology.
  ///
  /// In it, this message translates to:
  /// **'Posologia'**
  String get productPosology;

  /// No description provided for @productContraindications.
  ///
  /// In it, this message translates to:
  /// **'Controindicazioni'**
  String get productContraindications;

  /// No description provided for @productWarnings.
  ///
  /// In it, this message translates to:
  /// **'Avvertenze'**
  String get productWarnings;

  /// No description provided for @productCeMarking.
  ///
  /// In it, this message translates to:
  /// **'Marcatura CE'**
  String get productCeMarking;

  /// No description provided for @productCeMarkingPresent.
  ///
  /// In it, this message translates to:
  /// **'Dispositivo medico con marcatura CE.'**
  String get productCeMarkingPresent;

  /// No description provided for @productNotFound.
  ///
  /// In it, this message translates to:
  /// **'Prodotto non disponibile.'**
  String get productNotFound;

  /// No description provided for @trustReturnsTitle.
  ///
  /// In it, this message translates to:
  /// **'Reso e recesso'**
  String get trustReturnsTitle;

  /// No description provided for @trustReturnsBody.
  ///
  /// In it, this message translates to:
  /// **'Diritto di recesso entro 14 giorni (art. 54-bis). I medicinali seguono le limitazioni di legge.'**
  String get trustReturnsBody;

  /// No description provided for @searchTitle.
  ///
  /// In it, this message translates to:
  /// **'Cerca'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In it, this message translates to:
  /// **'Cerca prodotti, principi attivi…'**
  String get searchHint;

  /// No description provided for @searchAssistantHint.
  ///
  /// In it, this message translates to:
  /// **'Cerca un prodotto o chiedi un consiglio…'**
  String get searchAssistantHint;

  /// No description provided for @assistantTitle.
  ///
  /// In it, this message translates to:
  /// **'Assistente'**
  String get assistantTitle;

  /// No description provided for @assistantBridgeNote.
  ///
  /// In it, this message translates to:
  /// **'L\'assistente conversazionale AI arriva presto. Per ora ti mostro i prodotti che corrispondono alla ricerca.'**
  String get assistantBridgeNote;

  /// No description provided for @assistantEmptyPrompt.
  ///
  /// In it, this message translates to:
  /// **'Scrivi il nome di un prodotto o un principio attivo per cercarlo nel catalogo.'**
  String get assistantEmptyPrompt;

  /// No description provided for @assistantQuickChipHeadache.
  ///
  /// In it, this message translates to:
  /// **'Mal di testa'**
  String get assistantQuickChipHeadache;

  /// No description provided for @assistantQuickChipCold.
  ///
  /// In it, this message translates to:
  /// **'Raffreddore'**
  String get assistantQuickChipCold;

  /// No description provided for @assistantQuickChipSkin.
  ///
  /// In it, this message translates to:
  /// **'Consiglio pelle'**
  String get assistantQuickChipSkin;

  /// No description provided for @assistantQuickChipPharmacist.
  ///
  /// In it, this message translates to:
  /// **'Parla col farmacista'**
  String get assistantQuickChipPharmacist;

  /// No description provided for @assistantBadgeAi.
  ///
  /// In it, this message translates to:
  /// **'AI'**
  String get assistantBadgeAi;

  /// No description provided for @assistantDisclaimer.
  ///
  /// In it, this message translates to:
  /// **'Non sono un medico né un farmacista. Per casi seri rivolgiti al 112 o al tuo medico.'**
  String get assistantDisclaimer;

  /// No description provided for @assistantWelcome.
  ///
  /// In it, this message translates to:
  /// **'Ciao! Dimmi cosa ti serve o descrivi un piccolo disturbo: ti propongo prodotti dal nostro catalogo.'**
  String get assistantWelcome;

  /// No description provided for @assistantInputHint.
  ///
  /// In it, this message translates to:
  /// **'Scrivi un messaggio…'**
  String get assistantInputHint;

  /// No description provided for @assistantSend.
  ///
  /// In it, this message translates to:
  /// **'Invia'**
  String get assistantSend;

  /// No description provided for @assistantNewConversation.
  ///
  /// In it, this message translates to:
  /// **'Nuova conversazione'**
  String get assistantNewConversation;

  /// No description provided for @assistantPanelTitle.
  ///
  /// In it, this message translates to:
  /// **'Assistente AI'**
  String get assistantPanelTitle;

  /// No description provided for @assistantClose.
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get assistantClose;

  /// No description provided for @assistantPillLabel.
  ///
  /// In it, this message translates to:
  /// **'Sono il tuo assistente AI: dimmi cosa ti fa male o cosa cerchi'**
  String get assistantPillLabel;

  /// No description provided for @assistantTalkToPharmacist.
  ///
  /// In it, this message translates to:
  /// **'Parla con il farmacista'**
  String get assistantTalkToPharmacist;

  /// No description provided for @assistantEscalationSent.
  ///
  /// In it, this message translates to:
  /// **'Richiesta inviata: un farmacista ti risponderà al più presto.'**
  String get assistantEscalationSent;

  /// No description provided for @assistantRedFlagHint.
  ///
  /// In it, this message translates to:
  /// **'Caso serio: rivolgiti a un professionista'**
  String get assistantRedFlagHint;

  /// No description provided for @assistantRouterIntro.
  ///
  /// In it, this message translates to:
  /// **'Trovato nel catalogo:'**
  String get assistantRouterIntro;

  /// No description provided for @assistantOfflineFallback.
  ///
  /// In it, this message translates to:
  /// **'Non riesco a contattare l\'assistente. Ecco alcuni risultati dal catalogo; per un consiglio scrivi al farmacista.'**
  String get assistantOfflineFallback;

  /// No description provided for @assistantDailyLimit.
  ///
  /// In it, this message translates to:
  /// **'Hai raggiunto il limite giornaliero di messaggi. Riprova domani.'**
  String get assistantDailyLimit;

  /// No description provided for @assistantSessionLimit.
  ///
  /// In it, this message translates to:
  /// **'Questa conversazione è troppo lunga: iniziane una nuova.'**
  String get assistantSessionLimit;

  /// No description provided for @assistantErrorGeneric.
  ///
  /// In it, this message translates to:
  /// **'Qualcosa è andato storto. Riprova.'**
  String get assistantErrorGeneric;

  /// No description provided for @assistantOfflineBanner.
  ///
  /// In it, this message translates to:
  /// **'Sei offline: ricerca sul catalogo salvato, senza assistente.'**
  String get assistantOfflineBanner;

  /// No description provided for @assistantResultsOnlyBanner.
  ///
  /// In it, this message translates to:
  /// **'Assistente disattivato: vedi solo i risultati di ricerca.'**
  String get assistantResultsOnlyBanner;

  /// No description provided for @assistantUnavailableBanner.
  ///
  /// In it, this message translates to:
  /// **'L\'assistente non è al momento disponibile: ecco la ricerca classica.'**
  String get assistantUnavailableBanner;

  /// No description provided for @assistantEnableCta.
  ///
  /// In it, this message translates to:
  /// **'Attiva'**
  String get assistantEnableCta;

  /// No description provided for @assistantOnboardingTitle.
  ///
  /// In it, this message translates to:
  /// **'Il tuo assistente AI'**
  String get assistantOnboardingTitle;

  /// No description provided for @assistantDoes1.
  ///
  /// In it, this message translates to:
  /// **'Ti suggerisce prodotti da banco del nostro catalogo, come farebbe un commesso esperto.'**
  String get assistantDoes1;

  /// No description provided for @assistantDoes2.
  ///
  /// In it, this message translates to:
  /// **'Riconosce i casi seri e ti indirizza subito a medico, 112 o farmacista.'**
  String get assistantDoes2;

  /// No description provided for @assistantDoes3.
  ///
  /// In it, this message translates to:
  /// **'Ha sempre il farmacista al tuo fianco: puoi chiamarlo in ogni momento.'**
  String get assistantDoes3;

  /// No description provided for @assistantDoesnt1.
  ///
  /// In it, this message translates to:
  /// **'Non fa diagnosi e non sostituisce il medico o il farmacista.'**
  String get assistantDoesnt1;

  /// No description provided for @assistantDoesnt2.
  ///
  /// In it, this message translates to:
  /// **'Non consiglia farmaci con obbligo di ricetta né dosaggi fuori scheda.'**
  String get assistantDoesnt2;

  /// No description provided for @assistantConsentTitle.
  ///
  /// In it, this message translates to:
  /// **'Consenso ai dati sulla salute (art. 9 GDPR)'**
  String get assistantConsentTitle;

  /// No description provided for @assistantConsentBody.
  ///
  /// In it, this message translates to:
  /// **'Quello che scrivi in chat può includere dati sulla salute. Con il tuo consenso viene inviato al nostro assistente su server in UE, usato solo per suggerirti prodotti e conservato al massimo 90 giorni. Puoi revocare il consenso quando vuoi dal profilo; senza consenso resta attiva la ricerca classica.'**
  String get assistantConsentBody;

  /// No description provided for @assistantConsentAccept.
  ///
  /// In it, this message translates to:
  /// **'Accetto e inizio'**
  String get assistantConsentAccept;

  /// No description provided for @assistantConsentDecline.
  ///
  /// In it, this message translates to:
  /// **'Non ora: solo risultati'**
  String get assistantConsentDecline;

  /// No description provided for @searchNoResults.
  ///
  /// In it, this message translates to:
  /// **'Nessun risultato per \"{query}\"'**
  String searchNoResults(String query);

  /// No description provided for @searchClear.
  ///
  /// In it, this message translates to:
  /// **'Cancella'**
  String get searchClear;

  /// No description provided for @scanTitle.
  ///
  /// In it, this message translates to:
  /// **'Scansiona codice'**
  String get scanTitle;

  /// No description provided for @scanInstruction.
  ///
  /// In it, this message translates to:
  /// **'Inquadra il codice a barre (EAN) del prodotto.'**
  String get scanInstruction;

  /// No description provided for @scanManualTitle.
  ///
  /// In it, this message translates to:
  /// **'Inserisci il codice'**
  String get scanManualTitle;

  /// No description provided for @scanManualHint.
  ///
  /// In it, this message translates to:
  /// **'Codice EAN'**
  String get scanManualHint;

  /// No description provided for @scanManualSubmit.
  ///
  /// In it, this message translates to:
  /// **'Cerca'**
  String get scanManualSubmit;

  /// No description provided for @scanNotSupported.
  ///
  /// In it, this message translates to:
  /// **'La fotocamera non è disponibile su questo dispositivo. Inserisci il codice a mano.'**
  String get scanNotSupported;

  /// No description provided for @scanPermissionDenied.
  ///
  /// In it, this message translates to:
  /// **'Permesso fotocamera negato. Puoi inserire il codice a mano.'**
  String get scanPermissionDenied;

  /// No description provided for @scanNotFound.
  ///
  /// In it, this message translates to:
  /// **'Nessun prodotto con codice {code}.'**
  String scanNotFound(String code);

  /// No description provided for @offlineBannerTitle.
  ///
  /// In it, this message translates to:
  /// **'Sei offline'**
  String get offlineBannerTitle;

  /// No description provided for @offlineBannerBody.
  ///
  /// In it, this message translates to:
  /// **'Stai consultando il catalogo salvato. Alcune azioni non sono disponibili senza rete.'**
  String get offlineBannerBody;

  /// No description provided for @offlineActionDisabled.
  ///
  /// In it, this message translates to:
  /// **'Azione non disponibile offline.'**
  String get offlineActionDisabled;

  /// No description provided for @cartTitle.
  ///
  /// In it, this message translates to:
  /// **'Carrello'**
  String get cartTitle;

  /// No description provided for @cartEmpty.
  ///
  /// In it, this message translates to:
  /// **'Il carrello è vuoto'**
  String get cartEmpty;

  /// No description provided for @cartEmptyHint.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi prodotti dal negozio.'**
  String get cartEmptyHint;

  /// No description provided for @cartRemove.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi'**
  String get cartRemove;

  /// No description provided for @cartCheckout.
  ///
  /// In it, this message translates to:
  /// **'Vai al checkout'**
  String get cartCheckout;

  /// No description provided for @cartItemUnavailable.
  ///
  /// In it, this message translates to:
  /// **'Non più disponibile'**
  String get cartItemUnavailable;

  /// No description provided for @addedToCart.
  ///
  /// In it, this message translates to:
  /// **'Aggiunto al carrello'**
  String get addedToCart;

  /// No description provided for @cartQuantity.
  ///
  /// In it, this message translates to:
  /// **'Quantità'**
  String get cartQuantity;

  /// No description provided for @summarySubtotal.
  ///
  /// In it, this message translates to:
  /// **'Subtotale'**
  String get summarySubtotal;

  /// No description provided for @summaryShipping.
  ///
  /// In it, this message translates to:
  /// **'Spedizione'**
  String get summaryShipping;

  /// No description provided for @summaryShippingFree.
  ///
  /// In it, this message translates to:
  /// **'Gratuita'**
  String get summaryShippingFree;

  /// No description provided for @summaryVat.
  ///
  /// In it, this message translates to:
  /// **'IVA (inclusa)'**
  String get summaryVat;

  /// No description provided for @summaryVatRate.
  ///
  /// In it, this message translates to:
  /// **'di cui IVA {rate}%'**
  String summaryVatRate(int rate);

  /// No description provided for @summaryTotal.
  ///
  /// In it, this message translates to:
  /// **'Totale'**
  String get summaryTotal;

  /// No description provided for @summaryFreeShippingHint.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi {amount} per la spedizione gratuita.'**
  String summaryFreeShippingHint(String amount);

  /// No description provided for @checkoutTitle.
  ///
  /// In it, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @checkoutContact.
  ///
  /// In it, this message translates to:
  /// **'Contatti'**
  String get checkoutContact;

  /// No description provided for @checkoutGuestNote.
  ///
  /// In it, this message translates to:
  /// **'Puoi ordinare come ospite; creare un account è facoltativo.'**
  String get checkoutGuestNote;

  /// No description provided for @checkoutShippingAddress.
  ///
  /// In it, this message translates to:
  /// **'Indirizzo di spedizione'**
  String get checkoutShippingAddress;

  /// No description provided for @fieldFullName.
  ///
  /// In it, this message translates to:
  /// **'Nome e cognome'**
  String get fieldFullName;

  /// No description provided for @fieldPhone.
  ///
  /// In it, this message translates to:
  /// **'Telefono'**
  String get fieldPhone;

  /// No description provided for @fieldStreet.
  ///
  /// In it, this message translates to:
  /// **'Indirizzo (via e numero)'**
  String get fieldStreet;

  /// No description provided for @fieldCity.
  ///
  /// In it, this message translates to:
  /// **'Città'**
  String get fieldCity;

  /// No description provided for @fieldZip.
  ///
  /// In it, this message translates to:
  /// **'CAP'**
  String get fieldZip;

  /// No description provided for @fieldProvince.
  ///
  /// In it, this message translates to:
  /// **'Provincia'**
  String get fieldProvince;

  /// No description provided for @checkoutContinueToPayment.
  ///
  /// In it, this message translates to:
  /// **'Vai al pagamento'**
  String get checkoutContinueToPayment;

  /// No description provided for @paymentTitle.
  ///
  /// In it, this message translates to:
  /// **'Pagamento'**
  String get paymentTitle;

  /// No description provided for @paymentMethod.
  ///
  /// In it, this message translates to:
  /// **'Metodo di pagamento'**
  String get paymentMethod;

  /// No description provided for @paymentMethodCard.
  ///
  /// In it, this message translates to:
  /// **'Carta (Stripe/Nexi)'**
  String get paymentMethodCard;

  /// No description provided for @paymentMethodPaypal.
  ///
  /// In it, this message translates to:
  /// **'PayPal'**
  String get paymentMethodPaypal;

  /// No description provided for @paymentMethodSatispay.
  ///
  /// In it, this message translates to:
  /// **'Satispay'**
  String get paymentMethodSatispay;

  /// No description provided for @paymentMethodBnpl.
  ///
  /// In it, this message translates to:
  /// **'Paga a rate (Scalapay/Klarna)'**
  String get paymentMethodBnpl;

  /// No description provided for @paymentSandboxNotice.
  ///
  /// In it, this message translates to:
  /// **'Ambiente sandbox: nessun addebito reale. L\'integrazione dei gateway di pagamento reali è descritta nell\'ADR 0003.'**
  String get paymentSandboxNotice;

  /// No description provided for @paymentPay.
  ///
  /// In it, this message translates to:
  /// **'Paga {amount}'**
  String paymentPay(String amount);

  /// No description provided for @paymentProcessing.
  ///
  /// In it, this message translates to:
  /// **'Elaborazione del pagamento…'**
  String get paymentProcessing;

  /// No description provided for @paymentFailed.
  ///
  /// In it, this message translates to:
  /// **'Pagamento non riuscito. Riprova.'**
  String get paymentFailed;

  /// No description provided for @orderPlacedTitle.
  ///
  /// In it, this message translates to:
  /// **'Ordine confermato'**
  String get orderPlacedTitle;

  /// No description provided for @orderPlacedBody.
  ///
  /// In it, this message translates to:
  /// **'Grazie! Il tuo ordine {number} è stato registrato.'**
  String orderPlacedBody(String number);

  /// No description provided for @ordersEmpty.
  ///
  /// In it, this message translates to:
  /// **'Non hai ancora ordini.'**
  String get ordersEmpty;

  /// No description provided for @orderNumberLabel.
  ///
  /// In it, this message translates to:
  /// **'Ordine {number}'**
  String orderNumberLabel(String number);

  /// No description provided for @orderItemsLabel.
  ///
  /// In it, this message translates to:
  /// **'Articoli'**
  String get orderItemsLabel;

  /// No description provided for @orderTrackingLabel.
  ///
  /// In it, this message translates to:
  /// **'Tracking'**
  String get orderTrackingLabel;

  /// No description provided for @orderCarrierLabel.
  ///
  /// In it, this message translates to:
  /// **'Corriere'**
  String get orderCarrierLabel;

  /// No description provided for @orderPaymentLabel.
  ///
  /// In it, this message translates to:
  /// **'Pagamento'**
  String get orderPaymentLabel;

  /// No description provided for @orderShippingLabel.
  ///
  /// In it, this message translates to:
  /// **'Spedizione'**
  String get orderShippingLabel;

  /// No description provided for @orderStatusCreated.
  ///
  /// In it, this message translates to:
  /// **'Creato'**
  String get orderStatusCreated;

  /// No description provided for @orderStatusConfirmed.
  ///
  /// In it, this message translates to:
  /// **'Confermato'**
  String get orderStatusConfirmed;

  /// No description provided for @orderStatusPreparing.
  ///
  /// In it, this message translates to:
  /// **'In preparazione'**
  String get orderStatusPreparing;

  /// No description provided for @orderStatusShipped.
  ///
  /// In it, this message translates to:
  /// **'Spedito'**
  String get orderStatusShipped;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In it, this message translates to:
  /// **'Consegnato'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In it, this message translates to:
  /// **'Annullato'**
  String get orderStatusCancelled;

  /// No description provided for @paymentStatusPending.
  ///
  /// In it, this message translates to:
  /// **'In attesa'**
  String get paymentStatusPending;

  /// No description provided for @paymentStatusPaid.
  ///
  /// In it, this message translates to:
  /// **'Pagato'**
  String get paymentStatusPaid;

  /// No description provided for @paymentStatusFailed.
  ///
  /// In it, this message translates to:
  /// **'Non riuscito'**
  String get paymentStatusFailed;

  /// No description provided for @paymentStatusRefunded.
  ///
  /// In it, this message translates to:
  /// **'Rimborsato'**
  String get paymentStatusRefunded;

  /// No description provided for @shippingStatusProcessing.
  ///
  /// In it, this message translates to:
  /// **'In lavorazione'**
  String get shippingStatusProcessing;

  /// No description provided for @shippingStatusShipped.
  ///
  /// In it, this message translates to:
  /// **'Spedito'**
  String get shippingStatusShipped;

  /// No description provided for @shippingStatusDelivered.
  ///
  /// In it, this message translates to:
  /// **'Consegnato'**
  String get shippingStatusDelivered;

  /// No description provided for @shippingStatusReturned.
  ///
  /// In it, this message translates to:
  /// **'Reso'**
  String get shippingStatusReturned;

  /// No description provided for @withdrawalAlreadyRequested.
  ///
  /// In it, this message translates to:
  /// **'Recesso già richiesto per questo ordine.'**
  String get withdrawalAlreadyRequested;

  /// No description provided for @signInToOrder.
  ///
  /// In it, this message translates to:
  /// **'Accedi per vedere i tuoi ordini.'**
  String get signInToOrder;

  /// No description provided for @genericErrorRetry.
  ///
  /// In it, this message translates to:
  /// **'Qualcosa è andato storto. Riprova.'**
  String get genericErrorRetry;

  /// No description provided for @adminNewProductTitle.
  ///
  /// In it, this message translates to:
  /// **'Nuovo prodotto'**
  String get adminNewProductTitle;

  /// No description provided for @adminEditProductTitle.
  ///
  /// In it, this message translates to:
  /// **'Modifica prodotto'**
  String get adminEditProductTitle;

  /// No description provided for @adminCatalogTitle.
  ///
  /// In it, this message translates to:
  /// **'Gestione catalogo'**
  String get adminCatalogTitle;

  /// No description provided for @adminProductNameIt.
  ///
  /// In it, this message translates to:
  /// **'Nome prodotto (IT)'**
  String get adminProductNameIt;

  /// No description provided for @adminProductNameEn.
  ///
  /// In it, this message translates to:
  /// **'Nome prodotto (EN)'**
  String get adminProductNameEn;

  /// No description provided for @adminProductType.
  ///
  /// In it, this message translates to:
  /// **'Tipo'**
  String get adminProductType;

  /// No description provided for @adminPriceList.
  ///
  /// In it, this message translates to:
  /// **'Prezzo di listino (centesimi)'**
  String get adminPriceList;

  /// No description provided for @adminPriceSale.
  ///
  /// In it, this message translates to:
  /// **'Prezzo scontato (centesimi, 0 = nessuno)'**
  String get adminPriceSale;

  /// No description provided for @adminVatRate.
  ///
  /// In it, this message translates to:
  /// **'Aliquota IVA (%)'**
  String get adminVatRate;

  /// No description provided for @adminStock.
  ///
  /// In it, this message translates to:
  /// **'Giacenza'**
  String get adminStock;

  /// No description provided for @adminAvailable.
  ///
  /// In it, this message translates to:
  /// **'Disponibile'**
  String get adminAvailable;

  /// No description provided for @adminAssistantEligible.
  ///
  /// In it, this message translates to:
  /// **'Suggeribile dall\'assistente AI'**
  String get adminAssistantEligible;

  /// No description provided for @adminAssistantEligibleHint.
  ///
  /// In it, this message translates to:
  /// **'Se disattivato, l\'assistente non proporrà mai questo prodotto (§12.3).'**
  String get adminAssistantEligibleHint;

  /// No description provided for @adminCeMarking.
  ///
  /// In it, this message translates to:
  /// **'Marcatura CE (dispositivi)'**
  String get adminCeMarking;

  /// No description provided for @adminPickImage.
  ///
  /// In it, this message translates to:
  /// **'Scegli foto'**
  String get adminPickImage;

  /// No description provided for @adminTakePhoto.
  ///
  /// In it, this message translates to:
  /// **'Scatta foto'**
  String get adminTakePhoto;

  /// No description provided for @adminImageSelected.
  ///
  /// In it, this message translates to:
  /// **'Immagine pronta al caricamento'**
  String get adminImageSelected;

  /// No description provided for @adminCreateDraft.
  ///
  /// In it, this message translates to:
  /// **'Crea bozza'**
  String get adminCreateDraft;

  /// No description provided for @adminDraftCreated.
  ///
  /// In it, this message translates to:
  /// **'Bozza creata'**
  String get adminDraftCreated;

  /// No description provided for @adminSave.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get adminSave;

  /// No description provided for @adminSaved.
  ///
  /// In it, this message translates to:
  /// **'Modifiche salvate'**
  String get adminSaved;

  /// No description provided for @adminGenerateTexts.
  ///
  /// In it, this message translates to:
  /// **'Genera testi con AI'**
  String get adminGenerateTexts;

  /// No description provided for @adminGeneratingTexts.
  ///
  /// In it, this message translates to:
  /// **'Generazione in corso…'**
  String get adminGeneratingTexts;

  /// No description provided for @adminTextsGenerated.
  ///
  /// In it, this message translates to:
  /// **'Testi generati — da revisionare'**
  String get adminTextsGenerated;

  /// No description provided for @adminAiGeneratedBadge.
  ///
  /// In it, this message translates to:
  /// **'AI'**
  String get adminAiGeneratedBadge;

  /// No description provided for @adminAiImageStatusLabel.
  ///
  /// In it, this message translates to:
  /// **'Immagine AI'**
  String get adminAiImageStatusLabel;

  /// No description provided for @adminReviewNote.
  ///
  /// In it, this message translates to:
  /// **'Revisiona posologia e controindicazioni (IT+EN) prima di pubblicare.'**
  String get adminReviewNote;

  /// No description provided for @adminPublish.
  ///
  /// In it, this message translates to:
  /// **'Pubblica'**
  String get adminPublish;

  /// No description provided for @adminPublished.
  ///
  /// In it, this message translates to:
  /// **'Prodotto pubblicato'**
  String get adminPublished;

  /// No description provided for @adminCannotPublishMedicine.
  ///
  /// In it, this message translates to:
  /// **'Per pubblicare un medicinale servono posologia e controindicazioni in IT ed EN.'**
  String get adminCannotPublishMedicine;

  /// No description provided for @adminUnpublish.
  ///
  /// In it, this message translates to:
  /// **'Riporta in bozza'**
  String get adminUnpublish;

  /// No description provided for @adminArchive.
  ///
  /// In it, this message translates to:
  /// **'Archivia'**
  String get adminArchive;

  /// No description provided for @adminArchived.
  ///
  /// In it, this message translates to:
  /// **'Prodotto archiviato'**
  String get adminArchived;

  /// No description provided for @adminFieldShortDescription.
  ///
  /// In it, this message translates to:
  /// **'Descrizione breve'**
  String get adminFieldShortDescription;

  /// No description provided for @adminFieldDescription.
  ///
  /// In it, this message translates to:
  /// **'Descrizione'**
  String get adminFieldDescription;

  /// No description provided for @adminFieldActiveIngredient.
  ///
  /// In it, this message translates to:
  /// **'Principio attivo'**
  String get adminFieldActiveIngredient;

  /// No description provided for @adminFieldPosology.
  ///
  /// In it, this message translates to:
  /// **'Posologia'**
  String get adminFieldPosology;

  /// No description provided for @adminFieldContraindications.
  ///
  /// In it, this message translates to:
  /// **'Controindicazioni'**
  String get adminFieldContraindications;

  /// No description provided for @adminFieldWarnings.
  ///
  /// In it, this message translates to:
  /// **'Avvertenze'**
  String get adminFieldWarnings;

  /// No description provided for @adminSectionBasics.
  ///
  /// In it, this message translates to:
  /// **'Dati di base'**
  String get adminSectionBasics;

  /// No description provided for @adminSectionTexts.
  ///
  /// In it, this message translates to:
  /// **'Contenuti (IT / EN)'**
  String get adminSectionTexts;

  /// No description provided for @adminSectionPublish.
  ///
  /// In it, this message translates to:
  /// **'Pubblicazione'**
  String get adminSectionPublish;

  /// No description provided for @adminNoProducts.
  ///
  /// In it, this message translates to:
  /// **'Nessun prodotto. Creane uno con \"Aggiungi prodotto\".'**
  String get adminNoProducts;

  /// No description provided for @adminReviewedBy.
  ///
  /// In it, this message translates to:
  /// **'Approvato da {uid}'**
  String adminReviewedBy(String uid);

  /// No description provided for @productTypeSop.
  ///
  /// In it, this message translates to:
  /// **'Medicinale SOP'**
  String get productTypeSop;

  /// No description provided for @productTypeOtc.
  ///
  /// In it, this message translates to:
  /// **'Medicinale OTC'**
  String get productTypeOtc;

  /// No description provided for @productTypeParafarmaco.
  ///
  /// In it, this message translates to:
  /// **'Parafarmaco'**
  String get productTypeParafarmaco;

  /// No description provided for @productTypeIntegratore.
  ///
  /// In it, this message translates to:
  /// **'Integratore'**
  String get productTypeIntegratore;

  /// No description provided for @productTypeCosmetico.
  ///
  /// In it, this message translates to:
  /// **'Cosmetico'**
  String get productTypeCosmetico;

  /// No description provided for @productTypeDispositivoMedico.
  ///
  /// In it, this message translates to:
  /// **'Dispositivo medico'**
  String get productTypeDispositivoMedico;

  /// No description provided for @statusDraft.
  ///
  /// In it, this message translates to:
  /// **'Bozza'**
  String get statusDraft;

  /// No description provided for @statusPendingReview.
  ///
  /// In it, this message translates to:
  /// **'Da revisionare'**
  String get statusPendingReview;

  /// No description provided for @statusPublished.
  ///
  /// In it, this message translates to:
  /// **'Pubblicato'**
  String get statusPublished;

  /// No description provided for @statusArchived.
  ///
  /// In it, this message translates to:
  /// **'Archiviato'**
  String get statusArchived;
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
