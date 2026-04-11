import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchService {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://mediscribeapp.onrender.com/api',
  );

  static Future<List<Map<String, dynamic>>> globalSearch(String query) async {
    try {
      print('Search: Searching for "$query"...');
      final response = await http.get(Uri.parse('$_baseUrl/search?q=$query'));
      print('Search: Response status: ${response.statusCode}');
      print('Search: Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Backend returns: { doctors: [], medicines: [], labTests: [] }
        // We need to convert to: [{ type, id, title, subtitle, ... }, ...]
        final List<Map<String, dynamic>> results = [];
        
        // Process doctors
        if (data['doctors'] != null) {
          for (var doctor in data['doctors']) {
            results.add({
              'type': 'doctor',
              'id': doctor['id'],
              'title': doctor['title'],
              'subtitle': doctor['subtitle'],
              'imageUrl': doctor['imageUrl'],
              'rating': doctor['rating'],
            });
          }
        }
        
        // Process medicines
        if (data['medicines'] != null) {
          for (var medicine in data['medicines']) {
            results.add({
              'type': 'medicine',
              'id': medicine['id'],
              'title': medicine['title'],
              'subtitle': medicine['subtitle'],
              'imageUrl': medicine['imageUrl'],
              'price': medicine['price'],
            });
          }
        }
        
        // Process lab tests
        if (data['labTests'] != null) {
          for (var labTest in data['labTests']) {
            results.add({
              'type': 'lab_test',
              'id': labTest['id'],
              'title': labTest['title'],
              'subtitle': labTest['subtitle'],
              'imageUrl': labTest['imageUrl'],
              'price': labTest['price'],
            });
          }
        }
        
        print('Search: Found ${results.length} results (${data['doctors']?.length ?? 0} doctors, ${data['medicines']?.length ?? 0} medicines, ${data['labTests']?.length ?? 0} lab tests)');
        return results;
      } else {
        print('Search: Failed with status ${response.statusCode}');
      }
    } catch (e) {
      print("Search API Error: $e");
    }
    return [];
  }
}
