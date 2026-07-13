import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/theme/app_theme.dart';
import 'package:driveflow/features/shift/domain/entities/shift_history_entry.dart';
import 'package:driveflow/features/shift/domain/entities/shift_retrospective.dart';
import 'package:driveflow/features/shift/presentation/providers/shift_history_providers.dart';
import 'package:driveflow/features/shift/presentation/screens/shift_retrospective_screen.dart';

void main() {
  testWidgets('ShiftRetrospectiveScreen shows not found for missing entry',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shiftHistoryDetailProvider('missing').overrideWith(
            (ref) => Future<ShiftHistoryEntry?>.value(null),
          ),
          shiftRetrospectiveExportControllerProvider.overrideWith(
            ShiftRetrospectiveExportController.new,
          ),
        ],
        child: MaterialApp(
          theme: buildDriveFlowDarkTheme(),
          locale: const Locale('pt', 'BR'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('pt', 'BR')],
          home: const ShiftRetrospectiveScreen(entryId: 'missing'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Turno não encontrado'), findsOneWidget);
    expect(find.text('Ver histórico'), findsOneWidget);
  });

  testWidgets('ShiftRetrospectiveScreen shows metrics and PDF export',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final entry = ShiftHistoryEntry(
      id: 's1',
      userId: 'u1',
      startedAt: DateTime(2026, 7, 13, 18),
      endedAt: DateTime(2026, 7, 13, 22),
      elapsed: const Duration(hours: 4),
      accumulatedPause: Duration.zero,
      isTaxiMode: false,
      revenue: 320,
      rides: 6,
      revenuePerHour: 80,
      adherenceScore: 90,
      matchedPlanBlocks: 1,
      totalPlanBlocks: 1,
      planBlocks: const [],
      revenueByPlatform: const {},
      blockOutcomes: const [],
    );

    final retrospective = ShiftRetrospective(
      entry: entry,
      platformBreakdown: const [],
      blockOutcomes: const [],
      insight: 'Excelente aderência ao plano.',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shiftRetrospectiveProvider('s1').overrideWith(
            (ref) => AsyncData(retrospective),
          ),
          shiftRetrospectiveExportControllerProvider.overrideWith(
            ShiftRetrospectiveExportController.new,
          ),
        ],
        child: MaterialApp(
          theme: buildDriveFlowDarkTheme(),
          locale: const Locale('pt', 'BR'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('pt', 'BR')],
          home: const ShiftRetrospectiveScreen(entryId: 's1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('320'), findsWidgets);
    expect(find.text('Exportar PDF'), findsOneWidget);
    expect(find.text('Excelente aderência'), findsOneWidget);
  });
}
