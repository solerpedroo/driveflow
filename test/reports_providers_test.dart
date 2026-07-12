import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:driveflow/core/constants/app_constants.dart';
import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/earnings/domain/entities/earning_entity.dart';
import 'package:driveflow/features/expenses/domain/entities/expense_entity.dart';
import 'package:driveflow/features/goals/domain/entities/goal_entity.dart';
import 'package:driveflow/features/earnings/presentation/providers/earnings_providers.dart';
import 'package:driveflow/features/expenses/presentation/providers/expenses_providers.dart';
import 'package:driveflow/features/reports/presentation/providers/reports_providers.dart';

import 'support/reports_provider_overrides.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  EarningEntity earning({
    required DateTime date,
    double amount = 500,
    String? vehicleId,
  }) {
    return EarningEntity(
      id: 'e1',
      userId: 'u1',
      platform: RidePlatform.uber,
      amount: amount,
      rides: 4,
      workedHours: 6,
      date: date,
      vehicleId: vehicleId,
    );
  }

  ExpenseEntity expense({
    required DateTime date,
    double amount = 120,
    String? vehicleId,
  }) {
    return ExpenseEntity(
      id: 'x1',
      userId: 'u1',
      category: ExpenseCategory.fuel,
      amount: amount,
      date: date,
      vehicleId: vehicleId,
    );
  }

  test('reportSnapshotProvider agrega lucro do período mensal', () async {
    final now = DateTime.now();
    final earnings = [
      earning(date: now, amount: 800),
      earning(date: DateTime(now.year - 1, now.month, now.day), amount: 200),
    ];
    final expenses = [expense(date: now, amount: 150)];

    final container = ProviderContainer(
      overrides: reportsProviderOverrides(
        earnings: earnings,
        expenses: expenses,
        period: GoalPeriod.monthly,
      ),
    );
    addTearDown(container.dispose);

    await container.read(earningsStreamProvider.future);
    await container.read(expensesStreamProvider.future);

    final snapshot = container.read(reportSnapshotProvider).requireValue;

    expect(snapshot.period, GoalPeriod.monthly);
    expect(snapshot.summary.revenue, 800);
    expect(snapshot.summary.expenses, 150);
    expect(snapshot.summary.profit, 650);
    expect(snapshot.summary.rides, 4);
  });

  test('reportSnapshotProvider respeita escopo de veículo', () async {
    final now = DateTime.now();
    final earnings = [
      earning(date: now, amount: 300, vehicleId: 'v1'),
      earning(date: now, amount: 700, vehicleId: 'v2'),
    ];

    final container = ProviderContainer(
      overrides: reportsProviderOverrides(
        earnings: earnings,
        scopedVehicleId: 'v1',
      ),
    );
    addTearDown(container.dispose);

    await container.read(earningsStreamProvider.future);
    await container.read(expensesStreamProvider.future);

    final snapshot = container.read(reportSnapshotProvider).requireValue;

    expect(snapshot.summary.revenue, 300);
    expect(snapshot.summary.profit, 300);
  });

  test('reportEarningsProvider filtra por data do período', () async {
    final now = DateTime.now();
    final earnings = [
      earning(date: now),
      earning(date: DateTime(now.year - 1, now.month, now.day)),
    ];

    final container = ProviderContainer(
      overrides: reportsProviderOverrides(earnings: earnings),
    );
    addTearDown(container.dispose);

    await container.read(earningsStreamProvider.future);

    final scoped = container.read(reportEarningsProvider).requireValue;

    expect(scoped, hasLength(1));
    expect(scoped.first.amount, 500);
  });
}
