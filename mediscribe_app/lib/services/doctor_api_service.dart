import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class NearbyDoctor {
  NearbyDoctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.imageUrl,
    required this.rating,
    required this.fee,
    required this.distanceKm,
  });

  final String id;
  final String name;
  final String specialty;
  final String imageUrl;
  final double rating;
  final int fee;
  final double distanceKm;

  factory NearbyDoctor.fromJson(Map<String, dynamic> json) {
    return NearbyDoctor(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      specialty: (json['specialty'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      rating: ((json['rating'] ?? 0) as num).toDouble(),
      fee: ((json['fee'] ?? 500) as num).toInt(),
      distanceKm: ((json['distanceKm'] ?? 0) as num).toDouble(),
    );
  }
}

class DoctorApiService {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000/api',
  );

  static Future<List<NearbyDoctor>> getNearbyDoctors({
    required double lat,
    required double lng,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/doctors/nearby?lat=$lat&lng=$lng');
      final response = await http.get(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return [];
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final doctors = (json['doctors'] as List<dynamic>? ?? []);
      return doctors
          .map((item) => NearbyDoctor.fromJson(item as Map<String, dynamic>))
          .toList();
    } on SocketException {
      return [];
    } on FormatException {
      return [];
    }
  }
}
