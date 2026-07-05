import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_surface.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/catalog_filter.dart';
import '../../application/catalog_providers.dart';

/// Shared filter controls (category, medicines-only, on-sale). Rendered inside
/// a glass panel on desktop and a glass bottom-sheet on mobile (§2.2).
class _FilterControls extends ConsumerWidget {
  const _FilterControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final filter = ref.watch(catalogFilterProvider);
    final notifier = ref.read(catalogFilterProvider.notifier);
    final categories = ref.watch(categoriesProvider).valueOrNull ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              l10n.catalogFilters,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Spacer(),
            if (filter.isActive)
              TextButton(
                onPressed: notifier.clear,
                child: Text(l10n.catalogClearFilters),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.catalogFilterCategory,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text(l10n.catalogAllCategories),
              selected: filter.categoryRef == null,
              onSelected: (_) => notifier.setCategory(null),
            ),
            for (final c in categories)
              ChoiceChip(
                label: Text(c.name.resolve(locale)),
                selected: filter.categoryRef == c.id,
                onSelected: (_) => notifier.setCategory(c.id),
              ),
          ],
        ),
        const Divider(height: 32),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.catalogFilterMedicinesOnly),
          value: filter.medicinesOnly,
          activeThumbColor: AppColors.brandGreen,
          onChanged: (_) => notifier.toggleMedicinesOnly(),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.catalogFilterOnSale),
          value: filter.onSale,
          activeThumbColor: AppColors.brandGreen,
          onChanged: (_) => notifier.toggleOnSale(),
        ),
      ],
    );
  }
}

/// Desktop side panel — a persistent glass surface next to the grid.
class CatalogFilterPanel extends StatelessWidget {
  const CatalogFilterPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const GlassSurface(
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(child: _FilterControls()),
    );
  }
}

/// Mobile bottom-sheet variant of the same controls.
class CatalogFilterSheet extends StatelessWidget {
  const CatalogFilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 12,
        top: 12,
      ),
      child: GlassSurface(
        solidFallback: true,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _FilterControls(),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandGreen,
                ),
                child: Text(l10n.catalogApplyFilters),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
