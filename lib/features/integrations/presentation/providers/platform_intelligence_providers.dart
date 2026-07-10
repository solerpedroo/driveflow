import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/vehicle_scope_filter.dart';
import '../../../earnings/domain/entities/earning_entity.dart';
import '../../../earnings/presentation/providers/earnings_providers.dart';
import '../../../fuel/presentation/providers/fuel_providers.dart';
import '../../../vehicle/presentation/providers/vehicle_providers.dart';
import '../../domain/entities/platform_golden_hour_slot.dart';
import '../../domain/entities/platform_score_snapshot.dart';
import '../../domain/services/platform_golden_hour_analyzer.dart';
import '../../domain/services/platform_profit_per_km_analyzer.dart';
import '../../domain/services/platform_score_calculator.dart';
import 'platform_trips_providers.dart';

List<EarningEntity> _scopedEarnings(Ref ref) {
  final earnings = ref.watch(earningsStreamProvider).valueOrNull ?? const [];
  final vehicleId = ref.watch(scopedVehicleIdProvider);
  return VehicleScopeFilter.byVehicle(
    items: earnings,
    vehicleId: vehicleId,
    vehicleIdOf: (e) => e.vehicleId,
  );
}

final platformGoldenHourProvider =
    Provider<AsyncValue<PlatformGoldenHourSlot?>>((ref) {
  final tripsAsync = ref.watch(platformTripsStreamProvider);
  final earningsAsync = ref.watch(earningsStreamProvider);
  final trips = ref.watch(platformScopedTripsProvider);
  final earnings = _scopedEarnings(ref);

  if (tripsAsync.isLoading || earningsAsync.isLoading) {
    return const AsyncLoading();
  }
  if (tripsAsync.hasError) {
    return AsyncError(
      tripsAsync.error!,
      tripsAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (earningsAsync.hasError) {
    return AsyncError(
      earningsAsync.error!,
      earningsAsync.stackTrace ?? StackTrace.current,
    );
  }

  final fromTrips = PlatformGoldenHourAnalyzer.bestNow(trips: trips);
  if (fromTrips != null) return AsyncData(fromTrips);
  return AsyncData(PlatformGoldenHourAnalyzer.fromEarnings(earnings));
});

final platformScoreProvider =
    Provider<AsyncValue<List<PlatformScoreSnapshot>>>((ref) {
  final tripsAsync = ref.watch(platformTripsStreamProvider);
  final trips = ref.watch(platformScopedTripsProvider);

  if (tripsAsync.isLoading) return const AsyncLoading();
  if (tripsAsync.hasError) {
    return AsyncError(
      tripsAsync.error!,
      tripsAsync.stackTrace ?? StackTrace.current,
    );
  }

  return AsyncData(PlatformScoreCalculator.calculate(trips));
});

final platformProfitPerKmProvider =
    Provider<AsyncValue<List<PlatformProfitPerKmSnapshot>>>((ref) {
  final tripsAsync = ref.watch(platformTripsStreamProvider);
  final fuel = ref.watch(lastFuelLogProvider);
  final trips = ref.watch(platformScopedTripsProvider);

  if (tripsAsync.isLoading) return const AsyncLoading();
  if (tripsAsync.hasError) {
    return AsyncError(
      tripsAsync.error!,
      tripsAsync.stackTrace ?? StackTrace.current,
    );
  }

  return AsyncData(
    PlatformProfitPerKmAnalyzer.analyze(
      trips: trips,
      fuelCostPerKm: fuel.valueOrNull?.costPerKm ?? 0,
    ),
  );
});
