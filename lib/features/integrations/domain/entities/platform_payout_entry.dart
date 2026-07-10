import '../../../../core/constants/ride_platforms.dart';

/// Entrada no calendário de repasses estimados.
class PlatformPayoutEntry {
  const PlatformPayoutEntry({
    required this.platform,
    required this.expectedDate,
    required this.amount,
    required this.tripCount,
    required this.settlementDays,
  });

  final RidePlatform platform;
  final DateTime expectedDate;
  final double amount;
  final int tripCount;
  final int settlementDays;

  bool get isOverdue => expectedDate.isBefore(DateTime.now());
}
