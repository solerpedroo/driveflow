import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:driveflow/app.dart';
import 'package:driveflow/features/authentication/presentation/providers/auth_providers.dart';
import 'package:driveflow/features/authentication/presentation/providers/brand_intro_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  testWidgets('smoke: app deslogado redireciona para login', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          brandIntroCompleteProvider.overrideWith((ref) => true),
          authStateProvider.overrideWith((ref) => Stream.value(null)),
          authRefreshStreamProvider.overrideWith((ref) => const Stream.empty()),
        ],
        child: const DriveFlowApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Entrar no painel'), findsOneWidget);
    expect(find.text('Acesse sua conta'), findsOneWidget);
  });
}
