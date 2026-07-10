import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../earnings/presentation/providers/earnings_providers.dart';
import '../../../fuel/presentation/providers/fuel_providers.dart';
import '../../domain/entities/platform_golden_hour_slot.dart';
import '../../domain/entities/platform_score_snapshot.dart';
import '../../domain/services/platform_golden_hour_analyzer.dart';
import '../../domain/services/platform_profit_per_km_analyzer.dart';
import '../../domain/services/platform_score_calculator.dart';
import 'platform_trips_providers.dart';

final platformGoldenHourProvider =
    Provider<AsyncValue<PlatformGoldenHourSlot?>>((ref) {
  final trips = ref.watch(platformTripsStreamProvider);
  final earnings = ref.watch(earningsStreamProvider);

  return trips.when(
    loading: () => const AsyncLoading(),
    error: (e, st) => AsyncError(e, st),
    data: (tripList) {
      final fromTrips = PlatformGoldenHourAnalyzer.bestNow(trips: tripList);
      if (fromTrips != null) return AsyncData(fromTrips);
      return earnings.whenData(PlatformGoldenHourAnalyzer.fromEarnings);
    },
  );
});

final platformScoreProvider =
    Provider<AsyncValue<List<PlatformScoreSnapshot>>>((ref) {
  final trips = ref.watch(platformTripsStreamProvider);
  return trips.whenData(PlatformScoreCalculator.calculate);
});

final platformProfitPerKmProvider =
    Provider<AsyncValue<List<PlatformProfitPerKmSnapshot>>>((ref) {
  final trips = ref.watch(platformTripsStreamProvider);
  final fuel = ref.watch(lastFuelLogProvider);

  return trips.whenData((tripList) {
    final costPerKm = fuel.valueOrNull?.costPerKm ?? 0;
    return PlatformProfitPerKmAnalyzer.analyze(
      trips: tripList,
      fuelCostPerKm: costPerKm,
    );
  });
});
