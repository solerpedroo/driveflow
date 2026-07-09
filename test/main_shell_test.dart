import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/driveflow_tab_count.dart';
import 'package:driveflow/core/presentation/providers/sync_providers.dart';
import 'package:driveflow/core/services/sync_status.dart';
import 'package:driveflow/core/theme/app_theme.dart';
import 'package:driveflow/features/authentication/domain/entities/user_entity.dart';
import 'package:driveflow/features/authentication/presentation/providers/auth_providers.dart';
import 'package:driveflow/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:driveflow/features/dashboard/presentation/screens/main_shell_screen.dart';
import 'package:driveflow/features/earnings/presentation/providers/earnings_providers.dart';
import 'package:driveflow/features/expenses/presentation/providers/expenses_providers.dart';
import 'package:driveflow/features/fuel/presentation/providers/fuel_providers.dart';
import 'package:driveflow/features/goals/domain/entities/goal_entity.dart';
import 'package:driveflow/features/goals/domain/services/goal_progress_calculator.dart';
import 'package:driveflow/features/goals/presentation/providers/goals_providers.dart';
import 'package:driveflow/shared/domain/models/dashboard_snapshot.dart';
import 'package:driveflow/shared/domain/models/period_summary.dart';
import 'package:driveflow/features/profile/presentation/providers/profile_providers.dart';
import 'package:driveflow/features/vehicle/presentation/providers/vehicle_providers.dart';
import 'package:driveflow/shared/widgets/driveflow_bottom_nav_bar.dart';

void main() {
  testWidgets('MainShellScreen switches tabs via bottom nav', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(
              const UserEntity(id: 'u1', name: 'Driver', email: 'd@test.com'),
            ),
          ),
          userProfileProvider.overrideWith(
            (ref) async => const UserEntity(
              id: 'u1',
              name: 'Driver',
              email: 'd@test.com',
            ),
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
          isOnlineProvider.overrideWith((ref) => Stream.value(true)),
          syncStatusProvider.overrideWith((ref) => Stream.value(SyncStatus.idle)),
          pendingSyncCountProvider.overrideWith((ref) => Future.value(0)),
        ],
        child: MaterialApp(
          theme: buildDriveFlowDarkTheme(),
          home: const MainShellScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('COCKPIT ATIVO'), findsOneWidget);
    expect(find.text('GANHOS'), findsOneWidget);

    await tester.tap(find.text('GANHOS'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Ganhos'), findsWidgets);

    await tester.tap(find.text('PERFIL'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Perfil'), findsOneWidget);
    expect(find.byType(DriveFlowBottomNavBar), findsOneWidget);
  });

  testWidgets('MainShellScreen opens profile tab when requested', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(
              const UserEntity(id: 'u1', name: 'Driver', email: 'd@test.com'),
            ),
          ),
          userProfileProvider.overrideWith(
            (ref) async => const UserEntity(
              id: 'u1',
              name: 'Driver',
              email: 'd@test.com',
            ),
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
          isOnlineProvider.overrideWith((ref) => Stream.value(true)),
          syncStatusProvider.overrideWith((ref) => Stream.value(SyncStatus.idle)),
          pendingSyncCountProvider.overrideWith((ref) => Future.value(0)),
        ],
        child: MaterialApp(
          theme: buildDriveFlowDarkTheme(),
          home: const MainShellScreen(initialTab: DriveFlowTab.profile),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Meus veículos'), findsOneWidget);
  });
}
