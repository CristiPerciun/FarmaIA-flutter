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
}
