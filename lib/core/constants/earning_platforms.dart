import 'driver_type.dart';
import 'ride_platforms.dart';

export 'ride_platforms.dart' show RidePlatform, ridePlatformsFor;

/// Alias semântico para formulários e filtros de ganhos.
typedef EarningPlatformOption = RidePlatform;

List<EarningPlatformOption> earningPlatformsFor(DriverType driverType) {
  return ridePlatformsFor(driverType);
}
