import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static Future<String?> understandPrescription(String ocrText) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) return null;

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-preview:generateContent?key=$apiKey',
    );

  final prompt = '''
You are a medical prescription understanding assistant.

STRICT RULES:
- Extract ONLY what is clearly present in the prescription.
- DO NOT invent or guess missing information.
- If something is missing, write "Not mentioned".
- DO NOT add medical advice.
- Output must be SIMPLE, CLEAN, and STRUCTURED for humans.
- Do NOT use JSON, markdown, or bullets.
- Do NOT explain anything.

OUTPUT FORMAT (FOLLOW EXACTLY):

Doctor:
<Doctor Name or Not mentioned>

Hospital:
<Hospital Name or Not mentioned>

Patient:
<Name or Not mentioned>

Age:
<Age or Not mentioned>

Gender:
<Gender or Not mentioned>

Date:
<Date or Not mentioned>

Medicines:
1. <Medicine name> | <Dosage> | <Frequency> | <Instructions>
2. <Medicine name> | <Dosage> | <Frequency> | <Instructions>

Notes:
<Notes or Not mentioned>

Prescription text:
$ocrText
''';

    try {
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
      }
    } catch (_) {}

    return null;
  }
}
