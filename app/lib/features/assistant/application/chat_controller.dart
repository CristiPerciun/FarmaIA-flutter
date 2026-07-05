import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/utils/fuzzy.dart';
import '../../auth/application/auth_providers.dart';
import '../../catalog/application/catalog_providers.dart';
import '../data/assistant_chat_repository.dart';
import '../domain/chat_message.dart';
import 'assistant_consent.dart';

final assistantChatRepositoryProvider = Provider<AssistantChatRepository>(
  (ref) => AssistantChatRepository(ref.watch(firebaseFunctionsProvider)),
);

/// In-memory conversation state. App-scoped (not autoDispose) on purpose:
/// on desktop the 70/30 panel closes and reopens with the conversation
/// intact (§12.6 "la conversazione resta viva nella sessione").
class AssistantConversation {
  const AssistantConversation({
    this.messages = const [],
    this.sending = false,
    this.sessionId,
    this.transientError,
    this.chatUnavailable = false,
    this.needsConsent = false,
  });

  final List<ChatMessage> messages;
  final bool sending;

  /// Server session id (null until the first persisted turn).
  final String? sessionId;

  /// Limit errors surfaced as a snackbar, then cleared.
  final AssistantChatFailure? transientError;

  /// Backend refused (feature flag off) → the UI falls back to results-only.
  final bool chatUnavailable;

  /// Backend asked for consent (defensive: the UI gates before sending).
  final bool needsConsent;

  AssistantConversation copyWith({
    List<ChatMessage>? messages,
    bool? sending,
    String? sessionId,
    AssistantChatFailure? transientError,
    bool clearTransientError = false,
    bool? chatUnavailable,
    bool? needsConsent,
  }) => AssistantConversation(
    messages: messages ?? this.messages,
    sending: sending ?? this.sending,
    sessionId: sessionId ?? this.sessionId,
    transientError: clearTransientError
        ? null
        : (transientError ?? this.transientError),
    chatUnavailable: chatUnavailable ?? this.chatUnavailable,
    needsConsent: needsConsent ?? this.needsConsent,
  );
}

final chatControllerProvider =
    NotifierProvider<ChatController, AssistantConversation>(
      ChatController.new,
    );

class ChatController extends Notifier<AssistantConversation> {
  @override
  AssistantConversation build() => const AssistantConversation();

  /// Sends one user turn through `assistantChat`. [surface] is telemetry
  /// only ("mobile" page vs "desktop" 70/30 panel).
  Future<void> send(String text, {required String surface}) async {
    final message = text.trim();
    if (message.isEmpty || state.sending) return;

    final locale = ref.read(localeProvider).languageCode;
    final sessionConsent =
        ref.read(aiConsentStatusProvider) == AiConsentStatus.granted;

    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(role: ChatRole.user, text: message),
      ],
      sending: true,
      clearTransientError: true,
    );

    try {
      // Guests get an anonymous session (same idiom as guest checkout);
      // their consent travels per-session in the request (§12.5).
      await ref.read(authRepositoryProvider).ensureSignedIn();
      final result = await ref
          .read(assistantChatRepositoryProvider)
          .sendMessage(
            message: message,
            locale: locale,
            surface: surface,
            sessionId: state.sessionId,
            sessionConsent: sessionConsent,
          );
      state = state.copyWith(
        messages: [...state.messages, result.message],
        sessionId: result.sessionId ?? state.sessionId,
        sending: false,
      );
    } on AssistantChatException catch (e) {
      _handleFailure(e.failure, message);
    } catch (_) {
      _handleFailure(AssistantChatFailure.unavailable, message);
    }
  }

  void _handleFailure(AssistantChatFailure failure, String query) {
    switch (failure) {
      case AssistantChatFailure.consentRequired:
        state = state.copyWith(sending: false, needsConsent: true);
      case AssistantChatFailure.assistantDisabled:
        // Flag turned off mid-session: degrade to results-only (§12.6).
        state = state.copyWith(sending: false, chatUnavailable: true);
      case AssistantChatFailure.dailyLimit:
      case AssistantChatFailure.sessionLimit:
        state = state.copyWith(sending: false, transientError: failure);
      case AssistantChatFailure.unavailable:
        // LLM/backend unreachable → courteous local fallback with fuzzy
        // results for catalog-like queries (§12.3: degrada, non blocca).
        state = state.copyWith(
          sending: false,
          messages: [
            ...state.messages,
            ChatMessage(
              role: ChatRole.assistant,
              // Empty text: the UI localizes the fallback copy.
              text: '',
              productIds: _localFuzzyIds(query),
              mode: AssistantReplyMode.fallback,
              escalation: true,
            ),
          ],
        );
    }
  }

  /// Local "solo risultati" scoring — same engine and threshold as the
  /// results-only page (ADR 0002), capped to card-sized output.
  List<String> _localFuzzyIds(String query) {
    final products =
        ref.read(publishedProductsProvider).valueOrNull ?? const [];
    final scored = <(String, double)>[];
    for (final p in products) {
      final score = Fuzzy.bestScore(query, [
        p.name.it,
        p.name.en,
        p.activeIngredient.it,
        p.activeIngredient.en,
        p.sku,
        p.barcode,
      ]);
      if (score >= 0.62) scored.add((p.id, score));
    }
    scored.sort((a, b) => b.$2.compareTo(a.$2));
    return [for (final e in scored.take(3)) e.$1];
  }

  /// "Parla con il farmacista" (§12.4). Returns true when the escalation
  /// reached the admin inbox.
  Future<bool> escalate() async {
    final sessionId = state.sessionId;
    if (sessionId == null) return false;
    try {
      await ref.read(assistantChatRepositoryProvider).escalate(sessionId);
      return true;
    } on AssistantChatException {
      return false;
    }
  }

  /// Starts over (also the way out of a session-limit error).
  void newConversation() => state = const AssistantConversation();

  void clearTransientError() =>
      state = state.copyWith(clearTransientError: true);

  void consentHandled() => state = state.copyWith(needsConsent: false);
}
