import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/app_constants.dart';
import 'package:driveflow/core/theme/app_theme.dart';
import 'package:driveflow/features/authentication/domain/entities/user_entity.dart';
import 'package:driveflow/features/authentication/presentation/providers/auth_providers.dart';
import 'package:driveflow/features/dashboard/presentation/screens/main_shell_screen.dart';
import 'package:driveflow/features/profile/presentation/providers/profile_providers.dart';
import 'package:driveflow/features/vehicle/domain/entities/vehicle_entity.dart';
import 'package:driveflow/features/vehicle/presentation/providers/vehicle_providers.dart';
import 'package:driveflow/shared/widgets/driveflow_bottom_nav_bar.dart';

void main() {
  testWidgets('MainShellScreen switches tabs via bottom nav', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(
              const UserEntity(id: 'u1', name: 'Driver', email: 'd@test.com'),
            ),
          ),
          userProfileProvider.overrideWith(
            (ref) async => const UserEntity(
              id: 'u1',
              name: 'Driver',
              email: 'd@test.com',
            ),
          ),
          vehiclesStreamProvider.overrideWith(
            (ref) => Stream.value([
              const VehicleEntity(
                id: 'v1',
                userId: 'u1',
                brand: 'Fiat',
                model: 'Argo',
                year: 2021,
                fuel: FuelType.flex,
                odometerKm: 30000,
              ),
            ]),
          ),
        ],
        child: MaterialApp(
          theme: buildDriveFlowDarkTheme(),
          home: const MainShellScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Prévia de métricas'), findsOneWidget);
    expect(find.text('GANHOS'), findsOneWidget);

    await tester.tap(find.text('GANHOS'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('Registre corridas por plataforma'), findsOneWidget);

    await tester.tap(find.text('PERFIL'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Perfil'), findsOneWidget);
    expect(find.byType(DriveFlowBottomNavBar), findsOneWidget);
  });
}
