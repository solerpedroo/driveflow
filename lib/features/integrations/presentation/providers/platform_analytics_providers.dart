import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/utils/vehicle_scope_filter.dart';
import '../../../earnings/domain/entities/earning_entity.dart';
import '../../../earnings/presentation/providers/earnings_providers.dart';
import '../../../fuel/presentation/providers/fuel_providers.dart';
import '../../../goals/presentation/providers/goals_providers.dart';
import '../../../vehicle/presentation/providers/vehicle_providers.dart';
import '../../domain/entities/platform_consistency_snapshot.dart';
import '../../domain/entities/platform_efficiency_snapshot.dart';
import '../../domain/entities/platform_goal_progress.dart';
import '../../domain/entities/platform_heatmap_slot.dart';
import '../../domain/entities/platform_mix_simulation.dart';
import '../../domain/entities/platform_net_profit_slice.dart';
import '../../domain/entities/platform_payout_entry.dart';
import '../../domain/entities/platform_region_snapshot.dart';
import '../../domain/entities/platform_revenue_trend_point.dart';
import '../../domain/entities/platform_shift_plan.dart';
import '../../domain/entities/platform_take_rate_point.dart';
import '../../domain/entities/platform_trip_entity.dart';
import '../../domain/services/platform_analytics_breakdown.dart';
import '../../domain/services/platform_consistency_analyzer.dart';
import '../../domain/services/platform_efficiency_analyzer.dart';
import '../../domain/services/platform_goal_progress_calculator.dart';
import '../../domain/services/platform_heatmap_builder.dart';
import '../../domain/services/platform_mix_simulator.dart';
import '../../domain/services/platform_net_profit_calculator.dart';
import '../../domain/services/platform_payout_calendar_builder.dart';
import '../../domain/services/platform_region_analyzer.dart';
import '../../domain/services/platform_revenue_trend_calculator.dart';
import '../../domain/services/platform_shift_plan_builder.dart';
import '../../domain/services/platform_take_rate_trend_calculator.dart';
import 'integrations_providers.dart';
import 'platform_trips_providers.dart';
import '../../domain/services/platform_payout_rules.dart';

/// Janela do gráfico de evolução por app.
enum PlatformTrendWindow {
  days7(7, '7 dias'),
  days30(30, '30 dias'),
  days90(90, '90 dias');

  const PlatformTrendWindow(this.days, this.label);
  final int days;
  final String label;
}

final platformTrendWindowProvider =
    StateProvider<PlatformTrendWindow>((ref) => PlatformTrendWindow.days30);

final platformHeatmapFilterProvider =
    StateProvider<RidePlatform?>((ref) => null);

final platformMixUberProvider = StateProvider<double>((ref) => 40);
final platformMix99Provider = StateProvider<double>((ref) => 40);
final platformMixInDriveProvider = StateProvider<double>((ref) => 20);

List<EarningEntity> _scopedEarnings(Ref ref) {
  final earnings = ref.watch(earningsStreamProvider).valueOrNull ?? const [];
  final vehicleId = ref.watch(scopedVehicleIdProvider);
  return VehicleScopeFilter.byVehicle(
    items: earnings,
    vehicleId: vehicleId,
    vehicleIdOf: (e) => e.vehicleId,
  );
}

List<PlatformTripEntity> _scopedTrips(Ref ref) {
  final trips = ref.watch(platformTripsStreamProvider).valueOrNull ?? const [];
  final vehicleId = ref.watch(scopedVehicleIdProvider);
  return VehicleScopeFilter.byVehicle(
    items: trips,
    vehicleId: vehicleId,
    vehicleIdOf: (t) => t.vehicleId,
  );
}

final platformRevenueTrendProvider =
    Provider<AsyncValue<List<PlatformRevenueTrendPoint>>>((ref) {
  final tripsAsync = ref.watch(platformTripsStreamProvider);
  final window = ref.watch(platformTrendWindowProvider);
  final earnings = _scopedEarnings(ref);
  final trips = _scopedTrips(ref);

  if (tripsAsync.isLoading) return const AsyncLoading();
  if (tripsAsync.hasError) {
    return AsyncError(
      tripsAsync.error!,
      tripsAsync.stackTrace ?? StackTrace.current,
    );
  }

  if (trips.isNotEmpty) {
    return AsyncData(
      PlatformRevenueTrendCalculator.fromTrips(
        trips: trips,
        days: window.days,
      ),
    );
  }
  return AsyncData(
    PlatformRevenueTrendCalculator.fromEarnings(
      earnings: earnings,
      days: window.days,
    ),
  );
});

final platformTrendDeltaProvider =
    Provider<Map<RidePlatform, double>>((ref) {
  final trend = ref.watch(platformRevenueTrendProvider).valueOrNull;
  if (trend == null) return {};
  return PlatformRevenueTrendCalculator.periodDeltaByPlatform(points: trend);
});

final platformNetProfitProvider =
    Provider<AsyncValue<List<PlatformNetProfitSlice>>>((ref) {
  final tripsAsync = ref.watch(platformTripsStreamProvider);
  final fuel = ref.watch(lastFuelLogProvider);
  final trips = _scopedTrips(ref);

  if (tripsAsync.isLoading) return const AsyncLoading();
  if (tripsAsync.hasError) {
    return AsyncError(
      tripsAsync.error!,
      tripsAsync.stackTrace ?? StackTrace.current,
    );
  }

  return AsyncData(
    PlatformNetProfitCalculator.fromTrips(
      trips: trips,
      fuelCostPerKm: fuel.valueOrNull?.costPerKm ?? 0,
    ),
  );
});

final platformEfficiencyProvider =
    Provider<AsyncValue<List<PlatformEfficiencySnapshot>>>((ref) {
  final tripsAsync = ref.watch(platformTripsStreamProvider);
  final trips = _scopedTrips(ref);

  if (tripsAsync.isLoading) return const AsyncLoading();
  if (tripsAsync.hasError) {
    return AsyncError(
      tripsAsync.error!,
      tripsAsync.stackTrace ?? StackTrace.current,
    );
  }

  return AsyncData(PlatformEfficiencyAnalyzer.analyze(trips));
});

final platformTodayMixProvider =
    Provider<AsyncValue<List<PlatformRevenueSlice>>>((ref) {
  final earnings = _scopedEarnings(ref);
  final tripsAsync = ref.watch(platformTripsStreamProvider);
  final trips = _scopedTrips(ref);

  if (tripsAsync.isLoading) return const AsyncLoading();
  if (tripsAsync.hasError) {
    return AsyncError(
      tripsAsync.error!,
      tripsAsync.stackTrace ?? StackTrace.current,
    );
  }

  return AsyncData(
    PlatformAnalyticsBreakdown.todayMix(
      earnings: earnings,
      trips: trips,
    ),
  );
});

final platformHeatmapProvider =
    Provider<AsyncValue<List<PlatformHeatmapSlot>>>((ref) {
  final tripsAsync = ref.watch(platformTripsStreamProvider);
  final filter = ref.watch(platformHeatmapFilterProvider);
  final trips = _scopedTrips(ref);

  if (tripsAsync.isLoading) return const AsyncLoading();
  if (tripsAsync.hasError) {
    return AsyncError(
      tripsAsync.error!,
      tripsAsync.stackTrace ?? StackTrace.current,
    );
  }

  return AsyncData(
    PlatformHeatmapBuilder.build(
      trips: trips,
      filterPlatform: filter,
    ),
  );
});

final platformShiftPlanProvider =
    Provider<AsyncValue<PlatformShiftPlan>>((ref) {
  final heatmap = ref.watch(platformHeatmapProvider);
  final recommendation = ref.watch(platformShiftRecommendationProvider);

  return heatmap.when(
    loading: () => const AsyncLoading(),
    error: (e, st) => AsyncError(e, st),
    data: (slots) {
      final now = DateTime.now();
      if (slots.isNotEmpty) {
        return AsyncData(
          PlatformShiftPlanBuilder.build(
            slots: slots,
            currentWeekday: now.weekday,
            currentHour: now.hour,
          ),
        );
      }
      final rec = recommendation.valueOrNull;
      if (rec != null) {
        return AsyncData(
          PlatformShiftPlanBuilder.fallback(
            platform: rec.recommended,
            revenuePerHour: 0,
            currentHour: now.hour,
          ),
        );
      }
      return const AsyncData(
        PlatformShiftPlan(blocks: [], totalHours: 0, projectedRevenue: 0),
      );
    },
  );
});

final platformMixSimulationProvider =
    Provider<AsyncValue<PlatformMixSimulation>>((ref) {
  final net = ref.watch(platformNetProfitProvider);
  final uber = ref.watch(platformMixUberProvider);
  final ninetyNine = ref.watch(platformMix99Provider);
  final inDrive = ref.watch(platformMixInDriveProvider);

  return net.whenData(
    (slices) => PlatformMixSimulator.simulate(
      mixPercent: {
        RidePlatform.uber: uber,
        RidePlatform.ninetyNine: ninetyNine,
        RidePlatform.inDrive: inDrive,
      },
      netSlices: slices,
    ),
  );
});

final platformPayoutCalendarProvider =
    Provider<AsyncValue<List<PlatformPayoutEntry>>>((ref) {
  final tripsAsync = ref.watch(platformTripsStreamProvider);
  final connections = ref.watch(platformConnectionsProvider).valueOrNull ?? [];
  final overrides = PlatformPayoutRules.overridesFromConnections(connections);
  final trips = _scopedTrips(ref);

  if (tripsAsync.isLoading) return const AsyncLoading();
  if (tripsAsync.hasError) {
    return AsyncError(
      tripsAsync.error!,
      tripsAsync.stackTrace ?? StackTrace.current,
    );
  }

  return AsyncData(
    PlatformPayoutCalendarBuilder.build(
      trips: trips,
      policyOverrides: overrides,
    ),
  );
});

final platformPendingPayoutProvider = Provider<double>((ref) {
  final entries = ref.watch(platformPayoutCalendarProvider).valueOrNull;
  if (entries == null) return 0;
  return PlatformPayoutCalendarBuilder.pendingTotal(entries);
});

final platformGoalProgressProvider =
    Provider<AsyncValue<List<PlatformGoalProgress>>>((ref) {
  final goals = ref.watch(goalsStreamProvider).valueOrNull;
  final earnings = _scopedEarnings(ref);
  final tripsAsync = ref.watch(platformTripsStreamProvider);
  final trips = _scopedTrips(ref);

  if (tripsAsync.isLoading) return const AsyncLoading();
  if (tripsAsync.hasError) {
    return AsyncError(
      tripsAsync.error!,
      tripsAsync.stackTrace ?? StackTrace.current,
    );
  }

  return AsyncData(
    PlatformGoalProgressCalculator.calculate(
      goals: goals,
      earnings: earnings,
      trips: trips,
    ),
  );
});

final platformTakeRateTrendProvider =
    Provider<AsyncValue<List<PlatformTakeRatePoint>>>((ref) {
  final tripsAsync = ref.watch(platformTripsStreamProvider);
  final trips = _scopedTrips(ref);

  if (tripsAsync.isLoading) return const AsyncLoading();
  if (tripsAsync.hasError) {
    return AsyncError(
      tripsAsync.error!,
      tripsAsync.stackTrace ?? StackTrace.current,
    );
  }

  return AsyncData(
    PlatformTakeRateTrendCalculator.build(trips: trips),
  );
});

final platformRegionTopProvider =
    Provider<AsyncValue<List<PlatformRegionSnapshot>>>((ref) {
  final tripsAsync = ref.watch(platformTripsStreamProvider);
  final trips = _scopedTrips(ref);

  if (tripsAsync.isLoading) return const AsyncLoading();
  if (tripsAsync.hasError) {
    return AsyncError(
      tripsAsync.error!,
      tripsAsync.stackTrace ?? StackTrace.current,
    );
  }

  return AsyncData(PlatformRegionAnalyzer.topRegions(trips));
});

final platformConsistencyProvider =
    Provider<AsyncValue<List<PlatformConsistencySnapshot>>>((ref) {
  final tripsAsync = ref.watch(platformTripsStreamProvider);
  final trips = _scopedTrips(ref);

  if (tripsAsync.isLoading) return const AsyncLoading();
  if (tripsAsync.hasError) {
    return AsyncError(
      tripsAsync.error!,
      tripsAsync.stackTrace ?? StackTrace.current,
    );
  }

  return AsyncData(PlatformConsistencyAnalyzer.analyze(trips));
});
