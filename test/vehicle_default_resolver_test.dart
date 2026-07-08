import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/app_constants.dart';
import 'package:driveflow/features/vehicle/domain/entities/vehicle_entity.dart';
import 'package:driveflow/features/vehicle/domain/services/vehicle_default_resolver.dart';

void main() {
  group('VehicleDefaultResolver', () {
    final vehicles = [
      const VehicleEntity(
        id: 'v1',
        userId: 'u1',
        brand: 'Toyota',
        model: 'Corolla',
        year: 2020,
        fuel: FuelType.flex,
        odometerKm: 10000,
        isDefault: true,
      ),
      const VehicleEntity(
        id: 'v2',
        userId: 'u1',
        brand: 'Honda',
        model: 'City',
        year: 2021,
        fuel: FuelType.flex,
        odometerKm: 5000,
      ),
    ];

    test('resolve prefers stored id when valid', () {
      final resolved = VehicleDefaultResolver.resolve(
        vehicles: vehicles,
        preferredId: 'v2',
      );
      expect(resolved?.id, 'v2');
    });

    test('resolve falls back to default vehicle', () {
      final resolved = VehicleDefaultResolver.resolve(
        vehicles: vehicles,
        preferredId: 'missing',
      );
      expect(resolved?.id, 'v1');
    });

    test('nextDefaultAfterDelete returns first remaining vehicle', () {
      final next = VehicleDefaultResolver.nextDefaultAfterDelete(
        vehicles: vehicles,
        deletedId: 'v1',
      );
      expect(next?.id, 'v2');
    });
  });
}
