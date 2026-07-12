import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:driveflow/features/goals/domain/entities/goal_entity.dart';
import 'package:driveflow/features/reports/domain/entities/report_snapshot.dart';
import 'package:driveflow/features/reports/presentation/widgets/report_indicators_card.dart';
import 'package:driveflow/shared/domain/models/period_summary.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  testWidgets('ReportIndicatorsCard exibe indicadores do período', (
    tester,
  ) async {
    final report = ReportSnapshot(
      period: GoalPeriod.monthly,
      summary: const PeriodSummary(
        revenue: 1200,
        expenses: 400,
        profit: 800,
        workedHours: 32,
        rides: 18,
        kmDriven: 420,
        fuelExpense: 250,
        profitPerHour: 25,
        profitPerKm: 1.9,
        avgCostPerKm: null,
      ),
      generatedAt: DateTime(2026, 7, 12),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReportIndicatorsCard(report: report),
        ),
      ),
    );

    expect(find.text('Indicadores'), findsOneWidget);
    expect(find.text('Mensal'), findsOneWidget);
    expect(find.text('Receita'), findsOneWidget);
    expect(find.text('Lucro'), findsOneWidget);
    expect(find.text('Corridas'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.textContaining('R\$'), findsWidgets);
  });

  testWidgets('ReportIndicatorsCard oculta valores quando hideValue', (
    tester,
  ) async {
    final report = ReportSnapshot(
      period: GoalPeriod.weekly,
      summary: const PeriodSummary(
        revenue: 500,
        expenses: 100,
        profit: 400,
        workedHours: 10,
        rides: 5,
        kmDriven: 0,
        fuelExpense: 0,
        profitPerHour: null,
        profitPerKm: null,
        avgCostPerKm: null,
      ),
      generatedAt: DateTime(2026, 7, 12),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReportIndicatorsCard(report: report, hideValue: true),
        ),
      ),
    );

    expect(find.text('R\$ ••••••'), findsWidgets);
    expect(find.text('•••'), findsWidgets);
  });
}
