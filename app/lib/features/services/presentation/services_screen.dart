import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../l10n/app_localizations.dart';
import '../application/service_providers.dart';
import 'service_labels.dart';
import 'widgets/service_card.dart';

/// Step 5.2 — the Servizi catalog: category filter chips over a list of active
/// services (§16.4). Reachable from the Home hero card (§16.7).
class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final services = ref.watch(filteredServicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.servicesTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_hospital_outlined),
            tooltip: l10n.cupInfoTitle,
            onPressed: () => context.push('/cup-info'),
          ),
          IconButton(
            icon: const Icon(Icons.event_note_outlined),
            tooltip: l10n.appointmentsTitle,
            onPressed: () => context.push('/appointments'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CategoryChips(),
          Expanded(
            child: services.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, _) => _Message(
                icon: Icons.cloud_off_outlined,
                text: l10n.servicesLoadError,
              ),
              data: (list) {
                if (list.isEmpty) {
                  return _Message(
                    icon: Icons.medical_services_outlined,
                    text: l10n.servicesEmpty,
                  );
                }
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: list.length,
                      itemBuilder: (context, i) => ServiceCard(
                        service: list[i],
                        onTap: () => context.push('/services/${list[i].id}'),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final categories = ref.watch(availableServiceCategoriesProvider);
    final selected = ref.watch(serviceCategoryFilterProvider);

    if (categories.isEmpty) return const SizedBox(height: 8);

    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(l10n.serviceAllCategories),
              selected: selected == null,
              onSelected: (_) =>
                  ref.read(serviceCategoryFilterProvider.notifier).set(null),
            ),
          ),
          for (final category in categories)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(category.label(l10n)),
                selected: selected == category,
                onSelected: (_) => ref
                    .read(serviceCategoryFilterProvider.notifier)
                    .set(category),
              ),
            ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return AmbientBackground(
      child: Center(
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
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
