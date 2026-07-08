import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/theme/app_theme.dart';
import 'package:driveflow/features/authentication/presentation/screens/login_screen.dart';

void main() {
  testWidgets('LoginScreen renders form fields and actions', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildDriveFlowDarkTheme(),
          home: const LoginScreen(),
        ),
      ),
    );

    expect(find.text('Entrar'), findsWidgets);
    expect(find.text('Continuar com Google'), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('LoginScreen validates empty email', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildDriveFlowDarkTheme(),
          home: const LoginScreen(),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pump();

    expect(find.text('Informe seu e-mail'), findsOneWidget);
  });
}
