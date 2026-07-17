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

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create an account';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get displayNameLabel => 'Name';

  @override
  String get fieldRequired => 'Required field';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get authErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get authErrorInvalidCredentials => 'Incorrect email or password.';

  @override
  String get authErrorTooManyRequests => 'Too many attempts. Try again later.';

  @override
  String get authErrorEmailInUse =>
      'An account with this email already exists.';

  @override
  String get authErrorAccountExists =>
      'An account already exists with this email using a different sign-in method. Please sign in with your email and password.';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get orSeparator => 'or';

  @override
  String get profileTitle => 'Profile';

  @override
  String get guestProfileMessage =>
      'Sign in or register to manage orders, addresses and consents.';

  @override
  String get signOut => 'Sign out';

  @override
  String get viewModeLabel => 'View';

  @override
  String get viewAsCustomer => 'Customer';

  @override
  String get viewAsAdmin => 'Admin';

  @override
  String get roleCustomer => 'Customer';

  @override
  String get rolePharmacist => 'Pharmacist';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get ordersTitle => 'My orders';

  @override
  String get comingSoonPhase3 => 'Available in Phase 3';

  @override
  String get comingSoonPhase4 => 'Available in Phase 4';

  @override
  String get adminAreaTitle => 'Admin area';

  @override
  String adminWelcome(String name) {
    return 'Welcome, $name';
  }

  @override
  String get adminAddProduct => 'Add product (AI)';

  @override
  String get adminManageCatalog => 'Manage catalog';

  @override
  String get adminManageOrders => 'Manage orders';

  @override
  String get adminAssistantTitle => 'AI assistant — supervision';

  @override
  String get adminAssistantSubtitle =>
      'Conversation registry, escalations, red flags';

  @override
  String get adminAssistantGuardrails => 'Red-flag and Rx lists';

  @override
  String get adminAssistantNoSessions => 'No conversations recorded.';

  @override
  String get adminAssistantFilterAll => 'All';

  @override
  String get adminAssistantFilterRedFlag => 'Red-flag';

  @override
  String get adminAssistantFilterFlagged => 'Flagged';

  @override
  String get adminAssistantFilterEscalations => 'Pending escalations';

  @override
  String get adminAssistantUser => 'User';

  @override
  String get adminAssistantTurns => 'turns';

  @override
  String get adminAssistantTagRedFlag => 'RED-FLAG';

  @override
  String get adminAssistantTagFlagged => 'FLAGGED';

  @override
  String get adminAssistantTagEscalated => 'ESCALATION';

  @override
  String get adminAssistantSession => 'Conversation';

  @override
  String get adminAssistantFlagWrong => 'Wrong answer';

  @override
  String get adminAssistantUnflag => 'Remove flag';

  @override
  String get adminAssistantMarkHandled => 'Escalation handled';

  @override
  String get adminAssistantReviewNote => 'Review note';

  @override
  String get adminAssistantReviewNoteHint =>
      'What was wrong? (feeds prompt and red-flag revision)';

  @override
  String get adminAssistantRedFlagList =>
      'Extra red-flag terms (pharmacy\'s own)';

  @override
  String get adminAssistantRxList => 'Extra prescription terms';

  @override
  String get adminAssistantAddTerm => 'Add term…';

  @override
  String get adminAssistantBuiltinNote =>
      'The built-in baseline lists always stay active: here you only add pharmacy-specific terms. Changes apply from the next message, no deploy needed.';

  @override
  String get consentsTitle => 'Consents & privacy';

  @override
  String get consentsIntro =>
      'Manage your consents. You can change or withdraw them at any time.';

  @override
  String get consentsSaved => 'Consents updated';

  @override
  String get saveConsents => 'Save consents';

  @override
  String get consentMarketingTitle => 'Marketing communications';

  @override
  String get consentMarketingBody => 'Receive offers and news by email.';

  @override
  String get consentMedicineDataTitle => 'Medicine data processing';

  @override
  String get consentMedicineDataBody =>
      'Required to order SOP/OTC medicines (health data).';

  @override
  String get consentAiAssistantTitle => 'AI assistant (health data)';

  @override
  String get consentAiAssistantBody =>
      'Explicit consent to process symptoms typed into the chat (GDPR Art. 9).';

  @override
  String get ministerialLogoTitle => 'Online sale of medicines';

  @override
  String get ministerialLogoSemantics =>
      'National identifying logo for the online sale of medicines';

  @override
  String get ministerialLogoAuthorized =>
      'Pharmacy authorized by the Ministry of Health.';

  @override
  String get ministerialLogoPending =>
      'Ministry authorization to be confirmed before selling.';

  @override
  String get cookieBannerTitle => 'Cookies & privacy';

  @override
  String get cookieBannerBody =>
      'We use technical cookies and, with your consent, analytics cookies to improve the service.';

  @override
  String get cookieAccept => 'Accept all';

  @override
  String get cookieReject => 'Essential only';

  @override
  String get withdrawalButton => 'Request withdrawal';

  @override
  String get withdrawalConfirm => 'Confirm withdrawal';

  @override
  String get withdrawalConfirmBody =>
      'Do you want to exercise the right of withdrawal for this order (art. 54-bis)? The request will be recorded.';

  @override
  String get withdrawalRequested =>
      'Withdrawal requested. We\'ll contact you to complete the process.';

  @override
  String get cancel => 'Cancel';

  @override
  String get navHome => 'Home';

  @override
  String get navShop => 'Shop';

  @override
  String get navChatAi => 'AI Chat';

  @override
  String get navCart => 'Cart';

  @override
  String get navProfile => 'Profile';

  @override
  String get catalogAllCategories => 'All';

  @override
  String get catalogFilters => 'Filters';

  @override
  String get catalogFilterCategory => 'Category';

  @override
  String get catalogFilterMedicinesOnly => 'Medicines only';

  @override
  String get catalogFilterOnSale => 'On sale';

  @override
  String get catalogClearFilters => 'Clear filters';

  @override
  String get catalogApplyFilters => 'Apply';

  @override
  String get catalogNoProducts => 'No products found';

  @override
  String get catalogEmptyHint =>
      'Try removing a filter or changing your search.';

  @override
  String catalogResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '1 product',
      zero: 'No products',
    );
    return '$_temp0';
  }

  @override
  String get catalogLoadError => 'Could not load the catalog.';

  @override
  String get productAddToCart => 'Add';

  @override
  String get addToCartComingSoon => 'The cart arrives in Phase 3.';

  @override
  String priceWas(String price) {
    return 'List price $price';
  }

  @override
  String get productDescription => 'Description';

  @override
  String get productActiveIngredient => 'Active ingredient';

  @override
  String get productPosology => 'Posology';

  @override
  String get productContraindications => 'Contraindications';

  @override
  String get productWarnings => 'Warnings';

  @override
  String get productCeMarking => 'CE marking';

  @override
  String get productCeMarkingPresent => 'Medical device with CE marking.';

  @override
  String get productNotFound => 'Product not available.';

  @override
  String get trustReturnsTitle => 'Returns & withdrawal';

  @override
  String get trustReturnsBody =>
      'Right of withdrawal within 14 days (art. 54-bis). Medicines follow statutory limitations.';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchHint => 'Search products, active ingredients…';

  @override
  String get searchAssistantHint => 'Search a product or ask for advice…';

  @override
  String get assistantTitle => 'Assistant';

  @override
  String get assistantBridgeNote =>
      'The conversational AI assistant is coming soon. For now, here are the products matching your search.';

  @override
  String get assistantEmptyPrompt =>
      'Type a product name or active ingredient to search the catalog.';

  @override
  String get assistantQuickChipHeadache => 'Headache';

  @override
  String get assistantQuickChipCold => 'Cold';

  @override
  String get assistantQuickChipSkin => 'Skin advice';

  @override
  String get assistantQuickChipPharmacist => 'Talk to the pharmacist';

  @override
  String get assistantBadgeAi => 'AI';

  @override
  String get assistantDisclaimer =>
      'I\'m not a doctor or a pharmacist. For serious cases contact 112 or your doctor.';

  @override
  String get assistantWelcome =>
      'Hi! Tell me what you need or describe a minor ailment: I\'ll suggest products from our catalog.';

  @override
  String get assistantInputHint => 'Type a message…';

  @override
  String get assistantSend => 'Send';

  @override
  String get assistantNewConversation => 'New conversation';

  @override
  String get assistantPanelTitle => 'AI assistant';

  @override
  String get assistantClose => 'Close';

  @override
  String get assistantPillLabel =>
      'I\'m your AI assistant: tell me what hurts or what you\'re looking for';

  @override
  String get assistantTalkToPharmacist => 'Talk to the pharmacist';

  @override
  String get assistantEscalationSent =>
      'Request sent: a pharmacist will get back to you shortly.';

  @override
  String get assistantRedFlagHint => 'Serious case: see a professional';

  @override
  String get assistantRouterIntro => 'Found in the catalog:';

  @override
  String get assistantOfflineFallback =>
      'I can\'t reach the assistant. Here are some catalog results; for advice contact the pharmacist.';

  @override
  String get assistantDailyLimit =>
      'You\'ve reached the daily message limit. Try again tomorrow.';

  @override
  String get assistantSessionLimit =>
      'This conversation is too long: start a new one.';

  @override
  String get assistantErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get assistantOfflineBanner =>
      'You\'re offline: searching the saved catalog, without the assistant.';

  @override
  String get assistantResultsOnlyBanner =>
      'Assistant off: you\'re seeing search results only.';

  @override
  String get assistantUnavailableBanner =>
      'The assistant is currently unavailable: here is the classic search.';

  @override
  String get assistantEnableCta => 'Enable';

  @override
  String get assistantOnboardingTitle => 'Your AI assistant';

  @override
  String get assistantDoes1 =>
      'Suggests over-the-counter products from our catalog, like an expert shop assistant would.';

  @override
  String get assistantDoes2 =>
      'Recognises serious cases and points you straight to a doctor, 112 or the pharmacist.';

  @override
  String get assistantDoes3 =>
      'Always has the pharmacist by your side: you can call them at any time.';

  @override
  String get assistantDoesnt1 =>
      'Doesn\'t diagnose and doesn\'t replace your doctor or pharmacist.';

  @override
  String get assistantDoesnt2 =>
      'Doesn\'t recommend prescription medicines or dosages beyond the leaflet.';

  @override
  String get assistantConsentTitle => 'Health-data consent (GDPR art. 9)';

  @override
  String get assistantConsentBody =>
      'What you type in the chat may include health data. With your consent it is sent to our assistant on EU servers, used only to suggest products, and kept for at most 90 days. You can withdraw consent at any time from your profile; without it, the classic search stays available.';

  @override
  String get assistantConsentAccept => 'Accept and start';

  @override
  String get assistantConsentDecline => 'Not now: results only';

  @override
  String searchNoResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get searchClear => 'Clear';

  @override
  String get scanTitle => 'Scan code';

  @override
  String get scanInstruction =>
      'Point the camera at the product barcode (EAN).';

  @override
  String get scanManualTitle => 'Enter the code';

  @override
  String get scanManualHint => 'EAN code';

  @override
  String get scanManualSubmit => 'Search';

  @override
  String get scanNotSupported =>
      'The camera is not available on this device. Enter the code manually.';

  @override
  String get scanPermissionDenied =>
      'Camera permission denied. You can enter the code manually.';

  @override
  String scanNotFound(String code) {
    return 'No product with code $code.';
  }

  @override
  String get offlineBannerTitle => 'You\'re offline';

  @override
  String get offlineBannerBody =>
      'You\'re browsing the saved catalog. Some actions are unavailable without a connection.';

  @override
  String get offlineActionDisabled => 'Action unavailable offline.';

  @override
  String get cartTitle => 'Cart';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get cartEmptyHint => 'Add products from the shop.';

  @override
  String get cartRemove => 'Remove';

  @override
  String get cartCheckout => 'Go to checkout';

  @override
  String get cartItemUnavailable => 'No longer available';

  @override
  String get addedToCart => 'Added to cart';

  @override
  String get cartQuantity => 'Quantity';

  @override
  String get summarySubtotal => 'Subtotal';

  @override
  String get summaryShipping => 'Shipping';

  @override
  String get summaryShippingFree => 'Free';

  @override
  String get summaryVat => 'VAT (included)';

  @override
  String summaryVatRate(int rate) {
    return 'incl. VAT $rate%';
  }

  @override
  String get summaryTotal => 'Total';

  @override
  String summaryFreeShippingHint(String amount) {
    return 'Add $amount for free shipping.';
  }

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get checkoutContact => 'Contact';

  @override
  String get checkoutGuestNote =>
      'You can order as a guest; creating an account is optional.';

  @override
  String get checkoutShippingAddress => 'Shipping address';

  @override
  String get fieldFullName => 'Full name';

  @override
  String get fieldPhone => 'Phone';

  @override
  String get fieldStreet => 'Address (street and number)';

  @override
  String get fieldCity => 'City';

  @override
  String get fieldZip => 'Postcode';

  @override
  String get fieldProvince => 'Province';

  @override
  String get checkoutContinueToPayment => 'Continue to payment';

  @override
  String get paymentTitle => 'Payment';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get paymentMethodCard => 'Card (Stripe/Nexi)';

  @override
  String get paymentMethodPaypal => 'PayPal';

  @override
  String get paymentMethodSatispay => 'Satispay';

  @override
  String get paymentMethodBnpl => 'Pay in instalments (Scalapay/Klarna)';

  @override
  String get paymentSandboxNotice =>
      'Sandbox environment: no real charge. Real payment-gateway integration is described in ADR 0003.';

  @override
  String paymentPay(String amount) {
    return 'Pay $amount';
  }

  @override
  String get paymentProcessing => 'Processing payment…';

  @override
  String get paymentFailed => 'Payment failed. Please try again.';

  @override
  String get orderPlacedTitle => 'Order confirmed';

  @override
  String orderPlacedBody(String number) {
    return 'Thank you! Your order $number has been recorded.';
  }

  @override
  String get ordersEmpty => 'You have no orders yet.';

  @override
  String orderNumberLabel(String number) {
    return 'Order $number';
  }

  @override
  String get orderItemsLabel => 'Items';

  @override
  String get orderTrackingLabel => 'Tracking';

  @override
  String get orderCarrierLabel => 'Carrier';

  @override
  String get orderPaymentLabel => 'Payment';

  @override
  String get orderShippingLabel => 'Shipping';

  @override
  String get orderStatusCreated => 'Created';

  @override
  String get orderStatusConfirmed => 'Confirmed';

  @override
  String get orderStatusPreparing => 'Preparing';

  @override
  String get orderStatusShipped => 'Shipped';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get paymentStatusPending => 'Pending';

  @override
  String get paymentStatusPaid => 'Paid';

  @override
  String get paymentStatusFailed => 'Failed';

  @override
  String get paymentStatusRefunded => 'Refunded';

  @override
  String get shippingStatusProcessing => 'Processing';

  @override
  String get shippingStatusShipped => 'Shipped';

  @override
  String get shippingStatusDelivered => 'Delivered';

  @override
  String get shippingStatusReturned => 'Returned';

  @override
  String get withdrawalAlreadyRequested =>
      'Withdrawal already requested for this order.';

  @override
  String get signInToOrder => 'Sign in to see your orders.';

  @override
  String get genericErrorRetry => 'Something went wrong. Please try again.';

  @override
  String get adminNewProductTitle => 'New product';

  @override
  String get adminEditProductTitle => 'Edit product';

  @override
  String get adminCatalogTitle => 'Catalog management';

  @override
  String get adminProductNameIt => 'Product name (IT)';

  @override
  String get adminProductNameEn => 'Product name (EN)';

  @override
  String get adminProductType => 'Type';

  @override
  String get adminPriceList => 'List price (cents)';

  @override
  String get adminPriceSale => 'Sale price (cents, 0 = none)';

  @override
  String get adminVatRate => 'VAT rate (%)';

  @override
  String get adminStock => 'Stock';

  @override
  String get adminAvailable => 'Available';

  @override
  String get adminAssistantEligible => 'Suggestible by the AI assistant';

  @override
  String get adminAssistantEligibleHint =>
      'If off, the assistant will never suggest this product (§12.3).';

  @override
  String get adminCeMarking => 'CE marking (devices)';

  @override
  String get adminPickImage => 'Choose photo';

  @override
  String get adminTakePhoto => 'Take photo';

  @override
  String get adminImageSelected => 'Image ready to upload';

  @override
  String get adminCreateDraft => 'Create draft';

  @override
  String get adminDraftCreated => 'Draft created';

  @override
  String get adminSave => 'Save';

  @override
  String get adminSaved => 'Changes saved';

  @override
  String get adminGenerateTexts => 'Generate texts with AI';

  @override
  String get adminGeneratingTexts => 'Generating…';

  @override
  String get adminTextsGenerated => 'Texts generated — please review';

  @override
  String get adminAiGeneratedBadge => 'AI';

  @override
  String get adminAiImageStatusLabel => 'AI image';

  @override
  String get adminReviewNote =>
      'Review posology and contraindications (IT+EN) before publishing.';

  @override
  String get adminPublish => 'Publish';

  @override
  String get adminPublished => 'Product published';

  @override
  String get adminCannotPublishMedicine =>
      'To publish a medicine, posology and contraindications are required in IT and EN.';

  @override
  String get adminUnpublish => 'Back to draft';

  @override
  String get adminArchive => 'Archive';

  @override
  String get adminArchived => 'Product archived';

  @override
  String get adminFieldShortDescription => 'Short description';

  @override
  String get adminFieldDescription => 'Description';

  @override
  String get adminFieldActiveIngredient => 'Active ingredient';

  @override
  String get adminFieldPosology => 'Posology';

  @override
  String get adminFieldContraindications => 'Contraindications';

  @override
  String get adminFieldWarnings => 'Warnings';

  @override
  String get adminSectionBasics => 'Basics';

  @override
  String get adminSectionTexts => 'Content (IT / EN)';

  @override
  String get adminSectionPublish => 'Publishing';

  @override
  String get adminNoProducts => 'No products. Create one with \"Add product\".';

  @override
  String adminReviewedBy(String uid) {
    return 'Approved by $uid';
  }

  @override
  String get productTypeSop => 'SOP medicine';

  @override
  String get productTypeOtc => 'OTC medicine';

  @override
  String get productTypeParafarmaco => 'Parapharmaceutical';

  @override
  String get productTypeIntegratore => 'Supplement';

  @override
  String get productTypeCosmetico => 'Cosmetic';

  @override
  String get productTypeDispositivoMedico => 'Medical device';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusPendingReview => 'Pending review';

  @override
  String get statusPublished => 'Published';

  @override
  String get statusArchived => 'Archived';

  @override
  String get navToServices => 'Services';

  @override
  String get homeServicesCardTitle => 'Services & bookings';

  @override
  String get homeServicesCardSubtitle =>
      'Self-testing, telemedicine, CUP & reports';

  @override
  String get homeLocationsCardSubtitle =>
      'Hours, map and contacts for our pharmacies';

  @override
  String get servicesTitle => 'Services & bookings';

  @override
  String get servicesLoadError => 'Could not load services. Try again.';

  @override
  String get servicesEmpty => 'No services available right now.';

  @override
  String get serviceAllCategories => 'All';

  @override
  String get servicePriceFree => 'Free';

  @override
  String get servicePrepTitle => 'Preparation';

  @override
  String serviceDurationLabel(int min) {
    return '$min min';
  }

  @override
  String get serviceRequiresFasting => 'Requires fasting';

  @override
  String get serviceAvailableAtTitle => 'Available at';

  @override
  String get serviceCategoryAutoanalisi => 'Self-testing';

  @override
  String get serviceCategoryTelemedicina => 'Telemedicine';

  @override
  String get serviceCategoryConsulenza => 'Consultations';

  @override
  String get serviceCategoryTampone => 'Swab tests';

  @override
  String get serviceCategoryCup => 'CUP & reports';

  @override
  String get serviceCategoryAltro => 'Other services';

  @override
  String get serviceBookingFreeAccess => 'Walk-in';

  @override
  String get serviceBookingAppointment => 'By appointment';

  @override
  String get serviceBookingExternalLink => 'External service';

  @override
  String get serviceBookAppointment => 'Request appointment';

  @override
  String get serviceFreeAccessInfo => 'Walk-in: no booking needed.';

  @override
  String get serviceOpenExternal => 'Open service';

  @override
  String get serviceNotFound => 'Service not found.';

  @override
  String get locationsTitle => 'Our pharmacies';

  @override
  String get locationsLoadError => 'Could not load pharmacies. Try again.';

  @override
  String get locationsEmpty => 'No pharmacies available.';

  @override
  String get locationSelectorTitle => 'Your pharmacy';

  @override
  String get locationChange => 'Change';

  @override
  String get locationCall => 'Call';

  @override
  String get locationWhatsApp => 'WhatsApp';

  @override
  String get locationOpenMap => 'Map';

  @override
  String get locationEmail => 'Email';

  @override
  String get locationCupPoint => 'CUP point';

  @override
  String get locationHoursTitle => 'Opening hours';

  @override
  String get locationHoursClosed => 'Closed';

  @override
  String get locationNoHours => 'Hours not available';

  @override
  String get locationChooseTitle => 'Choose a pharmacy';

  @override
  String get launchFailed => 'Could not open the link.';

  @override
  String get bookingTitle => 'Appointment request';

  @override
  String get bookingSignInRequired => 'Sign in to request an appointment.';

  @override
  String get bookingChooseLocation => 'Pharmacy';

  @override
  String get bookingChooseDate => 'Date';

  @override
  String get bookingChooseTime => 'Time';

  @override
  String get bookingPickDate => 'Pick a date';

  @override
  String get bookingPickTime => 'Pick a time';

  @override
  String get bookingContactPhone => 'Contact phone';

  @override
  String get bookingNotes => 'Notes (optional)';

  @override
  String get bookingSubmit => 'Send request';

  @override
  String get bookingSubmitted => 'Request sent: we\'ll contact you to confirm.';

  @override
  String get bookingIncomplete => 'Select a pharmacy, date and time.';

  @override
  String get bookingError => 'Could not send. Try again.';

  @override
  String get bookingDisclaimer =>
      'This booking is a slot request handled by the pharmacy staff, who will confirm your appointment.';

  @override
  String get appointmentsTitle => 'My appointments';

  @override
  String get appointmentsSignIn => 'Sign in to see your appointments.';

  @override
  String get appointmentsEmpty => 'You have no appointments yet.';

  @override
  String get apptStatusRequested => 'Requested';

  @override
  String get apptStatusConfirmed => 'Confirmed';

  @override
  String get apptStatusCompleted => 'Completed';

  @override
  String get apptStatusCancelled => 'Cancelled';

  @override
  String get apptStatusNoShow => 'No-show';

  @override
  String get adminManageAppointments => 'Manage bookings';

  @override
  String get adminAppointmentsTitle => 'Bookings';

  @override
  String get adminAppointmentsEmpty => 'No bookings for this site.';

  @override
  String get adminApptConfirm => 'Confirm';

  @override
  String get adminApptCancel => 'Cancel';

  @override
  String get adminApptComplete => 'Complete';

  @override
  String get adminApptNoShow => 'No-show';

  @override
  String get adminApptUpdated => 'Status updated.';

  @override
  String adminApptContactLabel(String phone) {
    return 'Contact: $phone';
  }

  @override
  String get cupInfoTitle => 'CUP bookings & reports';

  @override
  String get cupInfoIntro =>
      'We point you to the regional health services. SSN bookings happen on the state portals with SPID login, not inside the app.';

  @override
  String get cupOpenCupWeb => 'Open CUPWeb';

  @override
  String get cupOpenErSalute => 'Open ER Salute';

  @override
  String get cupOpenFse => 'Health record (FSE)';

  @override
  String get cupPrepareDocsTitle => 'Prepare your documents';

  @override
  String get cupPrepareDocsBody =>
      'Prescription/NRE, health card and any exemption code.';

  @override
  String get cupPointsTitle => 'Where to book (FarmaCUP)';

  @override
  String get cupPointYes => 'CUP point available';

  @override
  String get cupPointNo => 'No CUP point at this site';
}
