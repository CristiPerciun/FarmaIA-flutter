import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/assistant_panel.dart';
import '../../application/assistant_ui_mode.dart';
import '../../application/chat_controller.dart';
import 'assistant_conversation.dart';
import 'assistant_onboarding.dart';

/// The desktop 30% chat panel (§12.6, step 4B.5): full-height column with
/// header (name + AI badge + ✕), the shared conversation, and ESC-to-close.
/// Solid white surface on purpose — product prices and guardrail texts must
/// not sit behind glass (§7.2.3). Focus is trapped inside while open.
class AssistantSidePanel extends ConsumerWidget {
  const AssistantSidePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final uiState = ref.watch(assistantUiStateProvider);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            ref.read(assistantPanelProvider.notifier).hide(),
      },
      child: FocusScope(
        autofocus: true,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(left: BorderSide(color: AppColors.border)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 20,
                      color: AppColors.brandGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.assistantPanelTitle,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.brandGreenDark,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.brandGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.assistantBadgeAi,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: l10n.assistantClose,
                      onPressed: () =>
                          ref.read(assistantPanelProvider.notifier).hide(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: switch (uiState.mode) {
                  AssistantUiMode.chat => const AssistantConversationView(
                    surface: 'desktop',
                    autofocus: true,
                  ),
                  AssistantUiMode.onboarding => const AssistantOnboarding(),
                  // Results-only in the panel: point to the full-page search
                  // (the panel is a conversation surface, the grid lives on
                  // /assistant). Keep it honest and small.
                  AssistantUiMode.resultsOnly => _PanelUnavailable(
                    reason: uiState.reason,
                  ),
                },
              ),
              if (uiState.mode == AssistantUiMode.chat)
                _NewConversationFooter(
                  onPressed: () => ref
                      .read(chatControllerProvider.notifier)
                      .newConversation(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewConversationFooter extends StatelessWidget {
  const _NewConversationFooter({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add_comment_outlined, size: 16),
        label: Text(l10n.assistantNewConversation),
        style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
      ),
    );
  }
}

class _PanelUnavailable extends StatelessWidget {
  const _PanelUnavailable({required this.reason});

  final ResultsOnlyReason reason;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = switch (reason) {
      ResultsOnlyReason.offline => l10n.assistantOfflineBanner,
      ResultsOnlyReason.consentDeclined => l10n.assistantResultsOnlyBanner,
      ResultsOnlyReason.unavailable => l10n.assistantUnavailableBanner,
      _ => l10n.assistantBridgeNote,
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline,
              size: 40,
              color: AppColors.brandGreen,
            ),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
