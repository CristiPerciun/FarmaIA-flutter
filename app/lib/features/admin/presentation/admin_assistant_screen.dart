import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../application/admin_assistant_providers.dart';
import '../data/admin_assistant_repository.dart';
import '../domain/assistant_session.dart';

/// Assistant supervision — conversation registry (§12.4, step 4B.7).
/// Pseudonymized list with the §12.4 filters (red-flag, flagged-for-review,
/// escalation inbox); tap opens the session detail with review actions.
class AdminAssistantScreen extends ConsumerWidget {
  const AdminAssistantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final filter = ref.watch(assistantSessionFilterProvider);
    final sessions = ref.watch(adminAssistantSessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminAssistantTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.rule_outlined),
            tooltip: l10n.adminAssistantGuardrails,
            onPressed: () => context.push('/admin/assistant/guardrails'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final f in AssistantSessionFilter.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(_filterLabel(l10n, f)),
                        selected: filter == f,
                        selectedColor: AppColors.brandGreen.withValues(
                          alpha: 0.15,
                        ),
                        onSelected: (_) => ref
                            .read(assistantSessionFilterProvider.notifier)
                            .set(f),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: sessions.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(l10n.genericErrorRetry)),
              data: (list) => list.isEmpty
                  ? Center(child: Text(l10n.adminAssistantNoSessions))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: list.length,
                      itemBuilder: (context, i) =>
                          _SessionTile(session: list[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _filterLabel(AppLocalizations l10n, AssistantSessionFilter f) =>
      switch (f) {
        AssistantSessionFilter.all => l10n.adminAssistantFilterAll,
        AssistantSessionFilter.redFlag => l10n.adminAssistantFilterRedFlag,
        AssistantSessionFilter.flagged => l10n.adminAssistantFilterFlagged,
        AssistantSessionFilter.escalations =>
          l10n.adminAssistantFilterEscalations,
      };
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});

  final AssistantSession session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final when = session.lastMessageAt;
    final whenText = when == null
        ? ''
        : DateFormat('dd/MM/yyyy HH:mm').format(when);

    return Card(
      child: ListTile(
        leading: Icon(
          session.redFlagTriggered
              ? Icons.emergency_outlined
              : Icons.chat_bubble_outline,
          color: session.redFlagTriggered
              ? AppColors.alert
              : AppColors.brandGreen,
        ),
        title: Text(
          '${l10n.adminAssistantUser} #${session.pseudonym} · $whenText',
        ),
        subtitle: Wrap(
          spacing: 6,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '${session.turnCount} ${l10n.adminAssistantTurns} · '
              '${session.surface} · ${session.provenanceMode}',
            ),
            if (session.redFlagTriggered)
              _Tag(l10n.adminAssistantTagRedFlag, AppColors.alert),
            if (session.flaggedForReview)
              _Tag(l10n.adminAssistantTagFlagged, AppColors.brandGold),
            if (session.escalated && !session.escalationHandled)
              _Tag(l10n.adminAssistantTagEscalated, AppColors.brandCrimson),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/admin/assistant/${session.id}'),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, this.color);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
