import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/theme/app_theme.dart';
import 'package:driveflow/features/authentication/domain/entities/user_entity.dart';
import 'package:driveflow/features/authentication/presentation/providers/auth_providers.dart';
import 'package:driveflow/shared/widgets/design_system/df_chip.dart';
import 'package:driveflow/features/dashboard/presentation/screens/foundation_screen.dart';
import 'package:driveflow/shared/widgets/driveflow_brand_logo.dart';

void main() {
  testWidgets('FoundationScreen renders brand and metrics', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(
              const UserEntity(id: 'test', name: 'Test Driver'),
            ),
          ),
        ],
        child: MaterialApp(
          theme: buildDriveFlowDarkTheme(),
          home: const FoundationScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(DriveFlowBrandLogo), findsOneWidget);
    expect(find.textContaining('Onda 0'), findsOneWidget);
    expect(find.text('Prévia de métricas'), findsOneWidget);
    expect(find.text('Test Driver'), findsOneWidget);
    expect(find.byType(DfChip), findsWidgets);
  });
}
