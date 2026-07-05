/// Conversation model for the customer assistant (§12.6, Fase 4B).
///
/// Messages live in memory for the current session; the durable, purgeable
/// record is written server-side by `assistantChat` on `chatSessions/`
/// (§12.5) — the client never writes chat data to Firestore directly.
library;

/// Who produced a message.
enum ChatRole { user, assistant }

/// How the assistant produced a reply (mirrors the backend `mode` field).
enum AssistantReplyMode {
  /// Pre-LLM router: catalog-name query answered with direct product cards —
  /// zero tokens, no health data (§12.3).
  router,

  /// Full pipeline with the configured LLM.
  llm,

  /// Deterministic mock (no LLM key configured — dev/emulator).
  mock,

  /// Red-flag triage: no products, referral to doctor/112/pharmacist (§12.4).
  redflag,

  /// Prescription-only request refused.
  rx,

  /// Moderation blocklist refusal.
  moderated,

  /// LLM down or unreachable: courteous message + fuzzy results (§12.3).
  fallback;

  static AssistantReplyMode fromStorage(String? value) => switch (value) {
    'router' => router,
    'llm' => llm,
    'redflag' => redflag,
    'rx' => rx,
    'moderated' => moderated,
    'fallback' => fallback,
    _ => mock,
  };
}

/// One chat bubble. Assistant messages may carry verified product references
/// (`productIds` are validated server-side against the published catalog) and
/// an [escalation] hint that surfaces the "Parla con il farmacista" action.
class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.text,
    this.productIds = const [],
    this.mode = AssistantReplyMode.mock,
    this.escalation = false,
    this.redFlag = false,
  });

  final ChatRole role;
  final String text;
  final List<String> productIds;
  final AssistantReplyMode mode;
  final bool escalation;
  final bool redFlag;
}
