import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/shift/domain/entities/shift_history_entry.dart';
import 'package:driveflow/features/shift/domain/services/shift_history_exporter.dart';

void main() {
  test('buildCsv includes header and entry row', () {
    final csv = ShiftHistoryExporter.buildCsv([
      ShiftHistoryEntry(
        id: 's1',
        userId: 'u1',
        startedAt: DateTime(2026, 7, 13, 18),
        endedAt: DateTime(2026, 7, 13, 22),
        elapsed: const Duration(hours: 3, minutes: 45),
        accumulatedPause: Duration.zero,
        isTaxiMode: false,
        revenue: 250,
        rides: 6,
        revenuePerHour: 66.67,
        adherenceScore: 80,
        matchedPlanBlocks: 4,
        totalPlanBlocks: 5,
        planBlocks: const [],
        revenueByPlatform: const {RidePlatform.uber: 250},
      ),
    ]);

    expect(csv.startsWith('Início,Fim,Duração'), isTrue);
    expect(csv.contains('250'), isTrue);
    expect(csv.contains('80.0'), isTrue);
  });
}
