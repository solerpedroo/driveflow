import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/app_constants.dart';
import 'package:driveflow/features/fuel/domain/entities/fuel_log_entity.dart';
import 'package:driveflow/features/fuel/domain/services/fuel_expense_linker.dart';
import 'package:driveflow/features/fuel/domain/services/fuel_metrics_calculator.dart';

void main() {
  group('FuelMetricsCalculator', () {
    test('compute km/L e custo/km com abastecimento anterior', () {
      final metrics = FuelMetricsCalculator.compute(
        odometerKm: 45100,
        liters: 40,
        totalAmount: 240,
        previousOdometerKm: 45000,
      );

      expect(metrics.kmPerLiter, 2.5);
      expect(metrics.costPerKm, closeTo(2.4, 0.001));
    });

    test('primeiro abastecimento não calcula métricas', () {
      final metrics = FuelMetricsCalculator.compute(
        odometerKm: 45000,
        liters: 40,
        totalAmount: 240,
      );

      expect(metrics.isCalculable, isFalse);
    });

    test('odômetro inválido não calcula métricas', () {
      final metrics = FuelMetricsCalculator.compute(
        odometerKm: 45000,
        liters: 40,
        totalAmount: 240,
        previousOdometerKm: 45100,
      );

      expect(metrics.isCalculable, isFalse);
    });

    test('previousOdometer retorna o maior odômetro anterior', () {
      final previous = FuelMetricsCalculator.previousOdometer(
        currentOdometerKm: 46000,
        existingLogs: const [
          FuelLogEntity(
            id: '1',
            vehicleId: 'v1',
            userId: 'u1',
            fuelType: FuelType.flex,
            pricePerLiter: 5,
            liters: 40,
            totalAmount: 200,
            odometerKm: 44000,
          ),
          FuelLogEntity(
            id: '2',
            vehicleId: 'v1',
            userId: 'u1',
            fuelType: FuelType.flex,
            pricePerLiter: 5,
            liters: 40,
            totalAmount: 200,
            odometerKm: 45000,
          ),
        ],
      );

      expect(previous, 45000);
    });

    test('rollingAverageKmPerLiter calcula média dos últimos N', () {
      final avg = FuelMetricsCalculator.rollingAverageKmPerLiter([
        _log(kmPerLiter: 10),
        _log(kmPerLiter: 12),
        _log(kmPerLiter: 8),
      ]);

      expect(avg, 10);
    });
  });

  group('FuelExpenseLinker', () {
    test('description inclui token do fuel log', () {
      final text = FuelExpenseLinker.description(
        fuelLogId: 'abc-123',
        fuelType: FuelType.gasoline,
        station: 'Shell',
      );

      expect(FuelExpenseLinker.matches(text, 'abc-123'), isTrue);
    });
  });
}

FuelLogEntity _log({required double kmPerLiter}) {
  return FuelLogEntity(
    id: 'x',
    vehicleId: 'v1',
    userId: 'u1',
    fuelType: FuelType.flex,
    pricePerLiter: 5,
    liters: 40,
    totalAmount: 200,
    odometerKm: 45000,
    kmPerLiter: kmPerLiter,
    costPerKm: 0.5,
  );
}
