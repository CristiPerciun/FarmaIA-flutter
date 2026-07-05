import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/breakpoints.dart';
import '../../../l10n/app_localizations.dart';
import '../application/assistant_panel.dart';

/// A search-field-shaped affordance that opens the assistant instead of
/// filtering inline (§12.6): the customer's single search entry point.
///
/// Used on Home and Negozio. On mobile, tapping the field or the lens
/// navigates to the full-screen chat page (`/assistant`) — same destination
/// as the central "Chat AI" tab. On desktop (≥1024 px) it opens the 70/30
/// panel instead (step 4B.5), keeping the page underneath.
class AssistantSearchBar extends ConsumerWidget {
  const AssistantSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      label: l10n.searchAssistantHint,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (Breakpoints.of(context).usesRail) {
            ref.read(assistantPanelProvider.notifier).show();
          } else {
            context.push('/assistant');
          }
        },
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.searchAssistantHint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
