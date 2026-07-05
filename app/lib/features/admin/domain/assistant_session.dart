import '../../../core/firebase/firestore_converters.dart';

/// Admin view of a `chatSessions/{id}` document (§12.4, step 4B.7).
///
/// The registry is pseudonymized: staff see [pseudonym], not the account
/// identity — enough to audit and follow up an escalation without exposing
/// who asked what (§12.5).
class AssistantSession {
  const AssistantSession({
    required this.id,
    required this.userRef,
    required this.locale,
    required this.surface,
    required this.turnCount,
    required this.redFlagTriggered,
    required this.escalated,
    required this.escalationHandled,
    required this.flaggedForReview,
    this.reviewNote,
    this.provenanceMode = '',
    this.provenanceModel = '',
    this.startedAt,
    this.lastMessageAt,
  });

  factory AssistantSession.fromJson(Map<String, dynamic> json, String id) {
    final provenance = (json['provenance'] as Map?)?.cast<String, dynamic>();
    return AssistantSession(
      id: id,
      userRef: (json['userRef'] as String?) ?? '',
      locale: (json['locale'] as String?) ?? 'it',
      surface: (json['surface'] as String?) ?? '',
      turnCount: (json['turnCount'] as num?)?.toInt() ?? 0,
      redFlagTriggered: json['redFlagTriggered'] == true,
      escalated: json['escalated'] == true,
      escalationHandled: json['escalationHandled'] == true,
      flaggedForReview: json['flaggedForReview'] == true,
      reviewNote: json['reviewNote'] as String?,
      provenanceMode: (provenance?['mode'] as String?) ?? '',
      provenanceModel: (provenance?['model'] as String?) ?? '',
      startedAt: dateFromJson(json['startedAt']),
      lastMessageAt: dateFromJson(json['lastMessageAt']),
    );
  }

  final String id;
  final String userRef;
  final String locale;
  final String surface;
  final int turnCount;
  final bool redFlagTriggered;
  final bool escalated;
  final bool escalationHandled;
  final bool flaggedForReview;
  final String? reviewNote;
  final String provenanceMode;
  final String provenanceModel;
  final DateTime? startedAt;
  final DateTime? lastMessageAt;

  /// Anonymous-looking short code shown in the registry instead of the uid.
  String get pseudonym {
    final uid = userRef.split('/').last;
    return uid.length <= 6 ? uid : uid.substring(uid.length - 6);
  }
}

/// One message of a session, as logged by the Cloud Function.
class AssistantSessionMessage {
  const AssistantSessionMessage({
    required this.role,
    required this.text,
    required this.productIds,
    required this.mode,
    required this.redFlag,
    this.createdAt,
  });

  factory AssistantSessionMessage.fromJson(Map<String, dynamic> json) =>
      AssistantSessionMessage(
        role: (json['role'] as String?) ?? 'user',
        text: (json['text'] as String?) ?? '',
        productIds: stringListFromJson(json['productIds']),
        mode: (json['mode'] as String?) ?? '',
        redFlag: json['redFlag'] == true,
        createdAt: dateFromJson(json['createdAt']),
      );

  final String role;
  final String text;
  final List<String> productIds;
  final String mode;
  final bool redFlag;
  final DateTime? createdAt;

  bool get isAssistant => role == 'assistant';
}

/// The pharmacist-curated guardrail lists (`config/assistant`, step 4B.7).
/// They extend — never replace — the built-in server defaults.
class AssistantGuardrailConfig {
  const AssistantGuardrailConfig({
    this.redFlags = const [],
    this.rxTerms = const [],
  });

  factory AssistantGuardrailConfig.fromJson(Map<String, dynamic> json) =>
      AssistantGuardrailConfig(
        redFlags: stringListFromJson(json['redFlags']),
        rxTerms: stringListFromJson(json['rxTerms']),
      );

  final List<String> redFlags;
  final List<String> rxTerms;
}
