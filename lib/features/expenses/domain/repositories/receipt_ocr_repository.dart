import 'dart:io';

/// Contrato para reconhecimento de texto em imagens de comprovante.
abstract interface class ReceiptOcrRepository {
  Future<String> recognizeText(File imageFile);
}
