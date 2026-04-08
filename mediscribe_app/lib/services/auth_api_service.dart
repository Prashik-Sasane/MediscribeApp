import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiUser {
  ApiUser({
    required this.name,
    required this.email,
    required this.city,
    required this.coins,
    this.role = 'patient',
    this.phone = '',
    this.bloodGroup = '',
    this.avatarUrl = '',
    this.specialty = '',
    this.fee = 0,
    this.bio = '',
    this.isOnline = false,
    this.upiId = '',
  });

  final String name;
  final String email;
  final String city;
  final int coins;
  final String role;
  final String phone;
  final String bloodGroup;
  final String avatarUrl;
  final String specialty;
  final int fee;
  final String bio;
  final bool isOnline;
  final String upiId;

  factory ApiUser.fromJson(Map<String, dynamic> json) {
    return ApiUser(
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      city: (json['city'] ?? 'Pune').toString(),
      coins: ((json['coins'] ?? 0) as num).toInt(),
      role: (json['role'] ?? 'patient').toString(),
      phone: (json['phone'] ?? '').toString(),
      bloodGroup: (json['bloodGroup'] ?? '').toString(),
      avatarUrl: (json['avatarUrl'] ?? '').toString(),
      specialty: (json['specialty'] ?? '').toString(),
      fee: ((json['fee'] ?? 0) as num).toInt(),
      bio: (json['bio'] ?? '').toString(),
      isOnline: (json['isOnline'] ?? false) as bool,
      upiId: (json['upiId'] ?? '').toString(),
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
    defaultValue: 'http://localhost:5000/api',
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

  static Future<AuthApiResult> doctorLogin({
    required String email,
    required String password,
  }) {
    return _authCall(
      endpoint: '/auth/doctor/login',
      body: {'email': email, 'password': password},
    );
  }

  static Future<AuthApiResult> doctorSignup({
    required String name,
    required String email,
    required String password,
    required String specialty,
    int experience = 0,
    int fee = 500,
    String bio = '',
  }) {
    return _authCall(
      endpoint: '/auth/doctor/signup',
      body: {
        'name': name, 
        'email': email, 
        'password': password, 
        'specialty': specialty,
        'experience': experience,
        'fee': fee,
        'bio': bio,
      },
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
