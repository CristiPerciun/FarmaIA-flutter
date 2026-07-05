import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baganza_app/core/models/app_config.dart';
import 'package:baganza_app/features/assistant/application/assistant_consent.dart';
import 'package:baganza_app/features/assistant/domain/chat_message.dart';

void main() {
  group('AppConfig.assistantChatEnabled (step 4B.6b)', () {
    test('defaults to false: the chat ships OFF until the 4B.8 gate', () {
      expect(const AppConfig().assistantChatEnabled, isFalse);
      expect(AppConfig.fromJson(const {}).assistantChatEnabled, isFalse);
    });

    test('parses the flag and round-trips through toJson', () {
      final config = AppConfig.fromJson(const {'assistantChatEnabled': true});
      expect(config.assistantChatEnabled, isTrue);
      expect(config.toJson()['assistantChatEnabled'], isTrue);
    });
  });

  group('sessionAiConsentProvider (art. 9, step 4B.4)', () {
    test('starts undecided, then tracks grant/decline/reset', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(sessionAiConsentProvider), isNull);

      container.read(sessionAiConsentProvider.notifier).grant();
      expect(container.read(sessionAiConsentProvider), isTrue);

      container.read(sessionAiConsentProvider.notifier).decline();
      expect(container.read(sessionAiConsentProvider), isFalse);

      // "Attiva l'assistente" after a refusal → onboarding again.
      container.read(sessionAiConsentProvider.notifier).reset();
      expect(container.read(sessionAiConsentProvider), isNull);
    });
  });

  group('AssistantReplyMode.fromStorage', () {
    test('maps every backend mode and falls back to mock', () {
      expect(
        AssistantReplyMode.fromStorage('router'),
        AssistantReplyMode.router,
      );
      expect(AssistantReplyMode.fromStorage('llm'), AssistantReplyMode.llm);
      expect(
        AssistantReplyMode.fromStorage('redflag'),
        AssistantReplyMode.redflag,
      );
      expect(AssistantReplyMode.fromStorage('rx'), AssistantReplyMode.rx);
      expect(
        AssistantReplyMode.fromStorage('moderated'),
        AssistantReplyMode.moderated,
      );
      expect(
        AssistantReplyMode.fromStorage('fallback'),
        AssistantReplyMode.fallback,
      );
      expect(
        AssistantReplyMode.fromStorage('unknown-future-mode'),
        AssistantReplyMode.mock,
      );
      expect(AssistantReplyMode.fromStorage(null), AssistantReplyMode.mock);
    });
  });
}
