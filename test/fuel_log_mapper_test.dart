import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/app_constants.dart';
import 'package:driveflow/features/fuel/data/mappers/fuel_log_mapper.dart';
import 'package:driveflow/features/fuel/domain/entities/fuel_log_entity.dart';

void main() {
  group('FuelLogMapper', () {
    test('fromRow maps Supabase row to entity', () {
      final entity = FuelLogMapper.fromRow({
        'id': 'f1',
        'vehicle_id': 'v1',
        'user_id': 'u1',
        'station': 'Ipiranga',
        'fuel_type': 'ethanol',
        'price_per_liter': 4.5,
        'liters': 35,
        'total_amount': 157.5,
        'odometer': 52000,
        'km_per_liter': 11.2,
        'cost_per_km': 0.45,
      });

      expect(entity.fuelType, FuelType.ethanol);
      expect(entity.station, 'Ipiranga');
      expect(entity.kmPerLiter, 11.2);
    });

    test('toInsert inclui métricas calculadas', () {
      final map = FuelLogMapper.toInsert(
        userId: 'u1',
        draft: const FuelLogDraft(
          vehicleId: 'v1',
          fuelType: FuelType.gasoline,
          pricePerLiter: 6,
          liters: 30,
          totalAmount: 180,
          odometerKm: 50000,
          kmPerLiter: 12,
          costPerKm: 0.6,
        ),
      );

      expect(map['km_per_liter'], 12);
      expect(map['cost_per_km'], 0.6);
    });
  });
}
