import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mediscribe_app/core/app_state.dart';

class ApiUser {
  ApiUser({
    required this.name,
    required this.email,
    required this.city,
    required this.coins,
    required this.appointments,
  });

  final String name;
  final String email;
  final String city;
  final int coins;
  final List<Appointment> appointments;

  factory ApiUser.fromJson(Map<String, dynamic> json) {
    final items = (json['appointments'] as List<dynamic>? ?? []);
    return ApiUser(
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      city: (json['city'] ?? 'Pune').toString(),
      coins: (json['coins'] ?? 0) as int,
      appointments: items.map((item) {
        final map = item as Map<String, dynamic>;
        return Appointment(
          doctorName: (map['doctorName'] ?? '').toString(),
          specialty: (map['specialty'] ?? '').toString(),
          dateLabel: (map['dateLabel'] ?? '').toString(),
          timeLabel: (map['timeLabel'] ?? '').toString(),
          type: (map['type'] ?? '').toString(),
          location: (map['location'] ?? '').toString(),
        );
      }).toList(),
    );
  }
}

class AuthResponse {
  AuthResponse({required this.token, required this.user});

  final String token;
  final ApiUser user;
}

class AuthApiResult {
  AuthApiResult({this.data, this.error});

  final AuthResponse? data;
  final String? error;
}

class AuthApiService {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.117.14.49:5000/api',
  );

  static Future<AuthApiResult> login({
    required String email,
    required String password,
  }) {
    return _authCall(
      endpoint: '/auth/login',
      body: {'email': email, 'password': password},
    );
  }

  static Future<AuthApiResult> signup({
    required String name,
    required String email,
    required String password,
  }) {
    return _authCall(
      endpoint: '/auth/signup',
      body: {'name': name, 'email': email, 'password': password},
    );
  }

  static Future<AuthApiResult> _authCall({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        try {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          return AuthApiResult(error: (json['message'] ?? 'Request failed').toString());
        } on FormatException {
          return AuthApiResult(error: 'Request failed with code ${response.statusCode}');
        }
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final token = (json['token'] ?? '').toString();
      final userMap = json['user'] as Map<String, dynamic>? ?? {};
      return AuthApiResult(
        data: AuthResponse(
          token: token,
          user: ApiUser.fromJson(userMap),
        ),
      );
    } on SocketException {
      return AuthApiResult(error: 'Cannot reach backend. Check API_BASE_URL and network.');
    } on FormatException {
      return AuthApiResult(error: 'Invalid server response format.');
    }
  }
}
