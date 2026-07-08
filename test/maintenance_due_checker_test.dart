import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/app_constants.dart';
import 'package:driveflow/features/maintenance/domain/entities/maintenance_entity.dart';
import 'package:driveflow/features/maintenance/domain/services/maintenance_due_checker.dart';

void main() {
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

  group('MaintenanceDueChecker', () {
    test('retorna ok sem lembrete configurado', () {
      final status = MaintenanceDueChecker.check(
        record: record(),
        currentOdometerKm: 50000,
        now: DateTime(2026, 7, 8),
      );
      expect(status, MaintenanceDueStatus.ok);
    });

    test('retorna overdue quando data passou', () {
      final status = MaintenanceDueChecker.check(
        record: record(nextDueDate: DateTime(2026, 7, 1)),
        currentOdometerKm: 50000,
        now: DateTime(2026, 7, 8),
      );
      expect(status, MaintenanceDueStatus.overdue);
    });

    test('retorna upcoming quando data está dentro da tolerância', () {
      final status = MaintenanceDueChecker.check(
        record: record(nextDueDate: DateTime(2026, 7, 15)),
        currentOdometerKm: 50000,
        now: DateTime(2026, 7, 8),
      );
      expect(status, MaintenanceDueStatus.upcoming);
    });

    test('retorna overdue quando km foi excedido', () {
      final status = MaintenanceDueChecker.check(
        record: record(nextDueKm: 50000),
        currentOdometerKm: 50500,
        now: DateTime(2026, 7, 8),
      );
      expect(status, MaintenanceDueStatus.overdue);
    });

    test('retorna upcoming quando faltam poucos km', () {
      final status = MaintenanceDueChecker.check(
        record: record(nextDueKm: 50400),
        currentOdometerKm: 50000,
        now: DateTime(2026, 7, 8),
      );
      expect(status, MaintenanceDueStatus.upcoming);
    });
  });
}
