import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchService {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://mediscribeapp.onrender.com/api',
  );

  static Future<List<Map<String, dynamic>>> globalSearch(String query) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/search?q=$query'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['results'] ?? []);
      }
    } catch (e) {
      print("Search API Error: $e");
    }
    return [];
  }
}
