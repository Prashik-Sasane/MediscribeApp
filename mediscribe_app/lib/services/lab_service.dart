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

  /// Create a lab test booking and return the booking ID
  static Future<String?> createBooking({
    required String token,
    required String labTestId,
    required Map<String, dynamic> address,
    required DateTime preferredDate,
    required String timeSlot,
    required int amount,
  }) async {
    try {
      final requestBody = {
        'labTestId': labTestId,
        'address': {
          'label': address['label'] ?? 'Home',
          'fullAddress': address['fullAddress'] ?? address['street'] ?? '',
          'lat': address['lat'],
          'lng': address['lng'],
          'phone': address['phone'] ?? '',
        },
        'preferredDate': preferredDate.toIso8601String(),
        'timeSlot': timeSlot,
        'paymentMethod': 'stripe',
      };

      print('LabService: Creating booking with body: $requestBody');

      final response = await http.post(
        Uri.parse('$_baseUrl/labs/book'), // Correct endpoint
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('LabService: Response status: ${response.statusCode}');
      print('LabService: Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        // Try multiple possible response structures
        final bookingId = json['booking']?['_id'] ?? 
                         json['booking']?['id'] ?? 
                         json['_id'] ?? 
                         json['id'] ??
                         json['bookingId'];
        print('LabService: Extracted booking ID: $bookingId');
        return bookingId;
      } else {
        print('LabService: Error response: ${response.body}');
      }
      return null;
    } catch (e) {
      print('LabService: Exception during booking creation: $e');
      return null;
    }
  }
}

