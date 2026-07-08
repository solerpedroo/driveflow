import '../../../expenses/domain/services/expense_category_suggester.dart';
import '../entities/import_format.dart';
import '../entities/statement_transaction.dart';
import 'import_file_validator.dart';

/// Parser básico de extratos OFX (STMTTRN).
abstract final class OfxStatementParser {
  static StatementParseResult parse(String content) {
    final lines = content
        .replaceAll('\r\n', '\n')
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList(growable: false);

    ImportFileValidator.validate(
      byteLength: content.codeUnits.length,
      lineCount: lines.length,
    );

    var skipped = 0;
    final transactions = <StatementTransaction>[];
    DateTime? currentDate;
    double? currentAmount;
    final descriptionBuffer = StringBuffer();

    void flush(int lineIndex) {
      final date = currentDate;
      final amount = currentAmount;
      final description = descriptionBuffer.toString().trim();

      if (date == null || amount == null || description.isEmpty) {
        skipped++;
      } else {
        final absAmount = amount.abs();
        if (absAmount > 0) {
          final type = amount < 0
              ? StatementEntryType.debit
              : StatementEntryType.credit;
          final suggestion = type == StatementEntryType.debit
              ? ExpenseCategorySuggester.suggest(description)
              : null;

          transactions.add(
            StatementTransaction(
              lineIndex: lineIndex,
              date: date,
              description: description,
              amount: absAmount,
              type: type,
              suggestedCategory: suggestion?.category,
            ),
          );
        } else {
          skipped++;
        }
      }

      currentDate = null;
      currentAmount = null;
      descriptionBuffer.clear();
    }

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      final upper = line.toUpperCase();

      if (upper.contains('<STMTTRN>')) {
        flush(i);
        continue;
      }
      if (upper.contains('</STMTTRN>')) {
        flush(i);
        continue;
      }

      if (upper.contains('<DTPOSTED>')) {
        currentDate = _parseOfxDate(_tagValue(line));
        continue;
      }
      if (upper.contains('<TRNAMT>')) {
        currentAmount = double.tryParse(_tagValue(line));
        continue;
      }
      if (upper.contains('<MEMO>') || upper.contains('<NAME>')) {
        descriptionBuffer.write(_tagValue(line));
      }
    }

    flush(lines.length);

    return StatementParseResult(
      format: ImportFormat.ofx,
      transactions: transactions,
      skippedLines: skipped,
    );
  }

  static String _tagValue(String line) {
    final start = line.indexOf('>');
    final end = line.lastIndexOf('<');
    if (start == -1) return line;
    if (end <= start) return line.substring(start + 1).trim();
    return line.substring(start + 1, end).trim();
  }

  static DateTime _parseOfxDate(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 8) {
      throw const FormatException('Data OFX inválida');
    }
    return DateTime(
      int.parse(digits.substring(0, 4)),
      int.parse(digits.substring(4, 6)),
      int.parse(digits.substring(6, 8)),
    );
  }
}
