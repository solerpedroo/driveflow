import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/app_constants.dart';
import 'package:driveflow/features/vehicle/data/mappers/vehicle_mapper.dart';
import 'package:driveflow/features/vehicle/domain/entities/vehicle_entity.dart';

void main() {
  group('VehicleMapper', () {
    test('fromRow maps Supabase row to entity', () {
      final entity = VehicleMapper.fromRow({
        'id': 'veh-1',
        'user_id': 'user-1',
        'brand': 'Toyota',
        'model': 'Corolla',
        'year': 2022,
        'plate': 'abc1d23',
        'fuel': 'flex',
        'tank': 50,
        'avg_consumption': 12.5,
        'odometer': 45000,
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-01-02T00:00:00Z',
      });

      expect(entity.id, 'veh-1');
      expect(entity.brand, 'Toyota');
      expect(entity.fuel, FuelType.flex);
      expect(entity.tankLiters, 50);
      expect(entity.odometerKm, 45000);
    });

    test('toInsert normalizes plate and trims text', () {
      final map = VehicleMapper.toInsert(
        userId: 'user-1',
        draft: const VehicleDraft(
          brand: '  Honda ',
          model: ' City ',
          year: 2020,
          plate: ' xyz9a88 ',
          fuel: FuelType.gasoline,
          odometerKm: 12000,
        ),
      );

      expect(map['brand'], 'Honda');
      expect(map['model'], 'City');
      expect(map['plate'], 'XYZ9A88');
      expect(map['fuel'], FuelType.gasoline.value);
    });
  });
}
