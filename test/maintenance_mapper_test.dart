import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/app_constants.dart';
import 'package:driveflow/features/maintenance/data/mappers/maintenance_mapper.dart';
import 'package:driveflow/features/maintenance/domain/entities/maintenance_entity.dart';

void main() {
  group('MaintenanceMapper', () {
    test('fromRow maps Supabase row to entity', () {
      final entity = MaintenanceMapper.fromRow({
        'id': 'm1',
        'vehicle_id': 'v1',
        'user_id': 'u1',
        'type': 'oil',
        'cost': 280,
        'notes': 'Óleo 5W30',
        'service_date': '2026-06-01T10:00:00Z',
        'next_due_km': 55000,
        'next_due_date': '2026-12-01',
      });

      expect(entity.type, MaintenanceType.oil);
      expect(entity.cost, 280);
      expect(entity.nextDueKm, 55000);
      expect(entity.nextDueDate, DateTime(2026, 12, 1));
    });

    test('toInsert normaliza notas vazias', () {
      final map = MaintenanceMapper.toInsert(
        userId: 'u1',
        draft: MaintenanceDraft(
          vehicleId: 'v1',
          type: MaintenanceType.brakes,
          cost: 450,
          serviceDate: DateTime(2026, 7, 8),
          notes: '   ',
          nextDueDate: DateTime(2027, 1, 1),
        ),
      );

      expect(map['type'], MaintenanceType.brakes.value);
      expect(map['notes'], isNull);
      expect(map['next_due_date'], '2027-01-01');
    });
  });
}
