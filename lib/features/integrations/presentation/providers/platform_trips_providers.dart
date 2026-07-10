import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/ride_platforms.dart';
import '../../data/repositories/platform_trips_repository_impl.dart';
import '../../domain/entities/platform_trip_entity.dart';
import '../../domain/repositories/platform_trips_repository.dart';
import '../../domain/services/platform_fee_analyzer.dart';

export '../../domain/services/platform_fee_analyzer.dart';

final platformTripsRepositoryProvider = Provider<PlatformTripsRepository>((ref) {
  return PlatformTripsRepositoryImpl();
});

final platformTripsStreamProvider =
    StreamProvider<List<PlatformTripEntity>>((ref) {
  return ref.watch(platformTripsRepositoryProvider).watchTrips();
});

final platformTripsFilterProvider =
    StateProvider<RidePlatform?>((ref) => null);

final platformTripsListProvider =
    Provider<AsyncValue<List<PlatformTripEntity>>>((ref) {
  final trips = ref.watch(platformTripsStreamProvider);
  final filter = ref.watch(platformTripsFilterProvider);

  return trips.whenData((items) {
    if (filter == null) return items;
    return items.where((t) => t.platform == filter).toList();
  });
});

final platformRecentTripsProvider =
    Provider<AsyncValue<List<PlatformTripEntity>>>((ref) {
  return ref.watch(platformTripsStreamProvider).whenData(
        (items) => items.take(5).toList(),
      );
});

final platformFeeAnalysisProvider =
    Provider<AsyncValue<List<PlatformFeeSnapshot>>>((ref) {
  final trips = ref.watch(platformTripsStreamProvider);
  return trips.whenData(PlatformFeeAnalyzer.analyze);
});
