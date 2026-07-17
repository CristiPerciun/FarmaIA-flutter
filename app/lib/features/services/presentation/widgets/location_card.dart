import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/launchers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/location.dart';
import '../service_labels.dart';

/// A pharmacy site card: address, CUP badge, opening hours and the outward
/// actions (call / WhatsApp / map / email, §16.1). Optionally shows a
/// "select this site" action used by the Home selector (§16.7).
class LocationCard extends ConsumerWidget {
  const LocationCard({
    super.key,
    required this.location,
    this.selected = false,
    this.onSelect,
  });

  final Location location;
  final bool selected;
  final VoidCallback? onSelect;

  Future<void> _run(
    BuildContext context,
    Future<bool> Function() action,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await action();
    if (!ok) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.launchFailed)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final localeCode = ref.watch(localeProvider).languageCode;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: selected
            ? const BorderSide(color: AppColors.brandGreen, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Farmacia ${location.name}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandGreenDark,
                    ),
                  ),
                ),
                if (location.isCupPoint)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: AppColors.brandGold.withValues(alpha: 0.18),
                    label: Text(l10n.locationCupPoint),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${location.address} · ${location.zip} ${location.city} '
              '(${location.province})',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            _ContactActions(location: location, onRun: _run),
            if (location.openingHours.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                l10n.locationHoursTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              for (final h in location.openingHours)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Text(
                    openingHoursLine(h, localeCode, l10n),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
            ],
            if (onSelect != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: selected
                    ? OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.check),
                        label: Text(l10n.locationSelectorTitle),
                      )
                    : FilledButton.tonal(
                        onPressed: onSelect,
                        child: Text(l10n.locationChange),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContactActions extends StatelessWidget {
  const _ContactActions({required this.location, required this.onRun});

  final Location location;
  final Future<void> Function(BuildContext, Future<bool> Function()) onRun;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (location.phone.isNotEmpty)
          ActionChip(
            avatar: const Icon(Icons.call, size: 18),
            label: Text(l10n.locationCall),
            onPressed: () => onRun(context, () => Launchers.call(location.phone)),
          ),
        if ((location.whatsapp ?? '').isNotEmpty)
          ActionChip(
            avatar: const Icon(Icons.chat, size: 18),
            label: Text(l10n.locationWhatsApp),
            onPressed: () =>
                onRun(context, () => Launchers.whatsApp(location.whatsapp!)),
          ),
        ActionChip(
          avatar: const Icon(Icons.map_outlined, size: 18),
          label: Text(l10n.locationOpenMap),
          onPressed: () => onRun(
            context,
            () => Launchers.maps(
              lat: location.lat,
              lng: location.lng,
              query: '${location.address} ${location.city}',
            ),
          ),
        ),
        if ((location.email ?? '').isNotEmpty)
          ActionChip(
            avatar: const Icon(Icons.mail_outline, size: 18),
            label: Text(l10n.locationEmail),
            onPressed: () =>
                onRun(context, () => Launchers.email(location.email!)),
          ),
      ],
    );
  }
}
