import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/earnings/domain/entities/earning_entity.dart';
import 'package:driveflow/features/integrations/domain/services/platform_shift_advisor.dart';

void main() {
  group('PlatformShiftAdvisor', () {
    test('recomenda app com melhor R$/hora no turno', () {
      final earnings = [
        EarningEntity(
          id: '1',
          userId: 'u1',
          platform: RidePlatform.ninetyNine,
          amount: 180,
          rides: 6,
          workedHours: 3,
          date: DateTime(2026, 7, 10, 19),
        ),
        EarningEntity(
          id: '2',
          userId: 'u1',
          platform: RidePlatform.uber,
          amount: 90,
          rides: 3,
          workedHours: 3,
          date: DateTime(2026, 7, 10, 20),
        ),
      ];

      final rec = PlatformShiftAdvisor.recommend(
        earnings: earnings,
        at: DateTime(2026, 7, 10, 19, 30),
      );

      expect(rec?.recommended, RidePlatform.ninetyNine);
      expect(rec?.confidence, greaterThan(0.5));
    });

    test('usa hora local para rollups em UTC', () {
      final earnings = [
        EarningEntity(
          id: '1',
          userId: 'u1',
          platform: RidePlatform.uber,
          amount: 200,
          rides: 4,
          workedHours: 2,
          date: DateTime.utc(2026, 7, 11, 2),
        ),
      ];

      final rec = PlatformShiftAdvisor.recommend(
        earnings: earnings,
        at: DateTime(2026, 7, 10, 22),
      );

      expect(rec, isNotNull);
    });

    test('detecta plataformas conectadas sem dados recentes', () {
      final earnings = [
        EarningEntity(
          id: '1',
          userId: 'u1',
          platform: RidePlatform.uber,
          amount: 100,
          rides: 2,
          workedHours: 2,
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      final missing = PlatformShiftAdvisor.missingSyncPlatforms(
        earnings: earnings,
        connected: {RidePlatform.uber, RidePlatform.ninetyNine},
      );

      expect(missing, [RidePlatform.ninetyNine]);
    });
  });
}
