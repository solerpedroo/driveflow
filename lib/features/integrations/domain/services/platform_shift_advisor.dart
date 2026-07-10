import '../../../../core/constants/ride_platforms.dart';
import '../../../earnings/domain/entities/earning_entity.dart';
import '../entities/platform_performance_snapshot.dart';
import '../entities/platform_shift_recommendation.dart';
import 'platform_catalog.dart';
import 'platform_performance_analyzer.dart';

/// Sugere qual app abrir com base no histórico do motorista.
abstract final class PlatformShiftAdvisor {
  static const _hourSlots = [
    (label: 'Madrugada', start: 0, end: 6),
    (label: 'Manhã', start: 6, end: 12),
    (label: 'Tarde', start: 12, end: 18),
    (label: 'Noite', start: 18, end: 24),
  ];

  static PlatformShiftRecommendation? recommend({
    required List<EarningEntity> earnings,
    DateTime? at,
  }) {
    final now = at ?? DateTime.now();
    final slot = _slotForHour(now.hour);
    final slotEarnings = earnings.where((e) {
      final hour = e.date.toLocal().hour;
      return hour >= slot.start && hour < slot.end;
    }).toList();

    final snapshots = PlatformPerformanceAnalyzer.analyze(
      slotEarnings.isNotEmpty ? slotEarnings : earnings,
    ).where((s) => s.hasData && s.avgPerHour > 0).toList();

    if (snapshots.isEmpty) return null;

    final best = snapshots.first;
    final confidence = _confidence(best, snapshots);

    return PlatformShiftRecommendation(
      recommended: best.platform,
      reason: slotEarnings.isNotEmpty
          ? 'No turno da ${slot.label.toLowerCase()}, ${best.platform.label} '
              'teve melhor R\$/hora (R\$ ${best.avgPerHour.toStringAsFixed(0)}/h).'
          : '${best.platform.label} lidera seu R\$/hora geral '
              '(R\$ ${best.avgPerHour.toStringAsFixed(0)}/h).',
      confidence: confidence,
      alternatives: snapshots,
      bestHourSlot: slot.label,
    );
  }

  static ({String label, int start, int end}) _slotForHour(int hour) {
    for (final slot in _hourSlots) {
      if (hour >= slot.start && hour < slot.end) return slot;
    }
    return _hourSlots.last;
  }

  static double _confidence(
    PlatformPerformanceSnapshot best,
    List<PlatformPerformanceSnapshot> all,
  ) {
    if (all.length < 2) return 0.55;
    final second = all[1];
    if (second.avgPerHour <= 0) return 0.85;
    final gap = (best.avgPerHour - second.avgPerHour) / second.avgPerHour;
    return (0.55 + gap.clamp(0, 0.4)).clamp(0.5, 0.95);
  }

  static List<RidePlatform> missingSyncPlatforms({
    required List<EarningEntity> earnings,
    required Set<RidePlatform> connected,
    int lookbackDays = 7,
  }) {
    final cutoff = DateTime.now().subtract(Duration(days: lookbackDays));
    final recent = earnings.where((e) => e.date.isAfter(cutoff)).toList();
    final activePlatforms = recent.map((e) => e.platform).toSet();

    return PlatformCatalog.integratablePlatforms
        .where((p) => connected.contains(p) && !activePlatforms.contains(p))
        .toList();
  }
}
