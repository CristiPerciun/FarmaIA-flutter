import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/launchers.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/app_button.dart';
import '../../../l10n/app_localizations.dart';
import '../application/location_providers.dart';
import '../application/service_providers.dart';
import '../domain/location.dart';
import '../domain/service.dart';
import 'service_labels.dart';

/// Step 5.2 — a service detail: price, sites, preparation and the booking
/// action, which depends on `bookingType` (§16.4–16.5). `appointment` opens the
/// booking request; `externalLink` deep-links out (never books in-app, §16.6);
/// `freeAccess` shows a walk-in note.
class ServiceDetailScreen extends ConsumerWidget {
  const ServiceDetailScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(serviceProvider(serviceId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.servicesTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.servicesLoadError)),
        data: (service) => service == null
            ? Center(child: Text(l10n.serviceNotFound))
            : _Detail(service: service),
      ),
    );
  }
}

class _Detail extends ConsumerWidget {
  const _Detail({required this.service});

  final Service service;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final localeCode = ref.watch(localeProvider).languageCode;
    final theme = Theme.of(context);
    final allLocations = ref.watch(locationsProvider).valueOrNull ?? const [];
    final sites = _resolveSites(service.availableAt, allLocations);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Text(
              service.name.resolveCode(localeCode),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.brandGreenDark,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(
                  visualDensity: VisualDensity.compact,
                  backgroundColor: AppColors.brandGreen.withValues(alpha: 0.12),
                  label: Text(service.category.label(l10n)),
                ),
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(service.bookingType.label(l10n)),
                ),
                if (service.durationMin != null)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    avatar: const Icon(Icons.schedule, size: 16),
                    label: Text(l10n.serviceDurationLabel(service.durationMin!)),
                  ),
                if (service.requiresFasting)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: AppColors.brandGold.withValues(alpha: 0.18),
                    avatar: const Icon(Icons.no_food, size: 16),
                    label: Text(l10n.serviceRequiresFasting),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              service.isFree
                  ? l10n.servicePriceFree
                  : service.price!.formatMoney(localeCode: localeCode),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.brandGreenDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (service.description.resolveCode(localeCode).isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                service.description.resolveCode(localeCode),
                style: theme.textTheme.bodyLarge,
              ),
            ],
            if (service.prep.resolveCode(localeCode).isNotEmpty) ...[
              const SizedBox(height: 20),
              _Section(title: l10n.servicePrepTitle),
              Text(
                service.prep.resolveCode(localeCode),
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (sites.isNotEmpty) ...[
              const SizedBox(height: 20),
              _Section(title: l10n.serviceAvailableAtTitle),
              for (final site in sites)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 18,
                        color: AppColors.brandGreen,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Farmacia ${site.name} · ${site.address}'),
                      ),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 28),
            _BookingAction(service: service, sites: sites),
          ],
        ),
      ),
    );
  }

  /// Maps `availableAt` ref strings ("locations/baganza2") to the [Location]
  /// objects, preserving order and dropping unknown refs.
  List<Location> _resolveSites(List<String> refs, List<Location> all) {
    final byId = {for (final l in all) l.id: l};
    return [
      for (final ref in refs)
        if (byId[ref.split('/').last] case final Location loc) loc,
    ];
  }
}

class _BookingAction extends StatelessWidget {
  const _BookingAction({required this.service, required this.sites});

  final Service service;
  final List<Location> sites;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    switch (service.bookingType) {
      case BookingType.freeAccess:
        return _InfoBanner(
          icon: Icons.directions_walk,
          text: l10n.serviceFreeAccessInfo,
        );
      case BookingType.appointment:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppButton(
              label: l10n.serviceBookAppointment,
              icon: Icons.event_available_outlined,
              onPressed: () => context.push('/services/${service.id}/book'),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.bookingDisclaimer,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        );
      case BookingType.externalLink:
        final url = service.externalUrl ?? '';
        return AppButton(
          label: l10n.serviceOpenExternal,
          icon: Icons.open_in_new,
          onPressed: url.isEmpty
              ? null
              : () async {
                  final messenger = ScaffoldMessenger.of(context);
                  if (!await Launchers.url(url)) {
                    messenger
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text(l10n.launchFailed)));
                  }
                },
        );
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    ),
  );
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.brandGreen.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.brandGreenDark),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
