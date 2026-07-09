import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

    expect(find.text('Criar conta'), findsOneWidget);
    expect(find.text('Mínimo 8 caracteres'), findsOneWidget);
    expect(find.text('Uma letra maiúscula'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(2), 'Abcdefg1');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byIcon(Icons.check_rounded), findsWidgets);
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
