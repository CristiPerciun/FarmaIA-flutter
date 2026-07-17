import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/launchers.dart';
import '../../../l10n/app_localizations.dart';
import '../application/location_providers.dart';

/// Step 5.4 — regional health-systems integration (§16.6). The app never books
/// SSN slots itself: CUPWeb / ER Salute / FSE are state systems behind SPID.
/// This screen deep-links out, explains which docs to prepare, and shows which
/// sites are FarmaCUP points.
class CupInfoScreen extends ConsumerWidget {
  const CupInfoScreen({super.key});

  // Official Emilia-Romagna / national entry points (§16.6).
  static const _cupWebUrl = 'https://www.cupweb.it';
  static const _erSaluteUrl = 'https://salute.regione.emilia-romagna.it';
  static const _fseUrl = 'https://www.fascicolo-sanitario.it';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locations = ref.watch(locationsProvider).valueOrNull ?? const [];

    Future<void> open(String url) async {
      final messenger = ScaffoldMessenger.of(context);
      if (!await Launchers.url(url)) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.launchFailed)));
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cupInfoTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.brandGold.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.brandGold),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.cupInfoIntro,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _LinkTile(
                icon: Icons.event_available_outlined,
                title: l10n.cupOpenCupWeb,
                url: _cupWebUrl,
                onOpen: open,
              ),
              _LinkTile(
                icon: Icons.health_and_safety_outlined,
                title: l10n.cupOpenErSalute,
                url: _erSaluteUrl,
                onOpen: open,
              ),
              _LinkTile(
                icon: Icons.folder_shared_outlined,
                title: l10n.cupOpenFse,
                url: _fseUrl,
                onOpen: open,
              ),
              const SizedBox(height: 20),
              _SectionTitle(l10n.cupPrepareDocsTitle),
              Text(l10n.cupPrepareDocsBody, style: theme.textTheme.bodyMedium),
              if (locations.isNotEmpty) ...[
                const SizedBox(height: 24),
                _SectionTitle(l10n.cupPointsTitle),
                for (final loc in locations)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      loc.isCupPoint
                          ? Icons.check_circle
                          : Icons.remove_circle_outline,
                      color: loc.isCupPoint
                          ? AppColors.brandGreen
                          : AppColors.textSecondary,
                    ),
                    title: Text('Farmacia ${loc.name}'),
                    subtitle: Text(
                      loc.isCupPoint ? l10n.cupPointYes : l10n.cupPointNo,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.title,
    required this.url,
    required this.onOpen,
  });

  final IconData icon;
  final String title;
  final String url;
  final Future<void> Function(String) onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppColors.brandGreen),
        title: Text(title),
        subtitle: Text(url),
        trailing: const Icon(Icons.open_in_new, size: 18),
        onTap: () => onOpen(url),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    ),
  );
}
