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
    this.experience = 0,
    this.reviews = 0,
    this.bio = '',
    this.isOnline = false,
    this.isVerified = false,
    this.licenseNumber = '',
    this.phone = '',
    this.email = '',
  });

  final String id;
  final String name;
  final String specialty;
  final String imageUrl;
  final double rating;
  final int fee;
  final double distanceKm;
  final int experience;
  final int reviews;
  final String bio;
  final bool isOnline;
  final bool isVerified;
  final String licenseNumber;
  final String phone;
  final String email;

  factory NearbyDoctor.fromMap(Map<String, dynamic> map) {
    return NearbyDoctor(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      specialty: (map['specialty'] ?? '').toString(),
      imageUrl: (map['imageUrl'] ?? '').toString(),
      rating: ((map['rating'] ?? 0) as num).toDouble(),
      fee: ((map['fee'] ?? 500) as num).toInt(),
      distanceKm: ((map['distanceKm'] ?? 0) as num).toDouble(),
      experience: ((map['experience'] ?? 0) as num).toInt(),
      reviews: ((map['reviews'] ?? 0) as num).toInt(),
      bio: (map['bio'] ?? '').toString(),
      isOnline: (map['isOnline'] ?? false) as bool,
      isVerified: (map['isVerified'] ?? false) as bool,
      licenseNumber: (map['licenseNumber'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
    );
  }
}

class DoctorApiService {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://mediscribeapp.onrender.com/api',
  );

  static Future<List<NearbyDoctor>> getAllDoctors({
    String specialty = '',
    String searchQuery = '',
    int page = 1,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
      };
      if (specialty.isNotEmpty) queryParams['specialty'] = specialty;
      if (searchQuery.isNotEmpty) queryParams['q'] = searchQuery;

      final uri = Uri.parse('$_baseUrl/doctors').replace(queryParameters: queryParams);
      final response = await http.get(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return [];
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final doctors = (json['doctors'] as List<dynamic>? ?? []);
      return doctors
          .map((item) => NearbyDoctor.fromMap(item as Map<String, dynamic>))
          .toList();
    } on SocketException {
      return [];
    } on FormatException {
      return [];
    }
  }

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
          .map((item) => NearbyDoctor.fromMap(item as Map<String, dynamic>))
          .toList();
    } on SocketException {
      return [];
    } on FormatException {
      return [];
    }
  }

  static Future<NearbyDoctor?> getDoctorById(String id) async {
    try {
      final uri = Uri.parse('$_baseUrl/doctors/$id');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NearbyDoctor.fromMap(data['doctor']);
      }
    } catch (e) {
      print("Get Doctor Error: $e");
    }
    return null;
  }
}
