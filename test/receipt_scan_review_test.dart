import 'dart:io';

import 'package:driveflow/core/constants/app_constants.dart';
import 'package:driveflow/core/utils/currency_formatter.dart';
import 'package:driveflow/features/expenses/domain/entities/receipt_scan_result.dart';
import 'package:driveflow/features/expenses/presentation/widgets/receipt_scan_review_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ReceiptScanResult exposes OCR suggestions for review', () {
    final scan = ReceiptScanResult(
      amount: 89.9,
      date: DateTime(2026, 7, 20),
      description: 'Posto Shell',
      suggestedCategory: ExpenseCategory.fuel,
      amountConfidence: 0.9,
    );

    expect(scan.hasAmount, isTrue);
    expect(scan.description, 'Posto Shell');
    expect(scan.suggestedCategory, ExpenseCategory.fuel);
    expect(CurrencyFormatter.tryParse(CurrencyFormatter.format(89.9)), 89.9);
  });

  test('ReceiptScanConfirmation keeps confirmed values', () {
    final file = File('${Directory.systemTemp.path}/receipt.bin');
    final confirmed = ReceiptScanConfirmation(
      amount: 89.9,
      date: DateTime(2026, 7, 20),
      category: ExpenseCategory.fuel,
      description: 'Posto Shell',
      imageFile: file,
    );

    expect(confirmed.amount, 89.9);
    expect(confirmed.category, ExpenseCategory.fuel);
    expect(confirmed.description, 'Posto Shell');
  });
}
