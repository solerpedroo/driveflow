import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/utils/vehicle_scope_filter.dart';

void main() {
  group('VehicleScopeFilter', () {
    test('byVehicle returns all items when scope is null', () {
      final items = [
        _Item('a', null),
        _Item('b', 'v1'),
      ];

      final result = VehicleScopeFilter.byVehicle(
        items: items,
        vehicleId: null,
        vehicleIdOf: (i) => i.vehicleId,
      );

      expect(result, hasLength(2));
    });

    test('byVehicle filters to matching vehicle id', () {
      final items = [
        _Item('a', null),
        _Item('b', 'v1'),
        _Item('c', 'v2'),
      ];

      final result = VehicleScopeFilter.byVehicle(
        items: items,
        vehicleId: 'v1',
        vehicleIdOf: (i) => i.vehicleId,
      );

      expect(result.map((e) => e.id), ['b']);
    });
  });
}

class _Item {
  const _Item(this.id, this.vehicleId);

  final String id;
  final String? vehicleId;
}
