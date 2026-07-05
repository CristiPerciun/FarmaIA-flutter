import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';

/// Resolved art. 9 consent for the assistant chat (§12.5, step 4B.4).
enum AiConsentStatus {
  /// Never asked (this session) — show the first-run onboarding (§12.6).
  unknown,

  /// Granted: on the account (`users.consents.aiAssistant`) or for this
  /// session (guests / signed-in users who accept on the spot).
  granted,

  /// Declined for this session → the page stays usable in "results-only"
  /// mode (local fuzzy, nothing sent to the LLM). Asked again next session:
  /// only a *granted* consent is remembered, a refusal never is.
  declined,
}

/// Per-session consent decision (guests, or before the account write lands).
/// `null` = undecided. In-memory only, by design: a session consent must not
/// outlive the session (§12.5).
final sessionAiConsentProvider =
    NotifierProvider<SessionAiConsentNotifier, bool?>(
      SessionAiConsentNotifier.new,
    );

class SessionAiConsentNotifier extends Notifier<bool?> {
  @override
  bool? build() => null;

  void grant() => state = true;
  void decline() => state = false;

  /// "Attiva l'assistente" after a refusal: back to undecided so the
  /// onboarding can be shown again.
  void reset() => state = null;
}

/// Effective consent: account consent wins, then the session decision.
final aiConsentStatusProvider = Provider<AiConsentStatus>((ref) {
  final accountConsent =
      ref.watch(appUserProvider).valueOrNull?.consents.aiAssistant ?? false;
  if (accountConsent) return AiConsentStatus.granted;
  return switch (ref.watch(sessionAiConsentProvider)) {
    true => AiConsentStatus.granted,
    false => AiConsentStatus.declined,
    null => AiConsentStatus.unknown,
  };
});
