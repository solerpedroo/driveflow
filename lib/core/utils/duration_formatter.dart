/// Formata horas trabalhadas para exibição no cockpit.
abstract final class DurationFormatter {
  static String formatWorkedHours(double hours) {
    if (hours <= 0) return '0h';
    final wholeHours = hours.floor();
    final minutes = ((hours - wholeHours) * 60).round();
    if (minutes == 0) return '${wholeHours}h';
    return '${wholeHours}h ${minutes}m';
  }
}
