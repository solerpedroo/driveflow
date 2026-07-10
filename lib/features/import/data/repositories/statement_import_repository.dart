import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/ride_platforms.dart';
import '../../../integrations/domain/entities/earning_source.dart';
import '../../../earnings/domain/entities/earning_entity.dart';
import '../../../earnings/domain/repositories/earnings_repository.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../expenses/domain/repositories/expenses_repository.dart';
import '../../domain/entities/statement_transaction.dart';
import '../datasources/import_remote_datasource.dart';

/// Executa importação em lote via repositórios (com fila offline).
class StatementImportRepository {
  StatementImportRepository({ImportRemoteDataSource? remote})
      : _remote = remote ?? ImportRemoteDataSource();

  final ImportRemoteDataSource _remote;

  Future<ImportBatchResult> importSelected({
    required List<StatementTransaction> transactions,
    required ExpensesRepository expenses,
    required EarningsRepository earnings,
    String? vehicleId,
  }) async {
    if (!_remote.isAuthenticated) {
      throw StateError('Sessão expirada. Entre novamente.');
    }

    var importedExpenses = 0;
    var importedEarnings = 0;
    var skippedDuplicates = 0;
    var failed = 0;

    for (final transaction in transactions) {
      if (!transaction.selected) continue;
      if (transaction.isDuplicate) {
        skippedDuplicates++;
        continue;
      }

      try {
        if (transaction.isCredit) {
          await earnings.createEarning(
            EarningDraft(
              platform: RidePlatform.other,
              amount: transaction.amount,
              rides: 0,
              workedHours: 0,
              date: transaction.date,
              vehicleId: vehicleId,
              note: 'Importado: ${transaction.description}',
              source: EarningSource.import_,
            ),
          );
          importedEarnings++;
        } else {
          await expenses.createExpense(
            ExpenseDraft(
              category: transaction.suggestedCategory ?? ExpenseCategory.other,
              amount: transaction.amount,
              date: transaction.date,
              vehicleId: vehicleId,
              description: transaction.description,
            ),
          );
          importedExpenses++;
        }
      } on Object {
        failed++;
      }
    }

    return ImportBatchResult(
      importedExpenses: importedExpenses,
      importedEarnings: importedEarnings,
      skippedDuplicates: skippedDuplicates,
      failed: failed,
    );
  }
}
