import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static Future<String?> understandPrescription(String ocrText) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return jsonEncode({
        "error":
            "Missing GEMINI_API_KEY. Please add it to assets/.env and restart the app.",
      });
    }

    // Correct model for the v1 API
    final url = Uri.parse(
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
);

    final prompt = '''
You are a medical prescription understanding assistant.

RULES:
- First check if the text looks like a medical prescription.
- If NOT, respond ONLY: {"error": "The provided image does not appear to be a medical prescription. Please upload a clear photo of a prescription."}
- If it IS a prescription:
  - Extract ONLY visible data.
  - No guessing.
  - If missing, set to "Not mentioned".
  - No explanations. Output ONLY valid JSON.

RESPONSE JSON FORMAT:
{
  "doctor": "",
  "hospital": "",
  "license": "",
  "patient": "",
  "age": "",
  "gender": "",
  "date": "",
  "medicines": [
    {
      "name": "",
      "dosage": "",
      "frequency": "",
      "instructions": ""
    }
  ],
  "notes": ""
}

Prescription text:
$ocrText
''';

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "contents": [
                {
                  "parts": [
                    {"text": prompt}
                  ]
                }
              ],
              "safetySettings": [
                {"category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_NONE"},
                {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_NONE"},
                {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_NONE"},
                {"category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_NONE"}
              ]
            }),
          )
          .timeout(const Duration(seconds: 60));

      debugPrint("FULL RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final candidates = data['candidates'];
        if (candidates == null || candidates.isEmpty) {
          return jsonEncode({"error": "No response from Gemini"});
        }

        final parts = candidates[0]['content']?['parts'];
        if (parts == null || parts.isEmpty) {
          return jsonEncode({"error": "Empty response content"});
        }

        return parts[0]['text']?.toString().trim();
      }

      debugPrint(
          'Gemini API error: ${response.statusCode} ${response.reasonPhrase}\n${response.body}');
      return jsonEncode({
        "error":
            "Gemini API request failed (${response.statusCode}). Check network, API key, and model availability.",
      });
    } on TimeoutException {
      return jsonEncode({
        "error":
            "Gemini API timed out. Please try again or check your internet connection.",
      });
    } catch (e) {
      debugPrint('Gemini API exception: $e');
      return jsonEncode({
        "error": "Gemini request failed. Please check your setup and try again.",
      });
    }
  }
}