import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static Future<String?> understandPrescription(String ocrText) async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) return null;

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-preview:generateContent?key=$apiKey',
      );

      final prompt = '''
You are a medical assistant.

From the prescription text below:
1. Extract medicine names ONLY
2. Extract dosage, frequency, and instructions
3. Return output in this format:

MEDICINES:
- Medicine 1
- Medicine 2

DETAILS:
<remaining information>

Do NOT add explanations.
Do NOT add non-medical content.

Prescription text:
$ocrText
''';

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }
}
