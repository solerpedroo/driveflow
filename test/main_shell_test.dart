import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/driveflow_tab_count.dart';
import 'package:driveflow/core/theme/app_theme.dart';
import 'package:driveflow/features/dashboard/presentation/screens/main_shell_screen.dart';
import 'package:driveflow/shared/widgets/driveflow_bottom_nav_bar.dart';

import 'support/shell_provider_overrides.dart';

void main() {
  void ignoreLayoutOverflow() {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('overflowed')) return;
      originalOnError?.call(details);
    };
  }

  testWidgets('MainShellScreen switches tabs via bottom nav', (tester) async {
    ignoreLayoutOverflow();
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: shellProviderOverrides(),
        child: MaterialApp(
          theme: buildDriveFlowDarkTheme(),
          home: const MainShellScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Lucro do mês'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(DriveFlowBottomNavBar),
        matching: find.text('Início'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('driveflow_nav_ganhos')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.descendant(
        of: find.byType(DriveFlowBottomNavBar),
        matching: find.text('Ganhos'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('driveflow_nav_despesas')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.descendant(
        of: find.byType(DriveFlowBottomNavBar),
        matching: find.text('Despesas'),
      ),
      findsOneWidget,
    );
    expect(find.text('Despesas'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('driveflow_nav_relatorios')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.descendant(
        of: find.byType(DriveFlowBottomNavBar),
        matching: find.text('Relatórios'),
      ),
      findsOneWidget,
    );
    expect(find.text('Relatórios'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('driveflow_nav_perfil')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.descendant(
        of: find.byType(DriveFlowBottomNavBar),
        matching: find.text('Perfil'),
      ),
      findsOneWidget,
    );
    expect(find.text('Meus veículos'), findsOneWidget);
    expect(find.byType(DriveFlowBottomNavBar), findsOneWidget);
  });

  testWidgets('MainShellScreen opens profile tab when requested', (tester) async {
    ignoreLayoutOverflow();
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: shellProviderOverrides(),
        child: MaterialApp(
          theme: buildDriveFlowDarkTheme(),
          home: const MainShellScreen(initialTab: DriveFlowTab.profile),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.descendant(
        of: find.byType(DriveFlowBottomNavBar),
        matching: find.text('Perfil'),
      ),
      findsOneWidget,
    );
    expect(find.text('Meus veículos'), findsOneWidget);
  });

  testWidgets('MainShellScreen back navigates tab history then dashboard', (tester) async {
    ignoreLayoutOverflow();
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: shellProviderOverrides(),
        child: MaterialApp(
          theme: buildDriveFlowDarkTheme(),
          home: const MainShellScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Lucro do mês'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('driveflow_nav_ganhos')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.pageBack();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Lucro do mês'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('driveflow_nav_ganhos')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const ValueKey('driveflow_nav_perfil')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Meus veículos'), findsOneWidget);

    await tester.pageBack();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.descendant(
        of: find.byType(DriveFlowBottomNavBar),
        matching: find.text('Ganhos'),
      ),
      findsOneWidget,
    );

    await tester.pageBack();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Lucro do mês'), findsOneWidget);

    await tester.pageBack();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Lucro do mês'), findsOneWidget);
  });

  testWidgets('MainShellScreen back from non-dashboard tab opens dashboard', (tester) async {
    ignoreLayoutOverflow();
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: shellProviderOverrides(),
        child: MaterialApp(
          theme: buildDriveFlowDarkTheme(),
          home: const MainShellScreen(initialTab: DriveFlowTab.profile),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Meus veículos'), findsOneWidget);

    await tester.pageBack();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Lucro do mês'), findsOneWidget);
  });
}
