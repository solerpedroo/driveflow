import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/utils/vehicle_scope_filter.dart';
import '../../../vehicle/presentation/providers/vehicle_providers.dart';
import '../../data/repositories/platform_trips_repository_impl.dart';
import '../../domain/entities/platform_trip_entity.dart';
import '../../domain/repositories/platform_trips_repository.dart';
import '../../domain/services/platform_fee_analyzer.dart';

export '../../domain/services/platform_fee_analyzer.dart';

final platformTripsRepositoryProvider = Provider<PlatformTripsRepository>((ref) {
  return PlatformTripsRepositoryImpl();
});

final platformTripsStreamProvider =
    StreamProvider.autoDispose<List<PlatformTripEntity>>((ref) {
  return ref.watch(platformTripsRepositoryProvider).watchTrips();
});

/// Corridas filtradas pelo veículo ativo no escopo.
final platformScopedTripsProvider = Provider<List<PlatformTripEntity>>((ref) {
  final trips = ref.watch(platformTripsStreamProvider).valueOrNull ?? const [];
  final vehicleId = ref.watch(scopedVehicleIdProvider);
  return VehicleScopeFilter.byVehicle(
    items: trips,
    vehicleId: vehicleId,
    vehicleIdOf: (t) => t.vehicleId,
  );
});

final platformTripsFilterProvider =
    StateProvider<RidePlatform?>((ref) => null);

final platformTripsListProvider =
    Provider<AsyncValue<List<PlatformTripEntity>>>((ref) {
  final tripsAsync = ref.watch(platformTripsStreamProvider);
  final filter = ref.watch(platformTripsFilterProvider);
  final scoped = ref.watch(platformScopedTripsProvider);

  if (tripsAsync.isLoading) return const AsyncLoading();
  if (tripsAsync.hasError) {
    return AsyncError(
      tripsAsync.error!,
      tripsAsync.stackTrace ?? StackTrace.current,
    );
  }

  final items = filter == null
      ? scoped
      : scoped.where((t) => t.platform == filter).toList();
  return AsyncData(items);
});

final platformRecentTripsProvider =
    Provider<AsyncValue<List<PlatformTripEntity>>>((ref) {
  final tripsAsync = ref.watch(platformTripsStreamProvider);
  final scoped = ref.watch(platformScopedTripsProvider);

  if (tripsAsync.isLoading) return const AsyncLoading();
  if (tripsAsync.hasError) {
    return AsyncError(
      tripsAsync.error!,
      tripsAsync.stackTrace ?? StackTrace.current,
    );
  }

  return AsyncData(scoped.take(5).toList());
});

final platformFeeAnalysisProvider =
    Provider<AsyncValue<List<PlatformFeeSnapshot>>>((ref) {
  final tripsAsync = ref.watch(platformTripsStreamProvider);
  final scoped = ref.watch(platformScopedTripsProvider);

  if (tripsAsync.isLoading) return const AsyncLoading();
  if (tripsAsync.hasError) {
    return AsyncError(
      tripsAsync.error!,
      tripsAsync.stackTrace ?? StackTrace.current,
    );
  }

  return AsyncData(PlatformFeeAnalyzer.analyze(scoped));
});
