import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class PlaceResult {
  final String id;
  final String name;
  final String displayName;
  final String address;
  final double lat;
  final double lon;
  final String type;

  const PlaceResult({
    required this.id,
    required this.name,
    required this.displayName,
    required this.address,
    required this.lat,
    required this.lon,
    required this.type,
  });

  factory PlaceResult.fromJson(Map<String, dynamic> json) {
    return PlaceResult(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      displayName: (json['displayName'] ?? json['name'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      lat: ((json['lat'] ?? 0) as num).toDouble(),
      lon: ((json['lng'] ?? json['lon'] ?? 0) as num).toDouble(),
      type: (json['type'] ?? '').toString(),
    );
  }
}

class NearbyClinic {
  final String id;
  final String name;
  final String specialty;
  final String imageUrl;
  final String address;
  final String type;
  final double rating;
  final double distanceKm;
  final double lat;
  final double lng;
  final bool isOnline;

  const NearbyClinic({
    required this.id,
    required this.name,
    required this.specialty,
    required this.imageUrl,
    required this.address,
    required this.type,
    required this.rating,
    required this.distanceKm,
    required this.lat,
    required this.lng,
    required this.isOnline,
  });

  factory NearbyClinic.fromJson(Map<String, dynamic> json) {
    return NearbyClinic(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      specialty: (json['specialty'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      type: (json['type'] ?? 'Clinic').toString(),
      rating: ((json['rating'] ?? 0) as num).toDouble(),
      distanceKm: ((json['distanceKm'] ?? 0) as num).toDouble(),
      lat: ((json['lat'] ?? 0) as num).toDouble(),
      lng: ((json['lng'] ?? 0) as num).toDouble(),
      isOnline: (json['isOnline'] ?? false) as bool,
    );
  }
}

class LocationService {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://mediscribeapp.onrender.com/api',
  );

  static Future<List<PlaceResult>> searchPlaces(String query, {String type = ''}) async {
    try {
      final uri = Uri.parse('$_baseUrl/location/search').replace(
        queryParameters: {
          'q': query,
          if (type.isNotEmpty) 'type': type,
        },
      );
      final response = await http.get(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) return [];
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final items = (json['places'] as List<dynamic>? ?? []);
      return items.map((e) => PlaceResult.fromJson(e as Map<String, dynamic>)).toList();
    } on SocketException {
      return [];
    } on FormatException {
      return [];
    }
  }

  static Future<List<NearbyClinic>> fetchNearbyClinics(double lat, double lng, {double radiusKm = 20}) async {
    try {
      final uri = Uri.parse('$_baseUrl/location/nearby-clinics').replace(
        queryParameters: {
          'lat': lat.toString(),
          'lng': lng.toString(),
          'radiusKm': radiusKm.toString(),
        },
      );
      final response = await http.get(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) return [];
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final items = (json['clinics'] as List<dynamic>? ?? []);
      return items.map((e) => NearbyClinic.fromJson(e as Map<String, dynamic>)).toList();
    } on SocketException {
      return [];
    } on FormatException {
      return [];
    }
  }
}
