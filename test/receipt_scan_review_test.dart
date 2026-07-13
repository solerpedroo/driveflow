import 'dart:io';

import 'package:driveflow/core/constants/app_constants.dart';
import 'package:driveflow/features/expenses/domain/entities/receipt_scan_result.dart';
import 'package:driveflow/features/expenses/presentation/widgets/receipt_scan_review_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('receipt scan review confirms parsed values', (tester) async {
    final imageFile = File(
      '${Directory.systemTemp.path}/driveflow_receipt_test.jpg',
    );
    await imageFile.writeAsBytes(const [0xFF, 0xD8, 0xFF]);

    ReceiptScanConfirmation? confirmed;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    confirmed = await showReceiptScanReviewSheet(
                      context: context,
                      scan: const ReceiptScanResult(
                        amount: 89.9,
                        date: null,
                        description: 'Posto Shell',
                        suggestedCategory: ExpenseCategory.fuel,
                        amountConfidence: 0.9,
                      ),
                      imageFile: imageFile,
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Revisar comprovante'), findsOneWidget);
    expect(find.text('Posto Shell'), findsOneWidget);

    await tester.tap(find.text('Usar estes dados'));
    await tester.pumpAndSettle();

    expect(confirmed, isNotNull);
    expect(confirmed!.amount, 89.9);
    expect(confirmed!.category, ExpenseCategory.fuel);
  });
}
