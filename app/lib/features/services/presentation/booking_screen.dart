import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/application/auth_providers.dart';
import '../application/appointment_providers.dart';
import '../application/location_providers.dart';
import '../application/service_providers.dart';
import '../domain/location.dart';
import '../domain/service.dart';

/// Step 5.3 — the slot request form. The customer picks a site (among the
/// service's `availableAt`), a date and a time; on submit an appointment with
/// `status == 'requested'` is created. Staff confirm it later (§16.4). Signed-
/// out users are asked to sign in first.
class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  String? _locationRef;
  DateTime? _date;
  TimeOfDay? _time;
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  bool _submitting = false;
  bool _phonePrefilled = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final signedIn = ref.watch(currentUserProvider) != null;
    final async = ref.watch(serviceProvider(widget.serviceId));

    // Prefill the contact phone from the profile once.
    final phone = ref.watch(appUserProvider).valueOrNull?.phone;
    if (!_phonePrefilled && phone != null && phone.isNotEmpty) {
      _phoneController.text = phone;
      _phonePrefilled = true;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingTitle)),
      body: !signedIn
          ? _Centered(
              icon: Icons.lock_outline,
              text: l10n.bookingSignInRequired,
              action: AppButton(
                label: l10n.signIn,
                onPressed: () => context.go('/login'),
              ),
            )
          : async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(child: Text(l10n.servicesLoadError)),
              data: (service) => service == null
                  ? Center(child: Text(l10n.serviceNotFound))
                  : _buildForm(context, service),
            ),
    );
  }

  Widget _buildForm(BuildContext context, Service service) {
    final l10n = AppLocalizations.of(context)!;
    final localeCode = ref.watch(localeProvider).languageCode;
    final allLocations = ref.watch(locationsProvider).valueOrNull ?? const [];
    final sites = _resolveSites(service.availableAt, allLocations);

    // Default the site: prefer the user's reference site when eligible.
    if (_locationRef == null && sites.isNotEmpty) {
      final preferred = ref.read(selectedLocationProvider);
      final match = sites.firstWhere(
        (s) => s.id == preferred?.id,
        orElse: () => sites.first,
      );
      _locationRef = 'locations/${match.id}';
    }

    final dateFmt = DateFormat.yMMMMd(localeCode);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              service.name.resolveCode(localeCode),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.brandGreenDark,
              ),
            ),
            const SizedBox(height: 20),
            if (sites.length > 1) ...[
              Text(l10n.bookingChooseLocation),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _locationRef,
                items: [
                  for (final site in sites)
                    DropdownMenuItem(
                      value: 'locations/${site.id}',
                      child: Text('Farmacia ${site.name}'),
                    ),
                ],
                onChanged: (v) => setState(() => _locationRef = v),
              ),
              const SizedBox(height: 16),
            ] else if (sites.length == 1) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.place_outlined,
                  color: AppColors.brandGreen,
                ),
                title: Text(l10n.bookingChooseLocation),
                subtitle: Text('Farmacia ${sites.first.name}'),
              ),
            ],
            Row(
              children: [
                Expanded(
                  child: _PickerTile(
                    label: l10n.bookingChooseDate,
                    value: _date == null ? l10n.bookingPickDate : dateFmt
                        .format(_date!),
                    icon: Icons.calendar_today_outlined,
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PickerTile(
                    label: l10n.bookingChooseTime,
                    value: _time == null
                        ? l10n.bookingPickTime
                        : _time!.format(context),
                    icon: Icons.schedule,
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: l10n.bookingContactPhone,
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.bookingNotes,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: l10n.bookingSubmit,
              icon: Icons.send_outlined,
              isLoading: _submitting,
              onPressed: () => _submit(service),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.bookingDisclaimer,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _submit(Service service) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    if (_locationRef == null || _date == null || _time == null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.bookingIncomplete)));
      return;
    }

    final start = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );
    final end = start.add(Duration(minutes: service.durationMin ?? 30));

    setState(() => _submitting = true);
    try {
      await ref
          .read(appointmentControllerProvider)
          .requestSlot(
            serviceRef: 'services/${service.id}',
            locationRef: _locationRef!,
            slotStart: start,
            slotEnd: end,
            contactPhone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.bookingSubmitted)));
      router.go('/appointments');
    } catch (_) {
      if (mounted) setState(() => _submitting = false);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.bookingError)));
    }
  }

  List<Location> _resolveSites(List<String> refs, List<Location> all) {
    final byId = {for (final l in all) l.id: l};
    return [
      for (final ref in refs)
        if (byId[ref.split('/').last] case final Location loc) loc,
    ];
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        child: Text(value, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({
    required this.icon,
    required this.text,
    required this.action,
  });

  final IconData icon;
  final String text;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Center(
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
            const SizedBox(height: 24),
            action,
          ],
        ),
      ),
    );
  }
}
