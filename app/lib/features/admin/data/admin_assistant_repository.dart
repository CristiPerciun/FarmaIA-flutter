import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/assistant_session.dart';

/// Registry filters (§12.4: filtro per `redFlagTriggered`/`flaggedForReview`
/// + inbox escalation).
enum AssistantSessionFilter { all, redFlag, flagged, escalations }

/// Staff-side reads for the assistant supervision (step 4B.7).
///
/// Sessions and messages are read-only here — every mutation goes through
/// the `assistantReview` callable so the registry stays an audit log (§12.4).
/// Only the guardrail lists (`config/assistant`) are written directly:
/// that's operational config, staff-writable by the rules.
class AdminAssistantRepository {
  AdminAssistantRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _sessions =>
      _firestore.collection('chatSessions');

  Stream<List<AssistantSession>> watchSessions(
    AssistantSessionFilter filter, {
    int limit = 50,
  }) {
    Query<Map<String, dynamic>> query = _sessions;
    query = switch (filter) {
      AssistantSessionFilter.all => query,
      AssistantSessionFilter.redFlag => query.where(
        'redFlagTriggered',
        isEqualTo: true,
      ),
      AssistantSessionFilter.flagged => query.where(
        'flaggedForReview',
        isEqualTo: true,
      ),
      AssistantSessionFilter.escalations => query
          .where('escalated', isEqualTo: true)
          .where('escalationHandled', isEqualTo: false),
    };
    return query
        .orderBy('lastMessageAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snap) => [
            for (final doc in snap.docs)
              AssistantSession.fromJson(doc.data(), doc.id),
          ],
        );
  }

  Stream<AssistantSession?> watchSession(String sessionId) =>
      _sessions.doc(sessionId).snapshots().map((snap) {
        final data = snap.data();
        if (data == null) return null;
        return AssistantSession.fromJson(data, snap.id);
      });

  Stream<List<AssistantSessionMessage>> watchMessages(String sessionId) =>
      _sessions
          .doc(sessionId)
          .collection('messages')
          .orderBy('createdAt')
          .snapshots()
          .map(
            (snap) => [
              for (final doc in snap.docs)
                AssistantSessionMessage.fromJson(doc.data()),
            ],
          );

  Stream<AssistantGuardrailConfig> watchGuardrailConfig() => _firestore
      .collection('config')
      .doc('assistant')
      .snapshots()
      .map(
        (snap) => AssistantGuardrailConfig.fromJson(snap.data() ?? const {}),
      );

  /// Saves the curated lists — effective at the next chat turn, no deploy
  /// needed ("modifica la lista red-flag senza deploy", step 4B.7).
  Future<void> saveGuardrailConfig({
    required List<String> redFlags,
    required List<String> rxTerms,
  }) => _firestore.collection('config').doc('assistant').set({
    'redFlags': redFlags,
    'rxTerms': rxTerms,
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}
