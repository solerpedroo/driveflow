import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/driver_type.dart';
import 'package:driveflow/core/theme/app_theme.dart';
import 'package:driveflow/features/authentication/presentation/screens/register_screen.dart';

void main() {
  testWidgets('RegisterScreen shows animated password checklist', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildDriveFlowLightTheme(),
          home: const RegisterScreen(),
        ),
      ),
    );

    expect(find.text('Cadastrar'), findsOneWidget);
    expect(find.text('Mínimo 8 caracteres'), findsOneWidget);
    expect(find.text('Uma letra maiúscula'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(2), 'Abcdefg1');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byIcon(Icons.check_rounded), findsWidgets);
  });

  testWidgets('RegisterScreen shows driver type picker', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildDriveFlowLightTheme(),
          home: const RegisterScreen(),
        ),
      ),
    );

    expect(find.text('Motorista de aplicativo'), findsOneWidget);
    expect(find.text('Taxista'), findsOneWidget);
  });

  testWidgets('RegisterScreen subtitle updates when taxi is selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildDriveFlowLightTheme(),
          home: const RegisterScreen(),
        ),
      ),
    );

    final taxiInkWell = find.ancestor(
      of: find.text('Taxista'),
      matching: find.byType(InkWell),
    );
    await tester.ensureVisible(taxiInkWell);
    await tester.tap(taxiInkWell);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.text(
        'Painel manual para taxistas — corridas, custos e lucro sem integrações.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('RegisterScreen has independent confirm password toggle', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildDriveFlowLightTheme(),
          home: const RegisterScreen(),
        ),
      ),
    );

    final visibilityButtons = find.byIcon(Icons.visibility_off_outlined);
    expect(visibilityButtons, findsNWidgets(2));
  });
}
