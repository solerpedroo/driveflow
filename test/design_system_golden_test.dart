import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/theme/app_theme.dart';
import 'package:driveflow/shared/widgets/design_system/df_button.dart';
import 'package:driveflow/shared/widgets/design_system/df_card.dart';
import 'package:driveflow/shared/widgets/design_system/df_empty_state.dart';

void main() {
  Widget goldenWrap(Widget child, Brightness brightness) {
    final theme = brightness == Brightness.light
        ? buildDriveFlowLightTheme()
        : buildDriveFlowDarkTheme();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: RepaintBoundary(
        key: const Key('golden_surface'),
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Center(
            child: SizedBox(width: 320, child: child),
          ),
        ),
      ),
    );
  }

  Future<void> pumpGolden(
    WidgetTester tester,
    Widget child,
    Brightness brightness, {
    Size surfaceSize = const Size(400, 200),
  }) async {
    tester.view.physicalSize = surfaceSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(goldenWrap(child, brightness));
    await tester.pump();
  }

  group('Design System golden', () {
    testWidgets('DfButton primary light', (tester) async {
      await pumpGolden(
        tester,
        const DfButton(label: 'Continuar', onPressed: null),
        Brightness.light,
      );
      await expectLater(
        find.byKey(const Key('golden_surface')),
        matchesGoldenFile('goldens/df_button_primary_light.png'),
      );
    });

    testWidgets('DfButton primary dark', (tester) async {
      await pumpGolden(
        tester,
        const DfButton(label: 'Continuar', onPressed: null),
        Brightness.dark,
      );
      await expectLater(
        find.byKey(const Key('golden_surface')),
        matchesGoldenFile('goldens/df_button_primary_dark.png'),
      );
    });

    testWidgets('DfCard elevated light', (tester) async {
      await pumpGolden(
        tester,
        const DfCard(
          variant: DfCardVariant.elevated,
          child: Text('Conteúdo do card'),
        ),
        Brightness.light,
      );
      await expectLater(
        find.byKey(const Key('golden_surface')),
        matchesGoldenFile('goldens/df_card_elevated_light.png'),
      );
    });

    testWidgets('DfEmptyState dark', (tester) async {
      await pumpGolden(
        tester,
        const DfEmptyState(
          title: 'Nenhum dado',
          subtitle: 'Registre sua primeira entrada.',
        ),
        Brightness.dark,
        surfaceSize: const Size(400, 280),
      );
      await expectLater(
        find.byKey(const Key('golden_surface')),
        matchesGoldenFile('goldens/df_empty_state_dark.png'),
      );
    });
  });

  group('Design System smoke', () {
    testWidgets('DfButton renders label', (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          const DfButton(label: 'Continuar', onPressed: null),
          Brightness.light,
        ),
      );
      expect(find.text('Continuar'), findsOneWidget);
    });

    testWidgets('DfEmptyState dark com semantics', (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          const DfEmptyState(
            title: 'Nenhum dado',
            subtitle: 'Registre sua primeira entrada.',
          ),
          Brightness.dark,
        ),
      );
      expect(find.text('Nenhum dado'), findsOneWidget);
      expect(find.text('Registre sua primeira entrada.'), findsOneWidget);
    });
  });
}
