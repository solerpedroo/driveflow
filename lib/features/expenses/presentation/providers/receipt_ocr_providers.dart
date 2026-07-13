import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/analytics_service.dart';
import '../../data/datasources/receipt_ocr_datasource.dart';
import '../../domain/entities/receipt_scan_result.dart';
import '../../domain/repositories/receipt_ocr_repository.dart';
import '../../domain/services/receipt_ocr_parser.dart';

/// Repository OCR com autoDispose — libera o TextRecognizer do ML Kit
/// quando ninguém depende do provider (sai do formulário / após scan).
final receiptOcrRepositoryProvider =
    Provider.autoDispose<ReceiptOcrRepository>((ref) {
  final dataSource = MlKitReceiptOcrDataSource();
  ref.onDispose(() => dataSource.dispose());
  return dataSource;
});

/// Processa imagem de comprovante e retorna campos sugeridos para revisão.
class ReceiptOcrController extends AutoDisposeNotifier<AsyncValue<ReceiptScanResult?>> {
  @override
  AsyncValue<ReceiptScanResult?> build() => const AsyncData(null);

  Future<ReceiptScanResult?> scan(File imageFile) async {
    state = const AsyncLoading();
    ReceiptScanResult? result;

    state = await AsyncValue.guard(() async {
      final text =
          await ref.read(receiptOcrRepositoryProvider).recognizeText(imageFile);
      result = ReceiptOcrParser.parse(text);
      DriveFlowAnalytics.logEvent('receipt_ocr_scanned', {
        'has_amount': result!.hasAmount,
        'has_date': result!.date != null,
        'has_description': result!.description != null,
      });
    });

    if (state.hasError) return null;
    return result;
  }

  void logConfirmed() {
    DriveFlowAnalytics.logEvent('receipt_ocr_confirmed');
    state = const AsyncData(null);
  }

  void logDiscarded() {
    DriveFlowAnalytics.logEvent('receipt_ocr_discarded');
    state = const AsyncData(null);
  }

  void clear() => state = const AsyncData(null);
}

final receiptOcrControllerProvider = NotifierProvider.autoDispose<
    ReceiptOcrController, AsyncValue<ReceiptScanResult?>>(
  ReceiptOcrController.new,
);

/// Implementação injetável para testes (bypass ML Kit).
class FakeReceiptOcrRepository implements ReceiptOcrRepository {
  FakeReceiptOcrRepository(this.text);

  final String text;

  @override
  Future<String> recognizeText(File imageFile) async => text;
}
