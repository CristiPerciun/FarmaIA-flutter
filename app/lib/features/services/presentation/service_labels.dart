import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/appointment.dart';
import '../domain/location.dart';
import '../domain/service.dart';

/// Localized labels + formatting for the Servizi module, kept in one place so
/// screens stay declarative (mirrors `order_labels.dart`).

extension ServiceCategoryLabel on ServiceCategory {
  String label(AppLocalizations l10n) => switch (this) {
    ServiceCategory.autoanalisi => l10n.serviceCategoryAutoanalisi,
    ServiceCategory.telemedicina => l10n.serviceCategoryTelemedicina,
    ServiceCategory.consulenza => l10n.serviceCategoryConsulenza,
    ServiceCategory.tampone => l10n.serviceCategoryTampone,
    ServiceCategory.cup => l10n.serviceCategoryCup,
    ServiceCategory.altro => l10n.serviceCategoryAltro,
  };
}

extension BookingTypeLabel on BookingType {
  String label(AppLocalizations l10n) => switch (this) {
    BookingType.freeAccess => l10n.serviceBookingFreeAccess,
    BookingType.appointment => l10n.serviceBookingAppointment,
    BookingType.externalLink => l10n.serviceBookingExternalLink,
  };
}

extension AppointmentStatusLabel on AppointmentStatus {
  String label(AppLocalizations l10n) => switch (this) {
    AppointmentStatus.requested => l10n.apptStatusRequested,
    AppointmentStatus.confirmed => l10n.apptStatusConfirmed,
    AppointmentStatus.completed => l10n.apptStatusCompleted,
    AppointmentStatus.cancelled => l10n.apptStatusCancelled,
    AppointmentStatus.noShow => l10n.apptStatusNoShow,
  };
}

/// Formats a weekday index (0 = Monday … 6 = Sunday, as stored in §16.5) into a
/// localized full weekday name. Anchored on 2024-01-01, a Monday.
String weekdayName(int weekday, String localeCode) {
  final date = DateTime(2024, 1, 1).add(Duration(days: weekday.clamp(0, 6)));
  return toBeginningOfSentenceCase(
    DateFormat.EEEE(localeCode).format(date),
  )!;
}

/// One-line opening-hours string for a weekday, e.g. "Lunedì · 08:30–19:30" or
/// the localized "closed" label.
String openingHoursLine(
  OpeningHours hours,
  String localeCode,
  AppLocalizations l10n,
) {
  final day = weekdayName(hours.weekday, localeCode);
  if (hours.closed || (hours.open.isEmpty && hours.close.isEmpty)) {
    return '$day · ${l10n.locationHoursClosed}';
  }
  return '$day · ${hours.open}–${hours.close}';
}
