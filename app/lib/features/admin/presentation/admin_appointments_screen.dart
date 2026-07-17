import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/locale_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../services/application/appointment_providers.dart';
import '../../services/application/location_providers.dart';
import '../../services/application/service_providers.dart';
import '../../services/domain/appointment.dart';
import '../../services/presentation/service_labels.dart';

/// Step 5.3 (staff side) — the booking queue per site. Staff confirm, cancel,
/// complete or flag no-show; writes are gated to staff by the security rules
/// (§5.5). A site selector switches the queue between the three pharmacies.
class AdminAppointmentsScreen extends ConsumerStatefulWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  ConsumerState<AdminAppointmentsScreen> createState() =>
      _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState
    extends ConsumerState<AdminAppointmentsScreen> {
  String? _locationId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locations = ref.watch(locationsProvider).valueOrNull ?? const [];

    _locationId ??= locations.isNotEmpty ? locations.first.id : null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminAppointmentsTitle)),
      body: Column(
        children: [
          if (locations.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: DropdownButtonFormField<String>(
                initialValue: _locationId,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: [
                  for (final l in locations)
                    DropdownMenuItem(
                      value: l.id,
                      child: Text('Farmacia ${l.name}'),
                    ),
                ],
                onChanged: (v) => setState(() => _locationId = v),
              ),
            ),
          Expanded(
            child: _locationId == null
                ? Center(child: Text(l10n.locationsEmpty))
                : _Queue(locationRef: 'locations/$_locationId'),
          ),
        ],
      ),
    );
  }
}

class _Queue extends ConsumerWidget {
  const _Queue({required this.locationRef});

  final String locationRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(locationAppointmentsProvider(locationRef));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(child: Text(l10n.genericErrorRetry)),
      data: (list) {
        if (list.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                l10n.adminAppointmentsEmpty,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, i) => _AppointmentTile(appointment: list[i]),
        );
      },
    );
  }
}

class _AppointmentTile extends ConsumerWidget {
  const _AppointmentTile({required this.appointment});

  final Appointment appointment;

  Future<void> _set(
    WidgetRef ref,
    BuildContext context,
    AppointmentStatus status,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    await ref
        .read(appointmentControllerProvider)
        .setStatus(appointment.id, status);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.adminApptUpdated)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final localeCode = ref.watch(localeProvider).languageCode;
    final services = ref.watch(servicesProvider).valueOrNull ?? const [];
    final service = {for (final s in services) s.id: s}[appointment.serviceRef
        .split('/')
        .last];
    final dateFmt = DateFormat.yMMMEd(localeCode).add_Hm();
    final s = appointment.status;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    service?.name.resolveCode(localeCode) ??
                        appointment.serviceRef.split('/').last,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(s.label(l10n)),
                ),
              ],
            ),
            if (appointment.slotStart != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(dateFmt.format(appointment.slotStart!)),
              ),
            if ((appointment.contactPhone ?? '').isNotEmpty)
              Text(l10n.adminApptContactLabel(appointment.contactPhone!)),
            if ((appointment.notes ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  appointment.notes!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (s == AppointmentStatus.requested)
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(l10n.adminApptConfirm),
                    onPressed: () =>
                        _set(ref, context, AppointmentStatus.confirmed),
                  ),
                if (s == AppointmentStatus.confirmed)
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.done_all, size: 18),
                    label: Text(l10n.adminApptComplete),
                    onPressed: () =>
                        _set(ref, context, AppointmentStatus.completed),
                  ),
                if (s == AppointmentStatus.requested ||
                    s == AppointmentStatus.confirmed) ...[
                  OutlinedButton.icon(
                    icon: const Icon(Icons.close, size: 18),
                    label: Text(l10n.adminApptCancel),
                    onPressed: () =>
                        _set(ref, context, AppointmentStatus.cancelled),
                  ),
                  TextButton(
                    onPressed: () =>
                        _set(ref, context, AppointmentStatus.noShow),
                    child: Text(l10n.adminApptNoShow),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
