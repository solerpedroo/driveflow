import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:driveflow/features/earnings/domain/entities/earning_entity.dart';
import 'package:driveflow/features/earnings/presentation/providers/earnings_providers.dart';
import 'package:driveflow/features/expenses/domain/entities/expense_entity.dart';
import 'package:driveflow/features/expenses/presentation/providers/expenses_providers.dart';
import 'package:driveflow/features/fuel/presentation/providers/fuel_providers.dart';
import 'package:driveflow/features/goals/domain/entities/goal_entity.dart';
import 'package:driveflow/features/reports/presentation/providers/reports_providers.dart';
import 'package:driveflow/features/vehicle/presentation/providers/vehicle_providers.dart';

/// Overrides para testes da feature de relatórios.
List<Override> reportsProviderOverrides({
  List<EarningEntity> earnings = const [],
  List<ExpenseEntity> expenses = const [],
  GoalPeriod period = GoalPeriod.monthly,
  String? scopedVehicleId,
}) {
  return [
    reportPeriodProvider.overrideWith((ref) => period),
    earningsStreamProvider.overrideWith((ref) => Stream.value(earnings)),
    expensesStreamProvider.overrideWith((ref) => Stream.value(expenses)),
    activeVehicleFuelLogsProvider.overrideWith((ref) => const AsyncData([])),
    scopedVehicleIdProvider.overrideWith((ref) => scopedVehicleId),
    vehiclesStreamProvider.overrideWith((ref) => Stream.value(const [])),
    activeVehicleProvider.overrideWith((ref) => const AsyncData(null)),
  ];
}
