import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../domain/repositories/receipt_ocr_repository.dart';

/// OCR on-device via Google ML Kit (sem envio à nuvem).
class MlKitReceiptOcrDataSource implements ReceiptOcrRepository {
  MlKitReceiptOcrDataSource({TextRecognizer? recognizer})
      : _recognizer = recognizer ?? TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;

  @override
  Future<String> recognizeText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    try {
      final recognized = await _recognizer.processImage(inputImage);
      return recognized.text;
    } finally {
      // Recognizer é singleton por instância; dispose no provider lifecycle.
    }
  }

  Future<void> dispose() => _recognizer.close();
}
