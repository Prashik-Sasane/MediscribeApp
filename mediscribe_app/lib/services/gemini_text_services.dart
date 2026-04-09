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
- First, determine if the provided text is a medical prescription.
- If it is NOT a prescription, return ONLY this JSON: {"error": "The provided image does not appear to be a medical prescription. Please upload a clear photo of a prescription."}
- If it IS a prescription:
    - Extract ONLY what is clearly present.
    - DO NOT invent or guess missing information.
    - If something is missing, write "Not mentioned".
    - DO NOT add medical advice.
    - Output MUST be in VALID JSON format ONLY.
    - DO NOT wrap the JSON in markdown code blocks like ```json ... ```.

OUTPUT JSON FORMAT FOR VALID PRESCRIPTION (FOLLOW EXACTLY):
{
  "doctor": "Doctor Name or Not mentioned",
  "hospital": "Hospital Name or Not mentioned",
  "license": "License No or Not mentioned",
  "patient": "Name or Not mentioned",
  "age": "Age or Not mentioned",
  "gender": "Gender or Not mentioned",
  "date": "Date or Not mentioned",
  "medicines": [
    {
      "name": "Medicine name",
      "dosage": "Dosage",
      "frequency": "Frequency",
      "instructions": "Instructions"
    }
  ],
  "notes": "Notes or Not mentioned"
}

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
