import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/theme/app_theme.dart';
import 'package:driveflow/features/authentication/presentation/screens/login_screen.dart';
import 'package:driveflow/shared/widgets/design_system/df_button.dart';

void main() {
  testWidgets('LoginScreen renders brand-first form without Google', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildDriveFlowDarkTheme(),
          home: const LoginScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Drive'), findsWidgets);
    expect(find.textContaining('Flow'), findsWidgets);
    expect(find.textContaining('Lucro claro'), findsOneWidget);
    expect(find.text('Entrar no painel'), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);
    expect(find.text('Continuar com Google'), findsNothing);
    expect(find.text('R\$ 248,40'), findsOneWidget);
    expect(find.text('Acesse sua conta'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Plano Pro'), findsOneWidget);
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
    await tester.pump();

    await tester.ensureVisible(find.byType(DfButton).first);
    await tester.tap(find.byType(DfButton).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Informe seu e-mail'), findsOneWidget);
  });
}
