import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/location_providers.dart';

/// The Servizi hero card for the Home (§16.7): the primary entry to the Servizi
/// module, promoted to a card instead of a nav tab to keep the bar at five.
class ServicesHeroCard extends StatelessWidget {
  const ServicesHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => context.push('/services'),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.brandGreen.withValues(alpha: 0.18),
                AppColors.brandGold.withValues(alpha: 0.14),
              ],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(
                Icons.medical_services_outlined,
                size: 40,
                color: AppColors.brandGreenDark,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeServicesCardTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.brandGreenDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.homeServicesCardSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.brandGreenDark),
            ],
          ),
        ),
      ),
    );
  }
}

/// A compact summary of the user's reference site with a "change" affordance
/// (§16.7). Tapping opens the site directory/selector.
class LocationSummaryCard extends ConsumerWidget {
  const LocationSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final location = ref.watch(selectedLocationProvider);
    if (location == null) return const SizedBox.shrink();

    return Card(
      child: ListTile(
        leading: const Icon(Icons.place_outlined, color: AppColors.brandGreen),
        title: Text(
          'Farmacia ${location.name}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(location.address),
        trailing: TextButton(
          onPressed: () => context.push('/locations'),
          child: Text(l10n.locationChange),
        ),
        onTap: () => context.push('/locations'),
      ),
    );
  }
}
