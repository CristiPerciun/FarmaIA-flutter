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
  String get adminAssistantTitle => 'Assistente AI — supervisione';

  @override
  String get adminAssistantSubtitle =>
      'Registro conversazioni, escalation, red-flag';

  @override
  String get adminAssistantGuardrails => 'Liste red-flag e ricetta';

  @override
  String get adminAssistantNoSessions => 'Nessuna conversazione registrata.';

  @override
  String get adminAssistantFilterAll => 'Tutte';

  @override
  String get adminAssistantFilterRedFlag => 'Red-flag';

  @override
  String get adminAssistantFilterFlagged => 'Segnalate';

  @override
  String get adminAssistantFilterEscalations => 'Escalation da gestire';

  @override
  String get adminAssistantUser => 'Utente';

  @override
  String get adminAssistantTurns => 'turni';

  @override
  String get adminAssistantTagRedFlag => 'RED-FLAG';

  @override
  String get adminAssistantTagFlagged => 'SEGNALATA';

  @override
  String get adminAssistantTagEscalated => 'ESCALATION';

  @override
  String get adminAssistantSession => 'Conversazione';

  @override
  String get adminAssistantFlagWrong => 'Risposta scorretta';

  @override
  String get adminAssistantUnflag => 'Rimuovi segnalazione';

  @override
  String get adminAssistantMarkHandled => 'Escalation gestita';

  @override
  String get adminAssistantReviewNote => 'Nota di revisione';

  @override
  String get adminAssistantReviewNoteHint =>
      'Cosa c\'era di sbagliato? (alimenta la revisione di prompt e red-flag)';

  @override
  String get adminAssistantRedFlagList =>
      'Red-flag aggiuntive (della farmacia)';

  @override
  String get adminAssistantRxList => 'Termini con ricetta aggiuntivi';

  @override
  String get adminAssistantAddTerm => 'Aggiungi termine…';

  @override
  String get adminAssistantBuiltinNote =>
      'Le liste di base integrate nel sistema restano sempre attive: qui aggiungi solo termini specifici della farmacia. Le modifiche valgono dal prossimo messaggio, senza deploy.';

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
  String get searchAssistantHint => 'Cerca un prodotto o chiedi un consiglio…';

  @override
  String get assistantTitle => 'Assistente';

  @override
  String get assistantBridgeNote =>
      'L\'assistente conversazionale AI arriva presto. Per ora ti mostro i prodotti che corrispondono alla ricerca.';

  @override
  String get assistantEmptyPrompt =>
      'Scrivi il nome di un prodotto o un principio attivo per cercarlo nel catalogo.';

  @override
  String get assistantQuickChipHeadache => 'Mal di testa';

  @override
  String get assistantQuickChipCold => 'Raffreddore';

  @override
  String get assistantQuickChipSkin => 'Consiglio pelle';

  @override
  String get assistantQuickChipPharmacist => 'Parla col farmacista';

  @override
  String get assistantBadgeAi => 'AI';

  @override
  String get assistantDisclaimer =>
      'Non sono un medico né un farmacista. Per casi seri rivolgiti al 112 o al tuo medico.';

  @override
  String get assistantWelcome =>
      'Ciao! Dimmi cosa ti serve o descrivi un piccolo disturbo: ti propongo prodotti dal nostro catalogo.';

  @override
  String get assistantInputHint => 'Scrivi un messaggio…';

  @override
  String get assistantSend => 'Invia';

  @override
  String get assistantNewConversation => 'Nuova conversazione';

  @override
  String get assistantPanelTitle => 'Assistente AI';

  @override
  String get assistantClose => 'Chiudi';

  @override
  String get assistantPillLabel =>
      'Sono il tuo assistente AI: dimmi cosa ti fa male o cosa cerchi';

  @override
  String get assistantTalkToPharmacist => 'Parla con il farmacista';

  @override
  String get assistantEscalationSent =>
      'Richiesta inviata: un farmacista ti risponderà al più presto.';

  @override
  String get assistantRedFlagHint =>
      'Caso serio: rivolgiti a un professionista';

  @override
  String get assistantRouterIntro => 'Trovato nel catalogo:';

  @override
  String get assistantOfflineFallback =>
      'Non riesco a contattare l\'assistente. Ecco alcuni risultati dal catalogo; per un consiglio scrivi al farmacista.';

  @override
  String get assistantDailyLimit =>
      'Hai raggiunto il limite giornaliero di messaggi. Riprova domani.';

  @override
  String get assistantSessionLimit =>
      'Questa conversazione è troppo lunga: iniziane una nuova.';

  @override
  String get assistantErrorGeneric => 'Qualcosa è andato storto. Riprova.';

  @override
  String get assistantOfflineBanner =>
      'Sei offline: ricerca sul catalogo salvato, senza assistente.';

  @override
  String get assistantResultsOnlyBanner =>
      'Assistente disattivato: vedi solo i risultati di ricerca.';

  @override
  String get assistantUnavailableBanner =>
      'L\'assistente non è al momento disponibile: ecco la ricerca classica.';

  @override
  String get assistantEnableCta => 'Attiva';

  @override
  String get assistantOnboardingTitle => 'Il tuo assistente AI';

  @override
  String get assistantDoes1 =>
      'Ti suggerisce prodotti da banco del nostro catalogo, come farebbe un commesso esperto.';

  @override
  String get assistantDoes2 =>
      'Riconosce i casi seri e ti indirizza subito a medico, 112 o farmacista.';

  @override
  String get assistantDoes3 =>
      'Ha sempre il farmacista al tuo fianco: puoi chiamarlo in ogni momento.';

  @override
  String get assistantDoesnt1 =>
      'Non fa diagnosi e non sostituisce il medico o il farmacista.';

  @override
  String get assistantDoesnt2 =>
      'Non consiglia farmaci con obbligo di ricetta né dosaggi fuori scheda.';

  @override
  String get assistantConsentTitle =>
      'Consenso ai dati sulla salute (art. 9 GDPR)';

  @override
  String get assistantConsentBody =>
      'Quello che scrivi in chat può includere dati sulla salute. Con il tuo consenso viene inviato al nostro assistente su server in UE, usato solo per suggerirti prodotti e conservato al massimo 90 giorni. Puoi revocare il consenso quando vuoi dal profilo; senza consenso resta attiva la ricerca classica.';

  @override
  String get assistantConsentAccept => 'Accetto e inizio';

  @override
  String get assistantConsentDecline => 'Non ora: solo risultati';

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

  @override
  String get adminNewProductTitle => 'Nuovo prodotto';

  @override
  String get adminEditProductTitle => 'Modifica prodotto';

  @override
  String get adminCatalogTitle => 'Gestione catalogo';

  @override
  String get adminProductNameIt => 'Nome prodotto (IT)';

  @override
  String get adminProductNameEn => 'Nome prodotto (EN)';

  @override
  String get adminProductType => 'Tipo';

  @override
  String get adminPriceList => 'Prezzo di listino (centesimi)';

  @override
  String get adminPriceSale => 'Prezzo scontato (centesimi, 0 = nessuno)';

  @override
  String get adminVatRate => 'Aliquota IVA (%)';

  @override
  String get adminStock => 'Giacenza';

  @override
  String get adminAvailable => 'Disponibile';

  @override
  String get adminAssistantEligible => 'Suggeribile dall\'assistente AI';

  @override
  String get adminAssistantEligibleHint =>
      'Se disattivato, l\'assistente non proporrà mai questo prodotto (§12.3).';

  @override
  String get adminCeMarking => 'Marcatura CE (dispositivi)';

  @override
  String get adminPickImage => 'Scegli foto';

  @override
  String get adminTakePhoto => 'Scatta foto';

  @override
  String get adminImageSelected => 'Immagine pronta al caricamento';

  @override
  String get adminCreateDraft => 'Crea bozza';

  @override
  String get adminDraftCreated => 'Bozza creata';

  @override
  String get adminSave => 'Salva';

  @override
  String get adminSaved => 'Modifiche salvate';

  @override
  String get adminGenerateTexts => 'Genera testi con AI';

  @override
  String get adminGeneratingTexts => 'Generazione in corso…';

  @override
  String get adminTextsGenerated => 'Testi generati — da revisionare';

  @override
  String get adminAiGeneratedBadge => 'AI';

  @override
  String get adminAiImageStatusLabel => 'Immagine AI';

  @override
  String get adminReviewNote =>
      'Revisiona posologia e controindicazioni (IT+EN) prima di pubblicare.';

  @override
  String get adminPublish => 'Pubblica';

  @override
  String get adminPublished => 'Prodotto pubblicato';

  @override
  String get adminCannotPublishMedicine =>
      'Per pubblicare un medicinale servono posologia e controindicazioni in IT ed EN.';

  @override
  String get adminUnpublish => 'Riporta in bozza';

  @override
  String get adminArchive => 'Archivia';

  @override
  String get adminArchived => 'Prodotto archiviato';

  @override
  String get adminFieldShortDescription => 'Descrizione breve';

  @override
  String get adminFieldDescription => 'Descrizione';

  @override
  String get adminFieldActiveIngredient => 'Principio attivo';

  @override
  String get adminFieldPosology => 'Posologia';

  @override
  String get adminFieldContraindications => 'Controindicazioni';

  @override
  String get adminFieldWarnings => 'Avvertenze';

  @override
  String get adminSectionBasics => 'Dati di base';

  @override
  String get adminSectionTexts => 'Contenuti (IT / EN)';

  @override
  String get adminSectionPublish => 'Pubblicazione';

  @override
  String get adminNoProducts =>
      'Nessun prodotto. Creane uno con \"Aggiungi prodotto\".';

  @override
  String adminReviewedBy(String uid) {
    return 'Approvato da $uid';
  }

  @override
  String get productTypeSop => 'Medicinale SOP';

  @override
  String get productTypeOtc => 'Medicinale OTC';

  @override
  String get productTypeParafarmaco => 'Parafarmaco';

  @override
  String get productTypeIntegratore => 'Integratore';

  @override
  String get productTypeCosmetico => 'Cosmetico';

  @override
  String get productTypeDispositivoMedico => 'Dispositivo medico';

  @override
  String get statusDraft => 'Bozza';

  @override
  String get statusPendingReview => 'Da revisionare';

  @override
  String get statusPublished => 'Pubblicato';

  @override
  String get statusArchived => 'Archiviato';
}
