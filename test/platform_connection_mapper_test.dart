import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/integrations/data/mappers/platform_connection_mapper.dart';
import 'package:driveflow/features/integrations/domain/entities/integration_status.dart';

void main() {
  group('PlatformConnectionMapper', () {
    test('fromRow mapeia conexão Supabase', () {
      final entity = PlatformConnectionMapper.fromRow({
        'id': 'c1',
        'user_id': 'u1',
        'platform': '99',
        'status': 'connected',
        'external_account_id': 'driver-99',
        'last_synced_at': '2026-07-10T12:00:00Z',
        'last_sync_error': null,
        'metadata': {'settlement_days': 3},
        'created_at': '2026-07-01T12:00:00Z',
        'updated_at': '2026-07-10T12:00:00Z',
      });

      expect(entity.platform, RidePlatform.ninetyNine);
      expect(entity.status, IntegrationStatus.connected);
      expect(entity.externalAccountId, 'driver-99');
      expect(entity.metadata['settlement_days'], 3);
    });

    test('toUpsert serializa status pending', () {
      final map = PlatformConnectionMapper.toUpsert(
        userId: 'u1',
        platform: RidePlatform.inDrive,
        status: IntegrationStatus.pending,
      );

      expect(map['platform'], 'indrive');
      expect(map['status'], 'pending');
    });
  });
}
