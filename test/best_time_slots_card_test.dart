import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/features/insights/domain/entities/earning_time_slot.dart';
import 'package:driveflow/features/insights/presentation/widgets/best_time_slots_card.dart';

void main() {
  testWidgets('BestTimeSlotsCard exibe melhor horário com semantics', (tester) async {
    const slots = [
      EarningTimeSlot(
        weekday: 5,
        hour: 20,
        totalProfit: 400,
        totalHours: 4,
        earningCount: 2,
      ),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BestTimeSlotsCard(slots: slots),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Melhores horários para trabalhar'),
        findsOneWidget);
    expect(find.textContaining('Sexta'), findsOneWidget);
    expect(find.textContaining('20h'), findsOneWidget);
  });
}
