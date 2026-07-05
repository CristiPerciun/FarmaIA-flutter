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
}
