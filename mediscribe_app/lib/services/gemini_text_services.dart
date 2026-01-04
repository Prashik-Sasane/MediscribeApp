import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiTextService {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  static Future<String> cleanPrescriptionText(String rawText) async {
    if (_apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not loaded');
    }

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/'
      'gemini-3-pro-preview:generateContent',
    );

    final body = {
      "contents": [
        {
          "parts": [
            {
              "text":
                  "You are a medical assistant. Clean and format the following "
                  "prescription text into a clear, readable format. Preserve "
                  "medicine names, dosage, frequency, and instructions.\n\n"
                  "$rawText"
            }
          ]
        }
      ]
    };

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "x-goog-api-key": _apiKey,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini text formatting failed');
    }

    final decoded = jsonDecode(response.body);

    return decoded['candidates'][0]['content']['parts'][0]['text']
        .toString()
        .trim();
  }
}
