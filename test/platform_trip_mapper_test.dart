import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/integrations/data/mappers/platform_trip_mapper.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_trip_entity.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_trip_status.dart';

void main() {
  group('PlatformTripMapper', () {
    test('fromRow mapeia corrida Supabase', () {
      final trip = PlatformTripMapper.fromRow({
        'id': 't1',
        'user_id': 'u1',
        'platform': 'indrive',
        'external_id': 'trip-abc',
        'fare_amount': 32.5,
        'tip_amount': 5,
        'platform_fee': 6.5,
        'driver_payout': 31,
        'distance_km': 8.2,
        'duration_minutes': 22,
        'started_at': '2026-07-10T18:30:00Z',
        'ended_at': '2026-07-10T18:52:00Z',
        'pickup_label': 'Centro',
        'dropoff_label': 'Aeroporto',
        'status': 'completed',
      });

      expect(trip.platform, RidePlatform.inDrive);
      expect(trip.driverPayout, 31);
      expect(trip.pickupLabel, 'Centro');
      expect(trip.status, PlatformTripStatus.completed);
    });

    test('toInsert serializa corrida', () {
      final trip = PlatformTripEntity(
        id: 'local',
        userId: 'u1',
        platform: RidePlatform.uber,
        externalId: 'ext-1',
        fareAmount: 20,
        tipAmount: 2,
        platformFee: 5,
        driverPayout: 17,
        startedAt: DateTime(2026, 7, 10, 12),
        status: PlatformTripStatus.completed,
      );

      final map = PlatformTripMapper.toInsert(userId: 'u1', trip: trip);
      expect(map['platform'], 'uber');
      expect(map['external_id'], 'ext-1');
      expect(map['driver_payout'], 17);
    });
  });
}
