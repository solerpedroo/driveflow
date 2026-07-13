import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/theme/app_theme.dart';
import 'package:driveflow/features/shift/domain/entities/shift_session_entity.dart';
import 'package:driveflow/features/shift/presentation/providers/shift_session_providers.dart';
import 'package:driveflow/features/shift/presentation/screens/shift_mode_screen.dart';

void main() {
  testWidgets('ShiftModeScreen shows start CTA without active session', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeShiftSessionProvider.overrideWith(
            (ref) => Stream<ShiftSessionEntity?>.value(null),
          ),
          shiftSessionControllerProvider.overrideWith(ShiftSessionController.new),
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
          home: const ShiftModeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Modo turno'), findsOneWidget);
    expect(find.text('Iniciar turno'), findsOneWidget);
  });
}
