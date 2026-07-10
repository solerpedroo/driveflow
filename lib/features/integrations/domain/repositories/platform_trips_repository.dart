import '../../../../core/constants/ride_platforms.dart';
import '../entities/platform_trip_entity.dart';

abstract class PlatformTripsRepository {
  Stream<List<PlatformTripEntity>> watchTrips({RidePlatform? platform});

  Future<List<PlatformTripEntity>> fetchTrips({RidePlatform? platform});
}
