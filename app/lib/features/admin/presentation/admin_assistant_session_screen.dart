import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../application/admin_assistant_providers.dart';
import '../domain/assistant_session.dart';

/// Session detail for supervision (step 4B.7): full transcript plus the
/// review actions — "risposta scorretta" (feeds prompt/red-flag revision,
/// §12.4), review note, "escalation gestita". All writes go through the
/// `assistantReview` callable.
class AdminAssistantSessionScreen extends ConsumerStatefulWidget {
  const AdminAssistantSessionScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<AdminAssistantSessionScreen> createState() =>
      _AdminAssistantSessionScreenState();
}

class _AdminAssistantSessionScreenState
    extends ConsumerState<AdminAssistantSessionScreen> {
  bool _busy = false;

  Future<void> _review({
    bool? flaggedForReview,
    String? reviewNote,
    bool? escalationHandled,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await ref
          .read(assistantReviewServiceProvider)
          .review(
            widget.sessionId,
            flaggedForReview: flaggedForReview,
            reviewNote: reviewNote,
            escalationHandled: escalationHandled,
          );
      messenger.showSnackBar(SnackBar(content: Text(l10n.adminSaved)));
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.genericErrorRetry)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _flagWrongAnswer() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.adminAssistantFlagWrong),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: l10n.adminAssistantReviewNoteHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
    controller.dispose();
    if (note == null) return;
    await _review(flaggedForReview: true, reviewNote: note);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref
        .watch(adminAssistantSessionProvider(widget.sessionId))
        .valueOrNull;
    final messages = ref.watch(
      adminAssistantMessagesProvider(widget.sessionId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${l10n.adminAssistantSession} #${session?.pseudonym ?? ''}',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          if (session != null) _SessionHeader(session: session),
          Expanded(
            child: messages.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(l10n.genericErrorRetry)),
              data: (list) => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, i) => _TranscriptBubble(item: list[i]),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _flagWrongAnswer,
                    icon: const Icon(Icons.flag_outlined, size: 18),
                    label: Text(l10n.adminAssistantFlagWrong),
                  ),
                  if (session?.flaggedForReview == true)
                    OutlinedButton.icon(
                      onPressed: _busy
                          ? null
                          : () => _review(flaggedForReview: false),
                      icon: const Icon(Icons.flag, size: 18),
                      label: Text(l10n.adminAssistantUnflag),
                    ),
                  if (session?.escalated == true &&
                      session?.escalationHandled == false)
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brandGreen,
                      ),
                      onPressed: _busy
                          ? null
                          : () => _review(escalationHandled: true),
                      icon: const Icon(Icons.task_alt, size: 18),
                      label: Text(l10n.adminAssistantMarkHandled),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionHeader extends StatelessWidget {
  const _SessionHeader({required this.session});

  final AssistantSession session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final when = session.startedAt;
    final whenText = when == null
        ? ''
        : DateFormat('dd/MM/yyyy HH:mm').format(when);
    final note = session.reviewNote;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$whenText · ${session.surface} · ${session.locale} · '
            '${session.provenanceMode} (${session.provenanceModel})',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (note != null && note.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${l10n.adminAssistantReviewNote}: $note',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.brandCrimson,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TranscriptBubble extends StatelessWidget {
  const _TranscriptBubble({required this.item});

  final AssistantSessionMessage item;

  @override
  Widget build(BuildContext context) {
    final isAssistant = item.isAssistant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isAssistant ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isAssistant
                ? Colors.white
                : AppColors.brandGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: item.redFlag ? AppColors.alert : AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.text, style: Theme.of(context).textTheme.bodyMedium),
              if (item.productIds.isNotEmpty || item.mode.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    [
                      if (item.mode.isNotEmpty) item.mode,
                      if (item.productIds.isNotEmpty)
                        item.productIds.join(', '),
                    ].join(' · '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
