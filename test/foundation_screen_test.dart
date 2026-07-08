import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/theme/app_theme.dart';
import 'package:driveflow/features/dashboard/presentation/screens/foundation_screen.dart';
import 'package:driveflow/shared/widgets/driveflow_brand_logo.dart';

void main() {
  testWidgets('FoundationScreen renders brand and metrics', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildDriveFlowDarkTheme(),
          home: const FoundationScreen(),
        ),
      ),
    );

    expect(find.byType(DriveFlowBrandLogo), findsOneWidget);
    expect(find.textContaining('Onda 0'), findsOneWidget);
    expect(find.text('Prévia de métricas'), findsOneWidget);
    expect(find.text('LUCRO HOJE'), findsOneWidget);
  });
}
