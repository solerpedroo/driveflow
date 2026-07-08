import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:driveflow/app.dart';
import 'package:driveflow/core/router/app_router.dart';
import 'package:driveflow/features/authentication/domain/entities/user_entity.dart';
import 'package:driveflow/features/authentication/presentation/providers/auth_providers.dart';

void main() {
  testWidgets('DriveFlowApp smoke test', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream<UserEntity?>.value(null),
          ),
          authRefreshStreamProvider.overrideWith(
            (ref) => const Stream.empty(),
          ),
          routerProvider.overrideWith(
            (ref) => GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const SizedBox(),
                ),
              ],
            ),
          ),
        ],
        child: const DriveFlowApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(DriveFlowApp), findsOneWidget);
  });
}
