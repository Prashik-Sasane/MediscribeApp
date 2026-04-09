import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mediscribe_app/models/lab_test.dart';

class LabService {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://mediscribeapp.onrender.com/api',
  );

  static Future<List<LabTest>> fetchLabTests({
    String? category,
    String? query,
    String? tag,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/labs').replace(
        queryParameters: <String, String>{
          if (category != null && category.isNotEmpty) 'category': category,
          if (query != null && query.isNotEmpty) 'q': query,
          if (tag != null && tag.isNotEmpty) 'tag': tag,
        },
      );
      final response = await http.get(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) return [];
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final items = (json['labs'] as List<dynamic>? ?? []);
      return items.map((e) => LabTest.fromJson(e as Map<String, dynamic>)).toList();
    } on SocketException {
      return [];
    } on FormatException {
      return [];
    }
  }
}

