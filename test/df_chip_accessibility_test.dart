import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/theme/app_theme.dart';
import 'package:driveflow/shared/widgets/design_system/df_chip.dart';

void main() {
  testWidgets('DfChip respeita textScaleFactor 1.3', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildDriveFlowLightTheme(),
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: const Scaffold(
            body: DfChip(
              label: 'Lucro',
              value: 'R\$ 250',
            ),
          ),
        ),
      ),
    );

    expect(find.text('R\$ 250'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
