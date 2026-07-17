import 'package:flutter/foundation.dart';

/// Platform capability guards (§4.4). Features that use mobile-only plugins
/// (barcode scanner, push) must check these and provide a desktop/web fallback.
abstract final class PlatformSupport {
  /// True on Android/iOS builds (not web, not desktop).
  static bool get isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// The camera barcode scanner (`mobile_scanner`) ships only for mobile.
  /// On desktop/web the UI falls back to manual EAN entry (§2.5, §2.8).
  static bool get barcodeScanner => isMobile;

  /// Federated (Google) sign-in via Firebase Auth's OAuth flow: `signInWithPopup`
  /// on web and `signInWithProvider` on mobile. Not supported on desktop/Windows,
  /// where the UI hides the Google button and keeps email/password (declared
  /// fallback, §4.4/§1.5).
  static bool get federatedSignIn => kIsWeb || isMobile;
}
