import '../entities/receipt_scan_result.dart';
import 'expense_category_suggester.dart';

/// Extrai campos de despesa a partir de texto OCR em português brasileiro.
abstract final class ReceiptOcrParser {
  static final _amountPattern = RegExp(
    r'(?:R\$\s*)?(\d{1,3}(?:\.\d{3})*,\d{2}|\d+,\d{2})',
    caseSensitive: false,
  );

  static final _datePattern = RegExp(
    r'(\d{2})[/.-](\d{2})[/.-](\d{2,4})',
  );

  static final _totalKeywords = RegExp(
    r'\b(total|valor\s*pago|valor\s*total|vlr\s*total|a\s*pagar)\b',
    caseSensitive: false,
  );

  static final _noisePattern = RegExp(
    r'^(cnpj|cpf|ie|nfce|nfc-e|sat|cupom|documento|auxiliar|serie|n[ºo°])',
    caseSensitive: false,
  );

  static ReceiptScanResult parse(String rawText) {
    final lines = rawText
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);

    final amountMatch = _extractAmount(lines);
    final dateMatch = _extractDate(lines);
    final description = _extractDescription(lines);
    final categorySuggestion = ExpenseCategorySuggester.suggest(rawText);

    return ReceiptScanResult(
      amount: amountMatch?.value,
      date: dateMatch?.value,
      description: description?.value,
      suggestedCategory: categorySuggestion?.category,
      amountConfidence: amountMatch?.confidence ?? 0,
      dateConfidence: dateMatch?.confidence ?? 0,
      descriptionConfidence: description?.confidence ?? 0,
      categoryConfidence: categorySuggestion?.confidence ?? 0,
      rawText: rawText,
    );
  }

  static _ParsedField<double>? _extractAmount(List<String> lines) {
    _ParsedField<double>? best;

    for (final line in lines) {
      final matches = _amountPattern.allMatches(line);
      for (final match in matches) {
        final parsed = _parseBrl(match.group(1));
        if (parsed == null || parsed <= 0) continue;

        var confidence = 0.45;
        if (_totalKeywords.hasMatch(line)) confidence = 0.92;
        if (line.toUpperCase().contains('TOTAL')) confidence = 0.88;

        final candidate = _ParsedField(value: parsed, confidence: confidence);
        if (best == null || candidate.confidence > best.confidence) {
          best = candidate;
        }
      }
    }

    if (best != null) return best;

    // Fallback: maior valor encontrado (cupons com vários itens).
    double? maxValue;
    for (final line in lines) {
      for (final match in _amountPattern.allMatches(line)) {
        final parsed = _parseBrl(match.group(1));
        if (parsed != null && parsed > (maxValue ?? 0)) {
          maxValue = parsed;
        }
      }
    }

    if (maxValue == null) return null;
    return _ParsedField(value: maxValue, confidence: 0.4);
  }

  static _ParsedField<DateTime>? _extractDate(List<String> lines) {
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final match = _datePattern.firstMatch(line);
      if (match == null) continue;

      final day = int.tryParse(match.group(1)!);
      final month = int.tryParse(match.group(2)!);
      var year = int.tryParse(match.group(3)!);
      if (day == null || month == null || year == null) continue;

      if (year < 100) year += 2000;
      if (!_isValidDate(day, month, year)) continue;

      final confidence = i < 8 ? 0.85 : 0.55;
      return _ParsedField(
        value: DateTime(year, month, day),
        confidence: confidence,
      );
    }
    return null;
  }

  static _ParsedField<String>? _extractDescription(List<String> lines) {
    for (final line in lines) {
      if (_noisePattern.hasMatch(line)) continue;
      if (_amountPattern.hasMatch(line) && line.length < 24) continue;
      if (_datePattern.hasMatch(line) && line.length < 16) continue;
      if (line.length < 3) continue;

      return _ParsedField(value: _normalizeDescription(line), confidence: 0.55);
    }
    return null;
  }

  static String _normalizeDescription(String line) {
    return line
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .split(' ')
        .take(8)
        .join(' ');
  }

  static double? _parseBrl(String? raw) {
    if (raw == null) return null;
    final normalized = raw.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  static bool _isValidDate(int day, int month, int year) {
    if (month < 1 || month > 12 || day < 1 || day > 31) return false;
    if (year < 2018 || year > 2100) return false;
    return true;
  }
}

class _ParsedField<T> {
  const _ParsedField({required this.value, required this.confidence});

  final T value;
  final double confidence;
}
