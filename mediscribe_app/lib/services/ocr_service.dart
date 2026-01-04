import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  static Future<String> extractText(File image) async {
    final inputImage = InputImage.fromFile(image);
    final recognizer =
        TextRecognizer(script: TextRecognitionScript.latin);

    final result = await recognizer.processImage(inputImage);
    await recognizer.close();

    return result.text.trim();
  }
}
