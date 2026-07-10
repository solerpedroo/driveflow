import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/earnings/domain/entities/earning_entity.dart';
import 'package:driveflow/features/integrations/domain/services/platform_performance_analyzer.dart';

void main() {
  group('PlatformPerformanceAnalyzer', () {
    final earnings = [
      EarningEntity(
        id: '1',
        userId: 'u1',
        platform: RidePlatform.uber,
        amount: 300,
        rides: 10,
        workedHours: 5,
        date: DateTime(2026, 7, 10, 20),
      ),
      EarningEntity(
        id: '2',
        userId: 'u1',
        platform: RidePlatform.ninetyNine,
        amount: 200,
        rides: 8,
        workedHours: 5,
        date: DateTime(2026, 7, 10, 21),
      ),
      EarningEntity(
        id: '3',
        userId: 'u1',
        platform: RidePlatform.inDrive,
        amount: 100,
        rides: 4,
        workedHours: 4,
        date: DateTime(2026, 7, 9, 14),
      ),
    ];

    test('ordena plataformas por R$/hora', () {
      final snapshots = PlatformPerformanceAnalyzer.analyze(earnings);
      expect(snapshots.first.platform, RidePlatform.uber);
      expect(snapshots.first.avgPerHour, 60);
    });

    test('bestPerHour retorna líder', () {
      final best = PlatformPerformanceAnalyzer.bestPerHour(earnings);
      expect(best?.platform, RidePlatform.uber);
    });
  });
}
