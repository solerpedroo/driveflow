import '../../../expenses/domain/services/expense_category_suggester.dart';
import '../entities/import_format.dart';
import '../entities/statement_transaction.dart';
import 'import_file_validator.dart';

/// Parse de extratos CSV (Nubank, Inter e genérico).
abstract final class CsvStatementParser {
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

    final delimiter = _detectDelimiter(lines.first);
    final headers = _splitLine(lines.first, delimiter)
        .map((h) => h.trim().toLowerCase())
        .toList(growable: false);

    final format = _detectFormat(headers);
    final mapping = _columnMapping(headers, format);

    var skipped = 0;
    final transactions = <StatementTransaction>[];

    for (var i = 1; i < lines.length; i++) {
      final cells = _splitLine(lines[i], delimiter);
      if (cells.length < 3) {
        skipped++;
        continue;
      }

      try {
        final date = _parseDate(cells[mapping.dateIndex]);
        final description = cells[mapping.descriptionIndex].trim();
        final rawAmount = cells[mapping.amountIndex];
        final amount = _parseAmount(rawAmount).abs();
        if (amount <= 0 || description.isEmpty) {
          skipped++;
          continue;
        }

        final type = _parseType(rawAmount);
        final suggestion = type == StatementEntryType.debit
            ? ExpenseCategorySuggester.suggest(description)
            : null;

        transactions.add(
          StatementTransaction(
            lineIndex: i,
            date: date,
            description: description,
            amount: amount,
            type: type,
            suggestedCategory: suggestion?.category,
          ),
        );
      } on Object {
        skipped++;
      }
    }

    return StatementParseResult(
      format: format,
      transactions: transactions,
      skippedLines: skipped,
    );
  }

  static String _detectDelimiter(String headerLine) {
    final semicolons = ';'.allMatches(headerLine).length;
    final commas = ','.allMatches(headerLine).length;
    return semicolons > commas ? ';' : ',';
  }

  static List<String> _splitLine(String line, String delimiter) {
    final result = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
        continue;
      }
      if (char == delimiter && !inQuotes) {
        result.add(buffer.toString());
        buffer.clear();
        continue;
      }
      buffer.write(char);
    }
    result.add(buffer.toString());
    return result;
  }

  static ImportFormat _detectFormat(List<String> headers) {
    final joined = headers.join(' ');
    if (joined.contains('nubank') ||
        (headers.contains('data') &&
            headers.contains('descrição') &&
            headers.contains('valor'))) {
      return ImportFormat.nubank;
    }
    if (joined.contains('inter') ||
        headers.any((h) => h.contains('lançamento'))) {
      return ImportFormat.inter;
    }
    return ImportFormat.generic;
  }

  static _ColumnMapping _columnMapping(
    List<String> headers,
    ImportFormat format,
  ) {
    int indexFor(Iterable<String> aliases) {
      for (var i = 0; i < headers.length; i++) {
        for (final alias in aliases) {
          if (headers[i].contains(alias)) return i;
        }
      }
      return -1;
    }

    switch (format) {
      case ImportFormat.nubank:
        return _ColumnMapping(
          dateIndex: indexFor(['data']).clamp(0, headers.length - 1),
          descriptionIndex:
              indexFor(['descrição', 'descricao']).clamp(0, headers.length - 1),
          amountIndex: indexFor(['valor']).clamp(0, headers.length - 1),
        );
      case ImportFormat.inter:
        return _ColumnMapping(
          dateIndex: indexFor(['data']).clamp(0, headers.length - 1),
          descriptionIndex:
              indexFor(['descrição', 'descricao', 'hist']).clamp(0, headers.length - 1),
          amountIndex: indexFor(['valor']).clamp(0, headers.length - 1),
        );
      case ImportFormat.generic:
      case ImportFormat.ofx:
        return _ColumnMapping(
          dateIndex: indexFor(['data', 'date']).clamp(0, headers.length - 1),
          descriptionIndex: indexFor([
            'descrição',
            'descricao',
            'description',
            'hist',
            'title',
          ]).clamp(0, headers.length - 1),
          amountIndex: indexFor(['valor', 'amount', 'value']).clamp(0, headers.length - 1),
        );
    }
  }

  static DateTime _parseDate(String raw) {
    final value = raw.trim().replaceAll('"', '');
    final parts = value.contains('/')
        ? value.split('/')
        : value.split('-');

    if (parts.length == 3) {
      if (parts[0].length == 4) {
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    }

    throw const FormatException('Data inválida');
  }

  static double _parseAmount(String raw) {
    var value = raw.trim().replaceAll('"', '').replaceAll('R\$', '').trim();
    if (value.contains(',') && value.contains('.')) {
      value = value.replaceAll('.', '').replaceAll(',', '.');
    } else if (value.contains(',')) {
      value = value.replaceAll(',', '.');
    }
    return double.parse(value);
  }

  static StatementEntryType _parseType(String rawAmount) {
    final amount = _parseAmount(rawAmount);
    return amount < 0
        ? StatementEntryType.debit
        : StatementEntryType.credit;
  }
}

class _ColumnMapping {
  const _ColumnMapping({
    required this.dateIndex,
    required this.descriptionIndex,
    required this.amountIndex,
  });

  final int dateIndex;
  final int descriptionIndex;
  final int amountIndex;
}
