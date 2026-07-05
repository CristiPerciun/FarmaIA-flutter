import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/baganza_effects.dart';
import '../../../../core/utils/money.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cart/application/cart_providers.dart';
import '../../../catalog/application/catalog_providers.dart';
import '../../../catalog/domain/product.dart';
import '../../application/assistant_consent.dart';
import '../../application/chat_controller.dart';
import '../../data/assistant_chat_repository.dart';
import '../../domain/chat_message.dart';

/// The conversation UI shared by the mobile full-screen page (step 4B.6) and
/// the desktop 70/30 panel (step 4B.5): AI-transparency disclaimer pinned on
/// top (§12.4), message history with verified product cards, quick-start
/// chips, input row. One contract, two surfaces (§12.6).
class AssistantConversationView extends ConsumerStatefulWidget {
  const AssistantConversationView({
    super.key,
    required this.surface,
    this.autofocus = false,
  });

  /// Telemetry tag sent to the backend ("mobile" | "desktop").
  final String surface;

  /// Focus the input on arrival (search-field entry, §12.6).
  final bool autofocus;

  @override
  ConsumerState<AssistantConversationView> createState() =>
      _AssistantConversationViewState();
}

class _AssistantConversationViewState
    extends ConsumerState<AssistantConversationView> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send([String? text]) {
    final message = (text ?? _inputController.text).trim();
    if (message.isEmpty) return;
    _inputController.clear();
    ref
        .read(chatControllerProvider.notifier)
        .send(message, surface: widget.surface);
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _escalate() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await ref.read(chatControllerProvider.notifier).escalate();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            ok ? l10n.assistantEscalationSent : l10n.assistantErrorGeneric,
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final conversation = ref.watch(chatControllerProvider);

    // Limit errors → snackbar; server-forced consent → back to onboarding.
    ref.listen(chatControllerProvider, (previous, next) {
      final error = next.transientError;
      if (error != null && previous?.transientError != error) {
        ref.read(chatControllerProvider.notifier).clearTransientError();
        final text = switch (error) {
          AssistantChatFailure.dailyLimit => l10n.assistantDailyLimit,
          AssistantChatFailure.sessionLimit => l10n.assistantSessionLimit,
          _ => l10n.assistantErrorGeneric,
        };
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(text)));
      }
      if (next.needsConsent && previous?.needsConsent != true) {
        ref.read(chatControllerProvider.notifier).consentHandled();
        ref.read(sessionAiConsentProvider.notifier).reset();
      }
      if (next.messages.length > (previous?.messages.length ?? 0)) {
        _scrollToEnd();
      }
    });

    return Column(
      children: [
        const _DisclaimerBar(),
        Expanded(
          child: conversation.messages.isEmpty
              ? _EmptyConversation(onChipTap: _send)
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  itemCount: conversation.messages.length,
                  itemBuilder: (context, i) => _MessageBubble(
                    message: conversation.messages[i],
                    canEscalate: conversation.sessionId != null,
                    onEscalate: _escalate,
                  ),
                ),
        ),
        if (conversation.sending) const _TypingIndicator(),
        _InputRow(
          controller: _inputController,
          autofocus: widget.autofocus,
          enabled: !conversation.sending,
          onSend: _send,
        ),
      ],
    );
  }
}

/// Fixed AI-transparency strip (AI Act art. 50, §12.4): badge + disclaimer.
class _DisclaimerBar extends StatelessWidget {
  const _DisclaimerBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.ambientAzure,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.assistantDisclaimer,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Welcome + quick-start chips (§12.6): three common needs plus the
/// pharmacist escalation, each just pre-fills and sends a message.
class _EmptyConversation extends StatelessWidget {
  const _EmptyConversation({required this.onChipTap});

  final void Function(String) onChipTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chips = [
      l10n.assistantQuickChipHeadache,
      l10n.assistantQuickChipCold,
      l10n.assistantQuickChipSkin,
      l10n.assistantQuickChipPharmacist,
    ];
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 56,
              color: AppColors.brandGreen,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.assistantWelcome,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final chip in chips)
                  ActionChip(
                    label: Text(chip),
                    onPressed: () => onChipTap(chip),
                    side: const BorderSide(color: AppColors.border),
                    backgroundColor: Colors.white,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends ConsumerWidget {
  const _MessageBubble({
    required this.message,
    required this.canEscalate,
    required this.onEscalate,
  });

  final ChatMessage message;
  final bool canEscalate;
  final VoidCallback onEscalate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isUser = message.role == ChatRole.user;
    final effects = BaganzaEffects.of(context);

    // Server guardrail texts arrive localized-fixed; locally-degraded turns
    // (mode fallback with empty text) and router card-only replies get their
    // copy from the client so language always follows the UI locale.
    final text = message.text.isNotEmpty
        ? message.text
        : switch (message.mode) {
            AssistantReplyMode.fallback => l10n.assistantOfflineFallback,
            AssistantReplyMode.router => l10n.assistantRouterIntro,
            _ => '',
          };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (text.isNotEmpty)
            Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isUser
                      ? AppColors.brandGreen.withValues(alpha: 0.12)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: isUser
                      ? null
                      : Border.all(color: AppColors.border),
                ),
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          if (message.redFlag)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.emergency_outlined,
                    size: 16,
                    color: AppColors.alert,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.assistantRedFlagHint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.alert,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          for (final id in message.productIds)
            _ChatProductCard(productId: id),
          if (!isUser && message.escalation && canEscalate)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TextButton.icon(
                onPressed: onEscalate,
                icon: const Icon(Icons.support_agent, size: 18),
                label: Text(l10n.assistantTalkToPharmacist),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.brandGreen,
                  animationDuration: effects.durationFast,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Compact product tile for chat replies. Rendered from the live Firestore
/// data (the backend returns verified `productRef`s, §12.3): real price,
/// photo and availability — never model-generated text. No glass here:
/// prices stay on solid backgrounds (§7.2.3).
class _ChatProductCard extends ConsumerWidget {
  const _ChatProductCard({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final products =
        ref.watch(publishedProductsProvider).valueOrNull ?? const <Product>[];
    Product? product;
    for (final p in products) {
      if (p.id == productId) {
        product = p;
        break;
      }
    }
    if (product == null) return const SizedBox.shrink();
    final found = product;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push('/product/${found.id}'),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: found.images.isEmpty
                        ? const ColoredBox(
                            color: AppColors.surface,
                            child: Icon(
                              Icons.medication_outlined,
                              color: AppColors.brandGreen,
                            ),
                          )
                        : Image.network(
                            found.images.first.url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const ColoredBox(
                              color: AppColors.surface,
                              child: Icon(
                                Icons.medication_outlined,
                                color: AppColors.brandGreen,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        found.name.resolve(locale),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        found.effectivePrice.formatMoney(
                          localeCode: locale.languageCode,
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.brandGreenDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle,
                    color: AppColors.brandGreen,
                  ),
                  tooltip: l10n.addedToCart,
                  onPressed: () {
                    ref.read(cartControllerProvider).add(found);
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(content: Text(l10n.addedToCart)),
                      );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: 40,
          child: LinearProgressIndicator(
            minHeight: 3,
            color: AppColors.brandGreen,
            backgroundColor: AppColors.ambientAzure,
          ),
        ),
      ),
    );
  }
}

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.controller,
    required this.autofocus,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool autofocus;
  final bool enabled;
  final void Function([String?]) onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                autofocus: autofocus,
                enabled: enabled,
                textInputAction: TextInputAction.send,
                onSubmitted: enabled ? (_) => onSend() : null,
                maxLength: 500,
                buildCounter:
                    (
                      context, {
                      required currentLength,
                      required isFocused,
                      maxLength,
                    }) => null,
                decoration: InputDecoration(
                  hintText: l10n.assistantInputHint,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: enabled ? () => onSend() : null,
              icon: const Icon(Icons.send),
              tooltip: l10n.assistantSend,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.brandGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
