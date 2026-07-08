import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../earnings/presentation/providers/earnings_providers.dart';
import '../../../expenses/presentation/providers/expenses_providers.dart';
import '../../../vehicle/presentation/providers/vehicle_providers.dart';
import '../../data/repositories/statement_import_repository.dart';
import '../../domain/entities/statement_transaction.dart';
import '../../domain/services/csv_statement_parser.dart';
import '../../domain/services/import_deduplicator.dart';
import '../../domain/services/ofx_statement_parser.dart';

final statementImportRepositoryProvider =
    Provider<StatementImportRepository>((ref) {
  return StatementImportRepository();
});

final importPreviewProvider =
    StateProvider<List<StatementTransaction>>((ref) => const []);

class ImportController extends Notifier<AsyncValue<ImportBatchResult?>> {
  @override
  AsyncValue<ImportBatchResult?> build() => const AsyncData(null);

  void parseContent({required String content, required bool isOfx}) {
    final result =
        isOfx ? OfxStatementParser.parse(content) : CsvStatementParser.parse(content);

    final expenses = ref.read(expensesStreamProvider).valueOrNull ?? const [];
    final earnings = ref.read(earningsStreamProvider).valueOrNull ?? const [];
    final existing = ImportDeduplicator.existingFingerprints(
      expenses: expenses,
      earnings: earnings,
    );

    ref.read(importPreviewProvider.notifier).state =
        ImportDeduplicator.markDuplicates(
      transactions: result.transactions,
      existing: existing,
    );
    state = const AsyncData(null);
  }

  void toggleSelection(int lineIndex, bool selected) {
    final current = ref.read(importPreviewProvider);
    ref.read(importPreviewProvider.notifier).state = current
        .map(
          (item) => item.lineIndex == lineIndex
              ? item.copyWith(selected: selected)
              : item,
        )
        .toList(growable: false);
  }

  void toggleAll(bool selected) {
    final current = ref.read(importPreviewProvider);
    ref.read(importPreviewProvider.notifier).state = current
        .map(
          (item) => item.isDuplicate
              ? item
              : item.copyWith(selected: selected),
        )
        .toList(growable: false);
  }

  Future<ImportBatchResult?> importSelected() async {
    final preview = ref.read(importPreviewProvider);
    if (preview.isEmpty) return null;

    state = const AsyncLoading();
    ImportBatchResult? result;

    state = await AsyncValue.guard(() async {
      final vehicleId = ref.read(scopedVehicleIdProvider);
      result = await ref.read(statementImportRepositoryProvider).importSelected(
            transactions: preview,
            expenses: ref.read(expensesRepositoryProvider),
            earnings: ref.read(earningsRepositoryProvider),
            vehicleId: vehicleId,
          );
    });

    if (state.hasError) return null;
    ref.read(importPreviewProvider.notifier).state = const [];
    return result;
  }

  void clearPreview() {
    ref.read(importPreviewProvider.notifier).state = const [];
    state = const AsyncData(null);
  }
}

final importControllerProvider =
    NotifierProvider<ImportController, AsyncValue<ImportBatchResult?>>(
  ImportController.new,
);
