import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:driveflow/core/presentation/providers/sync_providers.dart';
import 'package:driveflow/core/services/sync_status.dart';
import 'package:driveflow/features/authentication/domain/entities/user_entity.dart';
import 'package:driveflow/features/authentication/presentation/providers/auth_providers.dart';
import 'package:driveflow/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:driveflow/features/earnings/presentation/providers/earnings_providers.dart';
import 'package:driveflow/features/expenses/presentation/providers/expenses_providers.dart';
import 'package:driveflow/features/fuel/presentation/providers/fuel_providers.dart';
import 'package:driveflow/features/goals/domain/services/goal_progress_calculator.dart';
import 'package:driveflow/features/goals/presentation/providers/goals_providers.dart';
import 'package:driveflow/features/profile/presentation/providers/profile_providers.dart';
import 'package:driveflow/features/vehicle/presentation/providers/vehicle_providers.dart';
import 'package:driveflow/shared/domain/models/dashboard_snapshot.dart';
import 'package:driveflow/shared/domain/models/period_summary.dart';

/// Overrides compartilhados para testes do shell e abas.
List<Override> shellProviderOverrides({
  UserEntity? user = const UserEntity(
    id: 'u1',
    name: 'Driver',
    email: 'd@test.com',
  ),
}) {
  return [
    authStateProvider.overrideWith(
      (ref) => Stream.value(user),
    ),
    userProfileProvider.overrideWith(
      (ref) async => user ??
          const UserEntity(id: 'u1', name: 'Driver', email: 'd@test.com'),
    ),
    earningsStreamProvider.overrideWith((ref) => Stream.value(const [])),
    expensesStreamProvider.overrideWith((ref) => Stream.value(const [])),
    goalsStreamProvider.overrideWith((ref) => Stream.value(null)),
    activeVehicleFuelLogsProvider.overrideWith((ref) => const AsyncData([])),
    dashboardSnapshotProvider.overrideWith(
      (ref) => const AsyncData(
        DashboardSnapshot(
          today: PeriodSummary.empty,
          month: PeriodSummary.empty,
          weekProfits: [],
        ),
      ),
    ),
    goalProgressProvider.overrideWith(
      (ref, period) => AsyncData(
        GoalProgressCalculator.calculate(
          period: period,
          goals: null,
          earningsTotal: 0,
          expensesTotal: 0,
        ),
      ),
    ),
    vehiclesStreamProvider.overrideWith((ref) => Stream.value(const [])),
    activeVehicleProvider.overrideWith((ref) => const AsyncData(null)),
    isOnlineProvider.overrideWith((ref) => Stream.value(true)),
    syncStatusProvider.overrideWith((ref) => Stream.value(SyncStatus.idle)),
    pendingSyncCountProvider.overrideWith((ref) => Future.value(0)),
  ];
}
