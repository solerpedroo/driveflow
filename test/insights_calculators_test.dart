import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/app_constants.dart';
import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/earnings/domain/entities/earning_entity.dart';
import 'package:driveflow/features/fuel/domain/entities/fuel_log_entity.dart';
import 'package:driveflow/features/insights/domain/services/average_km_per_day_calculator.dart';
import 'package:driveflow/features/insights/domain/services/earnings_heatmap_builder.dart';
import 'package:driveflow/features/insights/domain/services/maintenance_predictor.dart';
import 'package:driveflow/features/maintenance/domain/entities/maintenance_entity.dart';

void main() {
  group('AverageKmPerDayCalculator', () {
    test('calcula média entre abastecimentos', () {
      final result = AverageKmPerDayCalculator.compute(
        fuelLogs: [
          FuelLogEntity(
            id: 'f1',
            vehicleId: 'v1',
            userId: 'u1',
            fuelType: FuelType.gasoline,
            pricePerLiter: 5,
            liters: 40,
            totalAmount: 200,
            odometerKm: 10000,
            createdAt: DateTime(2026, 6, 1),
          ),
          FuelLogEntity(
            id: 'f2',
            vehicleId: 'v1',
            userId: 'u1',
            fuelType: FuelType.gasoline,
            pricePerLiter: 5,
            liters: 40,
            totalAmount: 200,
            odometerKm: 10300,
            createdAt: DateTime(2026, 6, 11),
          ),
        ],
        currentOdometerKm: 10300,
        now: DateTime(2026, 6, 11),
      );

      expect(result.sampleCount, 1);
      expect(result.averageKmPerDay, closeTo(30, 0.01));
    });
  });

  group('EarningsHeatmapBuilder', () {
    test('ranqueia slots com hora registrada', () {
      final anchor = DateTime(2026, 7, 8, 12);

      final slots = EarningsHeatmapBuilder.build(
        earnings: [
          EarningEntity(
            id: 'e1',
            userId: 'u1',
            platform: RidePlatform.uber,
            amount: 200,
            rides: 5,
            workedHours: 2,
            date: DateTime(2026, 7, 7, 20),
          ),
          EarningEntity(
            id: 'e2',
            userId: 'u1',
            platform: RidePlatform.ninetyNine,
            amount: 100,
            rides: 3,
            workedHours: 4,
            date: DateTime(2026, 7, 6, 10),
          ),
        ],
        now: anchor,
      );

      expect(slots, isNotEmpty);
      expect(slots.first.profitPerHour, greaterThan(slots.last.profitPerHour));
      expect(slots.first.hour, 20);
    });
  });

  group('MaintenancePredictor', () {
    MaintenanceEntity record({
      double? nextDueKm,
      DateTime? nextDueDate,
    }) {
      return MaintenanceEntity(
        id: 'm1',
        vehicleId: 'v1',
        userId: 'u1',
        type: MaintenanceType.oil,
        cost: 300,
        serviceDate: DateTime(2026, 1, 1),
        nextDueKm: nextDueKm,
        nextDueDate: nextDueDate,
      );
    }

    test('prevê data a partir de km restante e média diária', () {
      final predictions = MaintenancePredictor.predictAll(
        records: [record(nextDueKm: 52000)],
        fuelLogs: [
          FuelLogEntity(
            id: 'f1',
            vehicleId: 'v1',
            userId: 'u1',
            fuelType: FuelType.gasoline,
            pricePerLiter: 5,
            liters: 40,
            totalAmount: 200,
            odometerKm: 50000,
            createdAt: DateTime(2026, 6, 1),
          ),
          FuelLogEntity(
            id: 'f2',
            vehicleId: 'v1',
            userId: 'u1',
            fuelType: FuelType.gasoline,
            pricePerLiter: 5,
            liters: 40,
            totalAmount: 200,
            odometerKm: 50300,
            createdAt: DateTime(2026, 6, 11),
          ),
        ],
        currentOdometerKm: 50500,
        now: DateTime(2026, 7, 8),
      );

      expect(predictions, hasLength(1));
      final prediction = predictions.first;
      expect(prediction.daysUntilDue, inInclusiveRange(45, 55));
      expect(prediction.confidence, isNotNull);
    });
  });
}
