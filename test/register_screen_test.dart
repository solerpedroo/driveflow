import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/theme/app_theme.dart';
import 'package:driveflow/features/authentication/presentation/screens/register_screen.dart';

Future<void> _pumpRegister(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: buildDriveFlowLightTheme(),
        home: const RegisterScreen(),
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

Future<void> _enterAndContinue(WidgetTester tester, String text) async {
  final field = find.byType(TextFormField);
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
  await tester.pump();
  await _tapContinuar(tester);
}

Future<void> _goToPasswordStep(WidgetTester tester) async {
  await _tapContinuar(tester);
  await _enterAndContinue(tester, 'João Motorista');
  await _enterAndContinue(tester, 'joao@driveflow.app');
}

void main() {
  testWidgets('RegisterScreen starts on driver type step with progress', (
    tester,
  ) async {
    await _pumpRegister(tester);

    expect(find.text('1/5'), findsOneWidget);
    expect(find.text('Etapa 1 de 5'), findsOneWidget);
    expect(find.textContaining('Como você'), findsOneWidget);
    expect(find.text('Motorista de aplicativo'), findsOneWidget);
    expect(find.text('Taxista'), findsOneWidget);
    expect(find.text('Plano Pro'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
    expect(find.text('Criar conta'), findsNothing);
  });

  testWidgets('RegisterScreen advances through steps with progress update', (
    tester,
  ) async {
    await _pumpRegister(tester);

    await _tapContinuar(tester);

    expect(find.text('2/5'), findsOneWidget);
    expect(find.textContaining('seu nome'), findsOneWidget);
    expect(find.text('Voltar'), findsOneWidget);

    await _enterAndContinue(tester, 'Maria');

    expect(find.text('3/5'), findsOneWidget);
    expect(find.textContaining('seu e-mail'), findsOneWidget);
  });

  testWidgets('RegisterScreen shows password checklist on password step', (
    tester,
  ) async {
    await _pumpRegister(tester);
    await _goToPasswordStep(tester);

    expect(find.text('4/5'), findsOneWidget);
    expect(find.text('Mínimo 8 caracteres'), findsOneWidget);
    expect(find.text('Uma letra maiúscula'), findsOneWidget);

    final field = find.byType(TextFormField);
    await tester.ensureVisible(field);
    await tester.enterText(field, 'Abcdefg1');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byIcon(Icons.check_rounded), findsWidgets);
  });

  testWidgets('RegisterScreen subtitle updates when taxi is selected', (
    tester,
  ) async {
    await _pumpRegister(tester);

    final taxiInkWell = find.ancestor(
      of: find.text('Taxista'),
      matching: find.byType(InkWell),
    );
    await tester.ensureVisible(taxiInkWell);
    await tester.tap(taxiInkWell);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Modo taxista'), findsOneWidget);

    await _tapContinuar(tester);
    await _enterAndContinue(tester, 'Ana');
    await _enterAndContinue(tester, 'ana@driveflow.app');
    await _enterAndContinue(tester, 'Abcdefg1');

    expect(find.text('5/5'), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);
    expect(
      find.text('Último passo — depois montamos seu painel de taxista.'),
      findsOneWidget,
    );
  });

  testWidgets('RegisterScreen has confirm password toggle on last step', (
    tester,
  ) async {
    await _pumpRegister(tester);
    await _goToPasswordStep(tester);
    await _enterAndContinue(tester, 'Abcdefg1');

    expect(find.text('Criar conta'), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });
}
