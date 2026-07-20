import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:driveflow/core/router/app_router.dart';
import 'package:driveflow/core/theme/app_theme.dart';
import 'package:driveflow/core/theme/theme_mode_provider.dart';
import 'package:driveflow/features/authentication/domain/entities/user_entity.dart';
import 'package:driveflow/features/authentication/presentation/providers/auth_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('router smoke test with auth overrides', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: Text('DriveFlow smoke'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream<UserEntity?>.value(null),
          ),
          authRefreshStreamProvider.overrideWith(
            (ref) => const Stream.empty(),
          ),
          themeModeProvider.overrideWith(ThemeModeNotifier.new),
          routerProvider.overrideWith((ref) => router),
        ],
        child: MaterialApp.router(
          theme: buildDriveFlowLightTheme(),
          routerConfig: router,
        ),
      ),
    );

    await tester.pump();
    expect(find.text('DriveFlow smoke'), findsOneWidget);
  });
}
