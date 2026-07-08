import '../../../fuel/domain/entities/fuel_log_entity.dart';

/// Resultado do cálculo de média de km/dia.
class AverageKmPerDayResult {
  const AverageKmPerDayResult({
    required this.averageKmPerDay,
    required this.sampleCount,
    required this.totalDays,
    required this.totalKm,
  });

  final double? averageKmPerDay;
  final int sampleCount;
  final int totalDays;
  final double totalKm;

  bool get hasEnoughData => sampleCount >= 2 && averageKmPerDay != null;
}

/// Estima km/dia a partir do histórico de abastecimentos.
abstract final class AverageKmPerDayCalculator {
  static const minDaysBetweenSamples = 1;

  static AverageKmPerDayResult compute({
    required List<FuelLogEntity> fuelLogs,
    required double currentOdometerKm,
    DateTime? now,
  }) {
    if (fuelLogs.isEmpty) {
      return const AverageKmPerDayResult(
        averageKmPerDay: null,
        sampleCount: 0,
        totalDays: 0,
        totalKm: 0,
      );
    }

    final anchor = now ?? DateTime.now();
    final sorted = [...fuelLogs]
      ..sort((a, b) {
        final aDate = a.createdAt ?? anchor;
        final bDate = b.createdAt ?? anchor;
        final byDate = aDate.compareTo(bDate);
        if (byDate != 0) return byDate;
        return a.odometerKm.compareTo(b.odometerKm);
      });

    var totalKm = 0.0;
    var totalDays = 0;
    var samples = 0;

    for (var i = 1; i < sorted.length; i++) {
      final previous = sorted[i - 1];
      final current = sorted[i];
      final kmDelta = current.odometerKm - previous.odometerKm;
      if (kmDelta <= 0) continue;

      final previousDate = previous.createdAt ?? anchor;
      final currentDate = current.createdAt ?? anchor;
      final days = currentDate.difference(previousDate).inDays;
      if (days < minDaysBetweenSamples) continue;

      totalKm += kmDelta;
      totalDays += days;
      samples++;
    }

    if (samples == 0) {
      final oldest = sorted.first;
      final oldestDate = oldest.createdAt ?? anchor;
      final daysSinceOldest = anchor.difference(oldestDate).inDays;
      final kmSinceOldest = currentOdometerKm - oldest.odometerKm;

      if (daysSinceOldest >= minDaysBetweenSamples && kmSinceOldest > 0) {
        return AverageKmPerDayResult(
          averageKmPerDay: kmSinceOldest / daysSinceOldest,
          sampleCount: 1,
          totalDays: daysSinceOldest,
          totalKm: kmSinceOldest,
        );
      }

      return AverageKmPerDayResult(
        averageKmPerDay: null,
        sampleCount: 0,
        totalDays: 0,
        totalKm: 0,
      );
    }

    return AverageKmPerDayResult(
      averageKmPerDay: totalKm / totalDays,
      sampleCount: samples,
      totalDays: totalDays,
      totalKm: totalKm,
    );
  }
}
