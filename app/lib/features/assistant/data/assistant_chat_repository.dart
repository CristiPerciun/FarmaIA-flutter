import 'package:cloud_functions/cloud_functions.dart';

import '../domain/chat_message.dart';

/// Typed reasons the backend can refuse a turn (mapped from `HttpsError`
/// details, see `firebase/functions/src/ai/assistant_chat.ts`).
enum AssistantChatFailure {
  /// Art. 9 consent missing (§12.5) — the UI should show the onboarding.
  consentRequired,

  /// Feature flag OFF and the caller is not staff (step 4B.6b).
  assistantDisabled,

  /// Per-uid daily message limit reached (§12.3 cost control).
  dailyLimit,

  /// Per-session turn limit reached — start a new conversation.
  sessionLimit,

  /// Network error, function crash, anything else: degrade to results-only.
  unavailable,
}

class AssistantChatException implements Exception {
  const AssistantChatException(this.failure);
  final AssistantChatFailure failure;

  @override
  String toString() => 'AssistantChatException(${failure.name})';
}

/// One validated assistant turn as returned by the `assistantChat` callable.
class AssistantChatResult {
  const AssistantChatResult({
    required this.sessionId,
    required this.message,
  });

  /// Server session id (null for ephemeral router replies without consent).
  final String? sessionId;

  /// The assistant reply, ready to append to the conversation.
  final ChatMessage message;
}

/// Client for the assistant Cloud Functions (`assistantChat`,
/// `assistantEscalate`). Same callable idiom as the admin AI pipeline —
/// region europe-west1, keys and logic server-side only (§11.5).
class AssistantChatRepository {
  AssistantChatRepository(this._functions);

  final FirebaseFunctions _functions;

  /// Sends one user turn. [sessionConsent] carries the per-session art. 9
  /// consent for guests/anonymous users (§12.5); account consent is read
  /// server-side from `users/{uid}.consents.aiAssistant`.
  Future<AssistantChatResult> sendMessage({
    required String message,
    required String locale,
    required String surface,
    String? sessionId,
    bool sessionConsent = false,
  }) async {
    try {
      final response = await _functions
          .httpsCallable('assistantChat')
          .call<Map<String, dynamic>>({
            'message': message,
            'locale': locale,
            'surface': surface,
            'sessionId': ?sessionId,
            'sessionConsent': sessionConsent,
          });
      final data = response.data;
      final reply = (data['reply'] as Map?)?.cast<String, dynamic>() ?? const {};
      final mode = AssistantReplyMode.fromStorage(data['mode'] as String?);
      return AssistantChatResult(
        sessionId: data['sessionId'] as String?,
        message: ChatMessage(
          role: ChatRole.assistant,
          text: (reply['text'] as String?) ?? '',
          productIds: [
            for (final id in (reply['productIds'] as List?) ?? const [])
              if (id is String) id,
          ],
          mode: mode,
          escalation: reply['escalation'] == true,
          redFlag: reply['redFlag'] == true,
        ),
      );
    } on FirebaseFunctionsException catch (e) {
      throw AssistantChatException(_mapFailure(e));
    } catch (_) {
      throw const AssistantChatException(AssistantChatFailure.unavailable);
    }
  }

  /// "Parla con il farmacista": flags the session for the admin inbox (§12.4).
  Future<void> escalate(String sessionId) async {
    try {
      await _functions
          .httpsCallable('assistantEscalate')
          .call<Map<String, dynamic>>({'sessionId': sessionId});
    } on FirebaseFunctionsException catch (e) {
      throw AssistantChatException(_mapFailure(e));
    } catch (_) {
      throw const AssistantChatException(AssistantChatFailure.unavailable);
    }
  }

  AssistantChatFailure _mapFailure(FirebaseFunctionsException e) {
    final reason = (e.details is Map)
        ? (e.details as Map)['reason'] as String?
        : null;
    return switch (reason ?? e.message) {
      'consent-required' => AssistantChatFailure.consentRequired,
      'assistant-disabled' => AssistantChatFailure.assistantDisabled,
      'daily-limit' => AssistantChatFailure.dailyLimit,
      'session-limit' => AssistantChatFailure.sessionLimit,
      _ => AssistantChatFailure.unavailable,
    };
  }
}
