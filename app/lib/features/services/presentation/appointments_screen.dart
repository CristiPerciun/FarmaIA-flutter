import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/application/auth_providers.dart';
import '../application/appointment_providers.dart';
import '../application/location_providers.dart';
import '../application/service_providers.dart';
import '../domain/appointment.dart';
import 'service_labels.dart';

/// Step 5.3 — the customer's appointments, newest first, with their status.
class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final signedIn = ref.watch(currentUserProvider) != null;
    final appointments = ref.watch(userAppointmentsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appointmentsTitle)),
      body: !signedIn
          ? _Message(icon: Icons.lock_outline, text: l10n.appointmentsSignIn)
          : appointments.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => _Message(
                icon: Icons.error_outline,
                text: l10n.genericErrorRetry,
              ),
              data: (list) => list.isEmpty
                  ? _Message(
                      icon: Icons.event_busy_outlined,
                      text: l10n.appointmentsEmpty,
                    )
                  : _AppointmentsList(appointments: list),
            ),
    );
  }
}

class _AppointmentsList extends ConsumerWidget {
  const _AppointmentsList({required this.appointments});

  final List<Appointment> appointments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeCode = ref.watch(localeProvider).languageCode;
    final services = ref.watch(servicesProvider).valueOrNull ?? const [];
    final locations = ref.watch(locationsProvider).valueOrNull ?? const [];
    final serviceById = {for (final s in services) s.id: s};
    final locationById = {for (final l in locations) l.id: l};
    final dateFmt = DateFormat.yMMMEd(localeCode).add_Hm();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          itemBuilder: (context, i) {
            final appt = appointments[i];
            final service = serviceById[appt.serviceRef.split('/').last];
            final location = locationById[appt.locationRef.split('/').last];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Text(
                  service?.name.resolveCode(localeCode) ??
                      appt.serviceRef.split('/').last,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (appt.slotStart != null)
                      Text(dateFmt.format(appt.slotStart!)),
                    if (location != null) Text('Farmacia ${location.name}'),
                    const SizedBox(height: 6),
                    _StatusChip(status: appt.status),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final AppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = switch (status) {
      AppointmentStatus.confirmed => AppColors.brandGreen,
      AppointmentStatus.completed => AppColors.brandGreenDark,
      AppointmentStatus.cancelled ||
      AppointmentStatus.noShow => AppColors.brandCrimson,
      AppointmentStatus.requested => AppColors.brandGold,
    };
    return Chip(
      visualDensity: VisualDensity.compact,
      backgroundColor: color.withValues(alpha: 0.14),
      label: Text(status.label(l10n)),
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
