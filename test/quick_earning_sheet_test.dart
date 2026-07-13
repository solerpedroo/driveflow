import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/theme/app_theme.dart';
import 'package:driveflow/features/earnings/presentation/providers/earnings_providers.dart';
import 'package:driveflow/features/earnings/presentation/widgets/quick_earning_sheet.dart';
import 'package:driveflow/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:driveflow/core/constants/driver_type.dart';

void main() {
  testWidgets('QuickEarningSheet exige app antes de registrar valor', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          earningsControllerProvider.overrideWith(EarningsController.new),
          driverTypeProvider.overrideWithValue(DriverType.rideShare),
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
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => QuickEarningSheet.show(context),
                  child: const Text('Abrir'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Ganho rápido'), findsOneWidget);
    expect(
      find.text('Selecione o app para liberar os valores.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Uber'));
    await tester.pump();

    expect(
      find.text('Selecione o app para liberar os valores.'),
      findsNothing,
    );
    expect(find.text(r'R$ 25,00'), findsOneWidget);
  });
}
