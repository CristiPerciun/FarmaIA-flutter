import 'package:url_launcher/url_launcher.dart';

/// Thin wrapper over `url_launcher` for the outward links used by the Servizi
/// module (§16.4–16.6): phone, WhatsApp, maps and the regional health portals
/// (CUPWeb / ER Salute / FSE). Every helper returns whether the launch
/// succeeded so callers can surface a fallback (e.g. a snackbar).
///
/// The app never *books* on the regional systems (§16.6) — it only deep-links
/// out to them.
class Launchers {
  const Launchers._();

  /// Opens the dialer with [phone] pre-filled. Non-digit characters are
  /// stripped so a formatted number ("0521 964022") still works.
  static Future<bool> call(String phone) =>
      _launch(Uri(scheme: 'tel', path: _digits(phone)));

  /// Opens a WhatsApp chat with [phone] (E.164 without '+', e.g. Italian
  /// "39331..."). Falls back to the phone's country code when [countryCode]
  /// is supplied and the number is national.
  static Future<bool> whatsApp(String phone, {String countryCode = '39'}) {
    var number = _digits(phone);
    if (!number.startsWith(countryCode) && number.length <= 10) {
      number = '$countryCode$number';
    }
    return _launch(Uri.parse('https://wa.me/$number'));
  }

  /// Opens the address (or lat/lng) in the platform maps app / web maps.
  static Future<bool> maps({double? lat, double? lng, String? query}) {
    final q = (lat != null && lng != null)
        ? '$lat,$lng'
        : (query ?? '');
    return _launch(
      Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': q}),
    );
  }

  /// Opens an email compose window.
  static Future<bool> email(String address) =>
      _launch(Uri(scheme: 'mailto', path: address));

  /// Opens an arbitrary external URL (regional health portals, §16.6) in a new
  /// tab / external browser.
  static Future<bool> url(String href) {
    final uri = Uri.tryParse(href);
    if (uri == null) return Future.value(false);
    return _launch(uri);
  }

  static String _digits(String value) =>
      value.replaceAll(RegExp(r'[^0-9]'), '');

  static Future<bool> _launch(Uri uri) async {
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
