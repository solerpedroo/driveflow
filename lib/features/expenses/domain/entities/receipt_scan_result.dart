import '../../../../core/constants/app_constants.dart';

/// Resultado estruturado do OCR de comprovante — revisado pelo usuário antes de salvar.
class ReceiptScanResult {
  const ReceiptScanResult({
    this.amount,
    this.date,
    this.description,
    this.suggestedCategory,
    this.amountConfidence = 0,
    this.dateConfidence = 0,
    this.descriptionConfidence = 0,
    this.categoryConfidence = 0,
    this.rawText = '',
  });

  final double? amount;
  final DateTime? date;
  final String? description;
  final ExpenseCategory? suggestedCategory;
  final double amountConfidence;
  final double dateConfidence;
  final double descriptionConfidence;
  final double categoryConfidence;
  final String rawText;

  bool get hasAmount => amount != null && amount! > 0;

  bool get hasLowConfidenceAmount => amountConfidence < 0.6;

  bool get hasLowConfidenceDate => dateConfidence < 0.6;

  ReceiptScanResult copyWith({
    double? amount,
    DateTime? date,
    String? description,
    ExpenseCategory? suggestedCategory,
    double? amountConfidence,
    double? dateConfidence,
    double? descriptionConfidence,
    double? categoryConfidence,
    String? rawText,
  }) {
    return ReceiptScanResult(
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      suggestedCategory: suggestedCategory ?? this.suggestedCategory,
      amountConfidence: amountConfidence ?? this.amountConfidence,
      dateConfidence: dateConfidence ?? this.dateConfidence,
      descriptionConfidence:
          descriptionConfidence ?? this.descriptionConfidence,
      categoryConfidence: categoryConfidence ?? this.categoryConfidence,
      rawText: rawText ?? this.rawText,
    );
  }
}
