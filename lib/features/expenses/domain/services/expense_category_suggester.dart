import '../../../../core/constants/app_constants.dart';

/// Sugere categoria de despesa a partir de palavras-chave no texto OCR.
abstract final class ExpenseCategorySuggester {
  static const _keywordMap = <ExpenseCategory, List<String>>{
    ExpenseCategory.fuel: [
      'posto',
      'combust',
      'gasolina',
      'etanol',
      'diesel',
      'shell',
      'ipiranga',
      'br distribuidora',
    ],
    ExpenseCategory.toll: ['pedagio', 'pedágio', 'sem parar', 'conectcar'],
    ExpenseCategory.food: [
      'restaurante',
      'lanchonete',
      'padaria',
      'ifood',
      'mcdonald',
      'burger',
      'aliment',
    ],
    ExpenseCategory.wash: ['lavagem', 'lava jato', 'lava-jato', 'estetica automotiva'],
    ExpenseCategory.mechanic: ['oficina', 'mecanica', 'mecânica', 'auto center'],
    ExpenseCategory.parking: ['estacionamento', 'parking', 'zona azul'],
    ExpenseCategory.fine: ['multa', 'detran', 'infracao', 'infração'],
    ExpenseCategory.insurance: ['seguro', 'porto seguro', 'tokio marine'],
    ExpenseCategory.ipva: ['ipva', 'detran', 'licenciamento'],
  };

  static ({ExpenseCategory category, double confidence})? suggest(String text) {
    final normalized = text.toLowerCase();

    ExpenseCategory? bestCategory;
    var bestScore = 0;

    for (final entry in _keywordMap.entries) {
      var score = 0;
      for (final keyword in entry.value) {
        if (normalized.contains(keyword)) score += keyword.length;
      }
      if (score > bestScore) {
        bestScore = score;
        bestCategory = entry.key;
      }
    }

    if (bestCategory == null || bestScore == 0) return null;

    final confidence = (bestScore / 12).clamp(0.35, 0.9);
    return (category: bestCategory, confidence: confidence);
  }
}
