import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/admin_assistant_repository.dart';
import '../domain/assistant_session.dart';

final adminAssistantRepositoryProvider = Provider<AdminAssistantRepository>(
  (ref) => AdminAssistantRepository(ref.watch(firestoreProvider)),
);

/// Active registry filter (step 4B.7).
final assistantSessionFilterProvider =
    NotifierProvider<AssistantSessionFilterNotifier, AssistantSessionFilter>(
      AssistantSessionFilterNotifier.new,
    );

class AssistantSessionFilterNotifier extends Notifier<AssistantSessionFilter> {
  @override
  AssistantSessionFilter build() => AssistantSessionFilter.all;
  void set(AssistantSessionFilter filter) => state = filter;
}

/// Conversation registry, newest activity first, per current filter.
final adminAssistantSessionsProvider =
    StreamProvider.autoDispose<List<AssistantSession>>((ref) {
      final filter = ref.watch(assistantSessionFilterProvider);
      return ref
          .watch(adminAssistantRepositoryProvider)
          .watchSessions(filter);
    });

final adminAssistantSessionProvider = StreamProvider.autoDispose
    .family<AssistantSession?, String>(
      (ref, sessionId) => ref
          .watch(adminAssistantRepositoryProvider)
          .watchSession(sessionId),
    );

final adminAssistantMessagesProvider = StreamProvider.autoDispose
    .family<List<AssistantSessionMessage>, String>(
      (ref, sessionId) => ref
          .watch(adminAssistantRepositoryProvider)
          .watchMessages(sessionId),
    );

final adminAssistantGuardrailsProvider =
    StreamProvider.autoDispose<AssistantGuardrailConfig>(
      (ref) => ref
          .watch(adminAssistantRepositoryProvider)
          .watchGuardrailConfig(),
    );

/// Review actions via the `assistantReview` callable (whitelisted fields,
/// audit-log posture — see the Cloud Function).
final assistantReviewServiceProvider = Provider<AssistantReviewService>(
  (ref) => AssistantReviewService(ref),
);

class AssistantReviewService {
  AssistantReviewService(this._ref);

  final Ref _ref;

  Future<void> review(
    String sessionId, {
    bool? flaggedForReview,
    String? reviewNote,
    bool? escalationHandled,
  }) async {
    await _ref
        .read(firebaseFunctionsProvider)
        .httpsCallable('assistantReview')
        .call<Map<String, dynamic>>({
          'sessionId': sessionId,
          'flaggedForReview': ?flaggedForReview,
          'reviewNote': ?reviewNote,
          'escalationHandled': ?escalationHandled,
        });
  }
}
