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

  @override
  String get navHome => 'Home';

  @override
  String get navShop => 'Negozio';

  @override
  String get navChatAi => 'Chat AI';

  @override
  String get navCart => 'Carrello';

  @override
  String get navProfile => 'Profilo';

  @override
  String get catalogAllCategories => 'Tutti';

  @override
  String get catalogFilters => 'Filtri';

  @override
  String get catalogFilterCategory => 'Categoria';

  @override
  String get catalogFilterMedicinesOnly => 'Solo medicinali';

  @override
  String get catalogFilterOnSale => 'In offerta';

  @override
  String get catalogClearFilters => 'Azzera filtri';

  @override
  String get catalogApplyFilters => 'Applica';

  @override
  String get catalogNoProducts => 'Nessun prodotto trovato';

  @override
  String get catalogEmptyHint =>
      'Prova a rimuovere qualche filtro o a cambiare ricerca.';

  @override
  String catalogResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prodotti',
      one: '1 prodotto',
      zero: 'Nessun prodotto',
    );
    return '$_temp0';
  }

  @override
  String get catalogLoadError => 'Impossibile caricare il catalogo.';

  @override
  String get productAddToCart => 'Aggiungi';

  @override
  String get addToCartComingSoon => 'Il carrello arriva nella Fase 3.';

  @override
  String priceWas(String price) {
    return 'Prezzo di listino $price';
  }

  @override
  String get productDescription => 'Descrizione';

  @override
  String get productActiveIngredient => 'Principio attivo';

  @override
  String get productPosology => 'Posologia';

  @override
  String get productContraindications => 'Controindicazioni';

  @override
  String get productWarnings => 'Avvertenze';

  @override
  String get productCeMarking => 'Marcatura CE';

  @override
  String get productCeMarkingPresent => 'Dispositivo medico con marcatura CE.';

  @override
  String get productNotFound => 'Prodotto non disponibile.';

  @override
  String get trustReturnsTitle => 'Reso e recesso';

  @override
  String get trustReturnsBody =>
      'Diritto di recesso entro 14 giorni (art. 54-bis). I medicinali seguono le limitazioni di legge.';

  @override
  String get searchTitle => 'Cerca';

  @override
  String get searchHint => 'Cerca prodotti, principi attivi…';

  @override
  String searchNoResults(String query) {
    return 'Nessun risultato per \"$query\"';
  }

  @override
  String get searchClear => 'Cancella';

  @override
  String get scanTitle => 'Scansiona codice';

  @override
  String get scanInstruction =>
      'Inquadra il codice a barre (EAN) del prodotto.';

  @override
  String get scanManualTitle => 'Inserisci il codice';

  @override
  String get scanManualHint => 'Codice EAN';

  @override
  String get scanManualSubmit => 'Cerca';

  @override
  String get scanNotSupported =>
      'La fotocamera non è disponibile su questo dispositivo. Inserisci il codice a mano.';

  @override
  String get scanPermissionDenied =>
      'Permesso fotocamera negato. Puoi inserire il codice a mano.';

  @override
  String scanNotFound(String code) {
    return 'Nessun prodotto con codice $code.';
  }

  @override
  String get offlineBannerTitle => 'Sei offline';

  @override
  String get offlineBannerBody =>
      'Stai consultando il catalogo salvato. Alcune azioni non sono disponibili senza rete.';

  @override
  String get offlineActionDisabled => 'Azione non disponibile offline.';

  @override
  String get cartTitle => 'Carrello';

  @override
  String get cartEmpty => 'Il carrello è vuoto';

  @override
  String get cartEmptyHint => 'Aggiungi prodotti dal negozio.';

  @override
  String get cartRemove => 'Rimuovi';

  @override
  String get cartCheckout => 'Vai al checkout';

  @override
  String get cartItemUnavailable => 'Non più disponibile';

  @override
  String get addedToCart => 'Aggiunto al carrello';

  @override
  String get cartQuantity => 'Quantità';

  @override
  String get summarySubtotal => 'Subtotale';

  @override
  String get summaryShipping => 'Spedizione';

  @override
  String get summaryShippingFree => 'Gratuita';

  @override
  String get summaryVat => 'IVA (inclusa)';

  @override
  String summaryVatRate(int rate) {
    return 'di cui IVA $rate%';
  }

  @override
  String get summaryTotal => 'Totale';

  @override
  String summaryFreeShippingHint(String amount) {
    return 'Aggiungi $amount per la spedizione gratuita.';
  }

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get checkoutContact => 'Contatti';

  @override
  String get checkoutGuestNote =>
      'Puoi ordinare come ospite; creare un account è facoltativo.';

  @override
  String get checkoutShippingAddress => 'Indirizzo di spedizione';

  @override
  String get fieldFullName => 'Nome e cognome';

  @override
  String get fieldPhone => 'Telefono';

  @override
  String get fieldStreet => 'Indirizzo (via e numero)';

  @override
  String get fieldCity => 'Città';

  @override
  String get fieldZip => 'CAP';

  @override
  String get fieldProvince => 'Provincia';

  @override
  String get checkoutContinueToPayment => 'Vai al pagamento';

  @override
  String get paymentTitle => 'Pagamento';

  @override
  String get paymentMethod => 'Metodo di pagamento';

  @override
  String get paymentMethodCard => 'Carta (Stripe/Nexi)';

  @override
  String get paymentMethodPaypal => 'PayPal';

  @override
  String get paymentMethodSatispay => 'Satispay';

  @override
  String get paymentMethodBnpl => 'Paga a rate (Scalapay/Klarna)';

  @override
  String get paymentSandboxNotice =>
      'Ambiente sandbox: nessun addebito reale. L\'integrazione dei gateway di pagamento reali è descritta nell\'ADR 0003.';

  @override
  String paymentPay(String amount) {
    return 'Paga $amount';
  }

  @override
  String get paymentProcessing => 'Elaborazione del pagamento…';

  @override
  String get paymentFailed => 'Pagamento non riuscito. Riprova.';

  @override
  String get orderPlacedTitle => 'Ordine confermato';

  @override
  String orderPlacedBody(String number) {
    return 'Grazie! Il tuo ordine $number è stato registrato.';
  }

  @override
  String get ordersEmpty => 'Non hai ancora ordini.';

  @override
  String orderNumberLabel(String number) {
    return 'Ordine $number';
  }

  @override
  String get orderItemsLabel => 'Articoli';

  @override
  String get orderTrackingLabel => 'Tracking';

  @override
  String get orderCarrierLabel => 'Corriere';

  @override
  String get orderPaymentLabel => 'Pagamento';

  @override
  String get orderShippingLabel => 'Spedizione';

  @override
  String get orderStatusCreated => 'Creato';

  @override
  String get orderStatusConfirmed => 'Confermato';

  @override
  String get orderStatusPreparing => 'In preparazione';

  @override
  String get orderStatusShipped => 'Spedito';

  @override
  String get orderStatusDelivered => 'Consegnato';

  @override
  String get orderStatusCancelled => 'Annullato';

  @override
  String get paymentStatusPending => 'In attesa';

  @override
  String get paymentStatusPaid => 'Pagato';

  @override
  String get paymentStatusFailed => 'Non riuscito';

  @override
  String get paymentStatusRefunded => 'Rimborsato';

  @override
  String get shippingStatusProcessing => 'In lavorazione';

  @override
  String get shippingStatusShipped => 'Spedito';

  @override
  String get shippingStatusDelivered => 'Consegnato';

  @override
  String get shippingStatusReturned => 'Reso';

  @override
  String get withdrawalAlreadyRequested =>
      'Recesso già richiesto per questo ordine.';

  @override
  String get signInToOrder => 'Accedi per vedere i tuoi ordini.';

  @override
  String get genericErrorRetry => 'Qualcosa è andato storto. Riprova.';
}
