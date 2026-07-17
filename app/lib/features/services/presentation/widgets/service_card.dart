import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/service.dart';
import '../service_labels.dart';

/// A service summary card for the Servizi list (§16.4): name, category, booking
/// type and price. Tapping opens the detail.
class ServiceCard extends ConsumerWidget {
  const ServiceCard({super.key, required this.service, required this.onTap});

  final Service service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final localeCode = ref.watch(localeProvider).languageCode;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      service.name.resolveCode(localeCode),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    service.isFree
                        ? l10n.servicePriceFree
                        : service.price!.formatMoney(localeCode: localeCode),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.brandGreenDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Chip(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: AppColors.brandGreen.withValues(
                      alpha: 0.12,
                    ),
                    label: Text(service.category.label(l10n)),
                  ),
                  Chip(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: AppColors.surface,
                    avatar: Icon(_bookingIcon(service.bookingType), size: 16),
                    label: Text(service.bookingType.label(l10n)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _bookingIcon(BookingType type) => switch (type) {
    BookingType.freeAccess => Icons.directions_walk,
    BookingType.appointment => Icons.event_available_outlined,
    BookingType.externalLink => Icons.open_in_new,
  };
}
