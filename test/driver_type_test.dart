import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/driver_type.dart';
import 'package:driveflow/core/constants/ride_platforms.dart';

void main() {
  group('DriverType', () {
    test('fromValue maps taxi and ride_share', () {
      expect(DriverType.fromValue('taxi'), DriverType.taxi);
      expect(DriverType.fromValue('ride_share'), DriverType.rideShare);
      expect(DriverType.fromValue(null), DriverType.rideShare);
    });

    test('role labels differ by type', () {
      expect(DriverType.taxi.roleLabel, 'Taxista');
      expect(DriverType.rideShare.roleLabel, 'Motorista');
    });
  });

  group('ridePlatformsFor', () {
    test('taxi excludes ride-share apps', () {
      final platforms = ridePlatformsFor(DriverType.taxi);

      expect(platforms, contains(RidePlatform.taximeter));
      expect(platforms, isNot(contains(RidePlatform.uber)));
      expect(platforms, isNot(contains(RidePlatform.ninetyNine)));
    });

    test('ride share includes app platforms', () {
      final platforms = ridePlatformsFor(DriverType.rideShare);

      expect(platforms, contains(RidePlatform.uber));
      expect(platforms, isNot(contains(RidePlatform.taximeter)));
    });
  });
}
