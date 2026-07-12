import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/earnings/domain/entities/earning_entity.dart';
import 'package:driveflow/features/reports/presentation/screens/reports_screen.dart';

import 'support/app_test_harness.dart';
import 'support/reports_provider_overrides.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  testWidgets('ReportsScreen exibe hero e ações de exportação', (tester) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('overflowed')) return;
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final now = DateTime.now();
    final earnings = [
      EarningEntity(
        id: 'e1',
        userId: 'u1',
        platform: RidePlatform.uber,
        amount: 600,
        rides: 3,
        workedHours: 4,
        date: now,
      ),
    ];

    await tester.pumpWidget(
      localizedTestApp(
        overrides: reportsProviderOverrides(earnings: earnings),
        child: const SizedBox(
          height: 2400,
          width: 800,
          child: ReportsScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Relatórios'), findsOneWidget);
    expect(find.text('Lucro no período'), findsOneWidget);
    expect(find.text('PDF'), findsOneWidget);
    expect(find.text('CSV'), findsOneWidget);
    expect(find.text('Indicadores'), findsOneWidget);
    expect(find.text('Filtros'), findsOneWidget);
  });
}
