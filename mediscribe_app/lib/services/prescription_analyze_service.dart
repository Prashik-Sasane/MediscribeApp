import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class PrescriptionAnalyzeService {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://mediscribeapp.onrender.com/api',
  );

  /// Uploads an image to backend which calls Gemini server-side.
  /// Returns Gemini's raw text (expected to be JSON string).
  static Future<String> analyzePrescriptionImage(File image) async {
    final uri = Uri.parse('$_baseUrl/gemini/prescription');

    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath('image', image.path),
    );

    http.StreamedResponse streamed;
    try {
      streamed = await request.send().timeout(const Duration(seconds: 55));
    } on TimeoutException {
      return jsonEncode({
        "error":
            "Backend timed out while analyzing the prescription. Please try again.",
      });
    } catch (e) {
      return jsonEncode({
        "error":
            "Cannot reach backend. Please check API_BASE_URL / internet and try again.",
      });
    }

    final response = await http.Response.fromStream(streamed);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final text = (data['text'] ?? '').toString();
        return text.trim().isEmpty
            ? jsonEncode({
                "error":
                    "Backend returned an empty result. Please try a clearer image.",
              })
            : text;
      } catch (_) {
        // If backend ever returns plain text.
        return response.body;
      }
    }

    // Forward backend error in a UI-friendly way (include backend message/details).
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final backendMsg = (data['error'] ?? data['message'] ?? '').toString();
      final details = data['details'];

      String msg = backendMsg.trim().isEmpty
          ? 'Analysis failed (${response.statusCode}).'
          : backendMsg.trim();

      // If Gemini returned a structured error body, surface its message too.
      final geminiMsg = (details is Map && details['error'] is Map)
          ? (details['error']['message'] ?? '').toString()
          : '';
      if (geminiMsg.trim().isNotEmpty) {
        msg = '$msg\n$geminiMsg';
      }

      return jsonEncode({"error": msg});
    } catch (_) {
      return jsonEncode({
        "error":
            "Analysis failed (${response.statusCode}). Please verify backend is running and configured.",
      });
    }
  }
}

