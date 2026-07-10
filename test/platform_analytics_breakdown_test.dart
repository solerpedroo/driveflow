import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/earnings/domain/entities/earning_entity.dart';
import 'package:driveflow/features/integrations/domain/services/platform_analytics_breakdown.dart';

void main() {
  test('PlatformAnalyticsBreakdown agrupa por app', () {
    final slices = PlatformAnalyticsBreakdown.fromEarnings([
      EarningEntity(
        id: '1',
        userId: 'u1',
        platform: RidePlatform.uber,
        amount: 200,
        rides: 5,
        workedHours: 4,
        date: DateTime(2026, 7, 10),
      ),
      EarningEntity(
        id: '2',
        userId: 'u1',
        platform: RidePlatform.ninetyNine,
        amount: 100,
        rides: 3,
        workedHours: 2,
        date: DateTime(2026, 7, 10),
      ),
    ]);

    expect(slices, hasLength(2));
    expect(slices.first.amount, 200);
  });
}
