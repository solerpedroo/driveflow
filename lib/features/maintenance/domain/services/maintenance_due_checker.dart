import '../entities/maintenance_entity.dart';

/// Verifica vencimento por data e quilometragem.
abstract final class MaintenanceDueChecker {
  static const kmUpcomingThreshold = 500;
  static const daysUpcomingThreshold = 14;

  static MaintenanceDueStatus check({
    required MaintenanceEntity record,
    required double currentOdometerKm,
    DateTime? now,
  }) {
    final today = _dateOnly(now ?? DateTime.now());
    var overdue = false;
    var upcoming = false;

    final dueDate = record.nextDueDate;
    if (dueDate != null) {
      final due = _dateOnly(dueDate);
      if (today.isAfter(due)) {
        overdue = true;
      } else {
        final daysLeft = due.difference(today).inDays;
        if (daysLeft <= daysUpcomingThreshold) upcoming = true;
      }
    }

    final dueKm = record.nextDueKm;
    if (dueKm != null) {
      if (currentOdometerKm >= dueKm) {
        overdue = true;
      } else {
        final kmLeft = dueKm - currentOdometerKm;
        if (kmLeft <= kmUpcomingThreshold) upcoming = true;
      }
    }

    if (!record.hasReminder) return MaintenanceDueStatus.ok;
    if (overdue) return MaintenanceDueStatus.overdue;
    if (upcoming) return MaintenanceDueStatus.upcoming;
    return MaintenanceDueStatus.ok;
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
