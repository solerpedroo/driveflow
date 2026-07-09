import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/theme/app_theme.dart';
import 'package:driveflow/shared/widgets/design_system/df_button.dart';
import 'package:driveflow/shared/widgets/design_system/df_card.dart';
import 'package:driveflow/shared/widgets/design_system/df_empty_state.dart';

void main() {
  Widget wrap(Widget child, Brightness brightness) {
    final theme = brightness == Brightness.light
        ? buildDriveFlowLightTheme()
        : buildDriveFlowDarkTheme();
    return MaterialApp(
      theme: theme,
      home: Scaffold(
        body: Center(child: SizedBox(width: 320, child: child)),
      ),
    );
  }

  group('Design System smoke', () {
    testWidgets('DfButton primary light', (tester) async {
      await tester.pumpWidget(
        wrap(
          const DfButton(label: 'Continuar', onPressed: null),
          Brightness.light,
        ),
      );
      expect(find.text('Continuar'), findsOneWidget);
      expect(find.byType(DfButton), findsOneWidget);
    });

    testWidgets('DfCard light', (tester) async {
      await tester.pumpWidget(
        wrap(
          const DfCard(child: Text('Conteúdo do card')),
          Brightness.light,
        ),
      );
      expect(find.text('Conteúdo do card'), findsOneWidget);
    });

    testWidgets('DfEmptyState dark com semantics', (tester) async {
      await tester.pumpWidget(
        wrap(
          const DfEmptyState(
            title: 'Nenhum dado',
            subtitle: 'Registre sua primeira entrada.',
          ),
          Brightness.dark,
        ),
      );
      expect(find.bySemanticsLabel('Nenhum dado. Registre sua primeira entrada.'),
          findsOneWidget);
    });
  });
}
