import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../l10n/app_localizations.dart';
import '../application/location_providers.dart';
import 'widgets/location_card.dart';

/// Step 5.1 — the site directory & selector. Each site shows contacts, hours
/// and the outward actions; tapping "select" sets the Home reference site
/// (§16.1, §16.7).
class LocationsScreen extends ConsumerWidget {
  const LocationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locations = ref.watch(locationsProvider);
    final selectedId = ref.watch(selectedLocationProvider)?.id;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.locationsTitle)),
      body: locations.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _Message(
          icon: Icons.cloud_off_outlined,
          text: l10n.locationsLoadError,
        ),
        data: (list) {
          if (list.isEmpty) {
            return _Message(
              icon: Icons.location_off_outlined,
              text: l10n.locationsEmpty,
            );
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final location in list)
                    LocationCard(
                      location: location,
                      selected: location.id == selectedId,
                      onSelect: () => ref
                          .read(selectedLocationIdProvider.notifier)
                          .select(location.id),
                    ),
                ],
              ),
            ),
          );
        },
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
