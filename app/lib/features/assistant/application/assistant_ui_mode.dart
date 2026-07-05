import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/config_provider.dart';
import '../../../core/providers/connectivity_provider.dart';
import '../../auth/application/auth_providers.dart';
import 'assistant_consent.dart';
import 'chat_controller.dart';

/// What the assistant surface should render (§12.6 degradations).
enum AssistantUiMode {
  /// Conversational chat (flag on / staff, online, consent granted).
  chat,

  /// First-run onboarding with the art. 9 consent (step 4B.6).
  onboarding,

  /// "Solo risultati": full-screen fuzzy search — the search never
  /// disappears (§12.6). See [ResultsOnlyReason] for the banner copy.
  resultsOnly,
}

/// Why the surface is in results-only mode (drives the contextual banner).
enum ResultsOnlyReason {
  none,

  /// Feature flag off (pre-gate 4B.8): honest bridge note.
  flagOff,

  /// Offline (§9.1): local fuzzy on the cached catalog.
  offline,

  /// Consent declined: discreet invitation to enable the assistant.
  consentDeclined,

  /// Backend refused/unreachable this session.
  unavailable,
}

class AssistantUiState {
  const AssistantUiState(this.mode, this.reason);
  final AssistantUiMode mode;
  final ResultsOnlyReason reason;
}

/// Whether the conversational chat is enabled for this user (step 4B.6b):
/// the `config/app.assistantChatEnabled` flag, with staff always allowed so
/// the red-team can exercise the disabled chat (4B.8).
final assistantChatFlagProvider = Provider<bool>((ref) {
  final enabled = ref.watch(appConfigValueProvider).assistantChatEnabled;
  final isStaff = ref.watch(isStaffProvider);
  return enabled || isStaff;
});

/// Resolves the effective assistant surface, in degradation-priority order:
/// flag → connectivity → backend health → consent.
final assistantUiStateProvider = Provider<AssistantUiState>((ref) {
  if (!ref.watch(assistantChatFlagProvider)) {
    return const AssistantUiState(
      AssistantUiMode.resultsOnly,
      ResultsOnlyReason.flagOff,
    );
  }
  if (ref.watch(isOnlineProvider).valueOrNull == false) {
    return const AssistantUiState(
      AssistantUiMode.resultsOnly,
      ResultsOnlyReason.offline,
    );
  }
  if (ref.watch(chatControllerProvider.select((s) => s.chatUnavailable))) {
    return const AssistantUiState(
      AssistantUiMode.resultsOnly,
      ResultsOnlyReason.unavailable,
    );
  }
  return switch (ref.watch(aiConsentStatusProvider)) {
    AiConsentStatus.granted => const AssistantUiState(
      AssistantUiMode.chat,
      ResultsOnlyReason.none,
    ),
    AiConsentStatus.unknown => const AssistantUiState(
      AssistantUiMode.onboarding,
      ResultsOnlyReason.none,
    ),
    AiConsentStatus.declined => const AssistantUiState(
      AssistantUiMode.resultsOnly,
      ResultsOnlyReason.consentDeclined,
    ),
  };
});
