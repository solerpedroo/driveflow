import '../../../../core/constants/ride_platforms.dart';
import '../../domain/entities/platform_trip_entity.dart';
import '../../domain/repositories/platform_trips_repository.dart';
import '../datasources/platform_trips_remote_datasource.dart';
import '../mappers/platform_trip_mapper.dart';

class PlatformTripsRepositoryImpl implements PlatformTripsRepository {
  PlatformTripsRepositoryImpl({PlatformTripsRemoteDataSource? dataSource})
      : _remote = dataSource ?? PlatformTripsRemoteDataSource();

  final PlatformTripsRemoteDataSource _remote;

  @override
  Stream<List<PlatformTripEntity>> watchTrips({RidePlatform? platform}) {
    return _remote.watchTrips().map((rows) {
      final trips = rows.map(PlatformTripMapper.fromRow).toList();
      if (platform == null) return trips;
      return trips.where((t) => t.platform == platform).toList();
    });
  }

  @override
  Future<List<PlatformTripEntity>> fetchTrips({RidePlatform? platform}) async {
    final rows = await _remote.fetchTrips(platform: platform);
    return rows.map(PlatformTripMapper.fromRow).toList();
  }
}
