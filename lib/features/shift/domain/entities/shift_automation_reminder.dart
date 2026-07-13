/// Lembrete automático para iniciar turno com deep link acionável.
class ShiftAutomationReminder {
  const ShiftAutomationReminder({
    required this.targetHour,
    required this.title,
    required this.body,
    required this.deepLink,
  });

  final int targetHour;
  final String title;
  final String body;
  final String deepLink;
}
