import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';

final aiPipelineServiceProvider = Provider<AiPipelineService>(
  (ref) => AiPipelineService(ref),
);

/// Client for the admin AI pipeline Cloud Functions (§10, §4.3). The heavy
/// lifting (LLM/Photoroom, keys, guardrails) is server-side; the client only
/// triggers and shows results for pharmacist review.
class AiPipelineService {
  AiPipelineService(this._ref);

  final Ref _ref;

  /// Generates bilingual draft texts for a product via the LLM pipeline
  /// (§4.3). The result is written to the product doc by the function and
  /// streamed back through [adminProductProvider]; this just awaits completion.
  Future<void> generateTexts(String productId) async {
    await _ref
        .read(firebaseFunctionsProvider)
        .httpsCallable('generateProductTexts')
        .call({'productId': productId});
  }
}
