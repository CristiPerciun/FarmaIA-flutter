import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/baganza_effects.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/assistant_panel.dart';

/// Floating bottom-center pill for Home and Catalogo on desktop (≥1024 px,
/// §12.6, step 4B.5): white pill, action-green icon/border, light shadow.
/// Click opens the 70/30 panel; the badge counts replies received while the
/// panel was closed. Never covers critical content — the hosting screen
/// reserves the bottom strip.
class AssistantPill extends ConsumerWidget {
  const AssistantPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final unread = ref.watch(assistantPanelProvider.select((s) => s.unread));
    final effects = BaganzaEffects.of(context);

    Widget icon = const Icon(
      Icons.auto_awesome,
      size: 20,
      color: AppColors.brandGreen,
    );
    if (unread > 0) {
      icon = Badge(
        label: Text('$unread'),
        backgroundColor: AppColors.brandCrimson,
        child: icon,
      );
    }

    return Semantics(
      button: true,
      label: l10n.assistantPillLabel,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () => ref.read(assistantPanelProvider.notifier).show(),
          child: AnimatedContainer(
            duration: effects.durationFast,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            constraints: const BoxConstraints(maxWidth: 480),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.brandGreen.withValues(alpha: 0.5),
              ),
              boxShadow: effects.cardShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    l10n.assistantPillLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.brandGreenDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
