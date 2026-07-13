import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:driveflow/core/constants/app_constants.dart';
import 'package:driveflow/core/theme/app_theme.dart';
import 'package:driveflow/features/shift/domain/entities/shift_history_entry.dart';
import 'package:driveflow/features/shift/presentation/providers/shift_history_providers.dart';
import 'package:driveflow/features/shift/presentation/screens/shift_history_screen.dart';

void main() {
  testWidgets('ShiftHistoryScreen shows empty CTA without history', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shiftHistoryStreamProvider.overrideWith(
            (ref) => Stream<List<ShiftHistoryEntry>>.value(const []),
          ),
          shiftHistoryExportControllerProvider.overrideWith(
            ShiftHistoryExportController.new,
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
          home: const ShiftHistoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nenhum turno encerrado'), findsOneWidget);
    expect(find.text('Iniciar turno'), findsOneWidget);
    expect(find.text('Exportar CSV'), findsOneWidget);
  });

  testWidgets('ShiftHistoryScreen lists entries', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
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
      revenue: 200,
      rides: 5,
      revenuePerHour: 50,
      adherenceScore: 80,
      matchedPlanBlocks: 2,
      totalPlanBlocks: 2,
      planBlocks: const [],
      revenueByPlatform: const {},
    );

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const ShiftHistoryScreen(),
        ),
        GoRoute(
          path: AppRoutes.shiftRetrospective,
          builder: (_, state) => Scaffold(
            body: Text('detail ${state.uri.queryParameters['id']}'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shiftHistoryStreamProvider.overrideWith(
            (ref) => Stream<List<ShiftHistoryEntry>>.value([entry]),
          ),
          shiftHistoryExportControllerProvider.overrideWith(
            ShiftHistoryExportController.new,
          ),
        ],
        child: MaterialApp.router(
          theme: buildDriveFlowDarkTheme(),
          locale: const Locale('pt', 'BR'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('pt', 'BR')],
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('200'), findsWidgets);
    await tester.tap(find.textContaining('200').first);
    await tester.pumpAndSettle();

    expect(find.text('detail s1'), findsOneWidget);
  });
}
