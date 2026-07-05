import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../l10n/app_localizations.dart';
import '../../cart/application/cart_providers.dart';
import '../../catalog/presentation/widgets/product_card.dart';
import '../application/assistant_consent.dart';
import '../application/assistant_providers.dart';
import '../application/assistant_ui_mode.dart';
import '../application/chat_controller.dart';
import 'widgets/assistant_conversation.dart';
import 'widgets/assistant_onboarding.dart';

/// The customer assistant page (§12.6): the single entry point for search,
/// reached from the central "Chat AI" tab and from the search field/lens on
/// Home and Negozio. Renders one of three states (step 4B.6):
///
/// - **chat** — the conversational assistant (flag on/staff, online, consent);
/// - **onboarding** — first-run "what it does / doesn't" + art. 9 consent;
/// - **solo risultati** — full-screen fuzzy search with a contextual banner
///   (flag off / offline / consent declined / backend down): the search never
///   disappears (§12.6).
class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(assistantQueryProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final uiState = ref.watch(assistantUiStateProvider);
    final isChat = uiState.mode == AssistantUiMode.chat;

    return AdaptiveScaffold(
      currentTab: AppTab.chatAi,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.assistantTitle),
            if (isChat) ...[
              const SizedBox(width: 8),
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
            ],
          ],
        ),
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              )
            : null,
        actions: [
          if (isChat)
            IconButton(
              icon: const Icon(Icons.add_comment_outlined),
              tooltip: l10n.assistantNewConversation,
              onPressed: () =>
                  ref.read(chatControllerProvider.notifier).newConversation(),
            ),
        ],
      ),
      body: AmbientBackground(
        hero: true,
        child: SafeArea(
          child: switch (uiState.mode) {
            AssistantUiMode.chat => const AssistantConversationView(
              surface: 'mobile',
              autofocus: true,
            ),
            AssistantUiMode.onboarding => const AssistantOnboarding(),
            AssistantUiMode.resultsOnly => _ResultsOnlyView(
              controller: _controller,
              reason: uiState.reason,
            ),
          },
        ),
      ),
    );
  }
}

/// "Solo risultati" (§12.6): the fuzzy catalog search of step 2.4, kept as
/// router fallback — with an honest, reason-specific banner.
class _ResultsOnlyView extends ConsumerWidget {
  const _ResultsOnlyView({required this.controller, required this.reason});

  final TextEditingController controller;
  final ResultsOnlyReason reason;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _SearchField(controller: controller),
        _ResultsOnlyBanner(reason: reason),
        const Expanded(child: _Results()),
      ],
    );
  }
}

class _SearchField extends ConsumerWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: controller,
        autofocus: true,
        textInputAction: TextInputAction.search,
        onChanged: (q) => ref.read(assistantQueryProvider.notifier).set(q),
        decoration: InputDecoration(
          hintText: l10n.searchAssistantHint,
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, _) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: l10n.searchClear,
                    onPressed: () {
                      controller.clear();
                      ref.read(assistantQueryProvider.notifier).clear();
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

/// Contextual note above the results: why the chat is not active, and — when
/// the user declined the consent — a discreet way back to the onboarding.
class _ResultsOnlyBanner extends ConsumerWidget {
  const _ResultsOnlyBanner({required this.reason});

  final ResultsOnlyReason reason;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final (icon, text) = switch (reason) {
      ResultsOnlyReason.offline => (
        Icons.wifi_off_outlined,
        l10n.assistantOfflineBanner,
      ),
      ResultsOnlyReason.consentDeclined => (
        Icons.lock_outline,
        l10n.assistantResultsOnlyBanner,
      ),
      ResultsOnlyReason.unavailable => (
        Icons.cloud_off_outlined,
        l10n.assistantUnavailableBanner,
      ),
      _ => (Icons.auto_awesome, l10n.assistantBridgeNote),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.brandGold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          if (reason == ResultsOnlyReason.consentDeclined)
            TextButton(
              onPressed: () =>
                  ref.read(sessionAiConsentProvider.notifier).reset(),
              child: Text(l10n.assistantEnableCta),
            ),
        ],
      ),
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final query = ref.watch(assistantQueryProvider).trim();
    final results = ref.watch(assistantResultsProvider);

    if (query.isEmpty) {
      return _Empty(
        icon: Icons.chat_bubble_outline,
        text: l10n.assistantEmptyPrompt,
      );
    }
    if (results.isEmpty) {
      return _Empty(
        icon: Icons.search_off_outlined,
        text: l10n.searchNoResults(query),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.64,
      ),
      itemCount: results.length,
      itemBuilder: (context, i) {
        final product = results[i];
        return ProductCard(
          product: product,
          onTap: () => context.push('/product/${product.id}'),
          onAdd: () {
            ref.read(cartControllerProvider).add(product);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(l10n.addedToCart)));
          },
        );
      },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.brandGreen),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
