import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/theme/app_theme.dart';
import 'package:driveflow/features/vehicle/presentation/screens/vehicle_onboarding_screen.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: buildDriveFlowLightTheme(),
        home: const VehicleOnboardingScreen(),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _tapContinuar(WidgetTester tester) async {
  final continuar = find.text('Continuar');
  await tester.ensureVisible(continuar);
  await tester.pump();
  await tester.tap(continuar);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
}

void main() {
  testWidgets('VehicleOnboardingScreen starts on brand step with progress', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('1/6'), findsOneWidget);
    expect(find.text('Etapa 1 de 6'), findsOneWidget);
    expect(find.textContaining('marca'), findsWidgets);
    expect(find.text('Continuar'), findsOneWidget);
    expect(find.text('Entrar no painel'), findsNothing);
    expect(find.text('Tudo incluso'), findsOneWidget);
  });

  testWidgets('VehicleOnboardingScreen advances through required steps', (
    tester,
  ) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextFormField), 'Toyota');
    await tester.pump();
    await _tapContinuar(tester);

    expect(find.text('2/6'), findsOneWidget);
    expect(find.textContaining('modelo'), findsWidgets);

    await tester.enterText(find.byType(TextFormField), 'Corolla');
    await tester.pump();
    await _tapContinuar(tester);

    expect(find.text('3/6'), findsOneWidget);
    expect(find.text('Voltar'), findsWidgets);
  });

  testWidgets('VehicleOnboardingScreen shows fuel pills on fuel step', (
    tester,
  ) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextFormField), 'Toyota');
    await _tapContinuar(tester);
    await tester.enterText(find.byType(TextFormField), 'Corolla');
    await _tapContinuar(tester);
    await _tapContinuar(tester); // year already filled

    expect(find.text('4/6'), findsOneWidget);
    expect(find.text('Flex'), findsOneWidget);
    expect(find.text('Gasolina'), findsOneWidget);
  });
}
