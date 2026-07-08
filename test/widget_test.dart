import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:driveflow/app.dart';

void main() {
  testWidgets('DriveFlowApp smoke test', (tester) async {
    // Router-only smoke; Supabase init happens in main().
    await tester.pumpWidget(
      const ProviderScope(child: DriveFlowApp()),
    );
    await tester.pump();
    expect(find.byType(DriveFlowApp), findsOneWidget);
  });
}
