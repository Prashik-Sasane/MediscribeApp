import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiAppointment {
  ApiAppointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.dateLabel,
    required this.timeLabel,
    required this.type,
    required this.location,
    required this.status,
    this.prescriptionText = '',
  });

  final String id;
  final String doctorId;
  final String doctorName;
  final String specialty;
  final String dateLabel;
  final String timeLabel;
  final String type;
  final String location;
  final String status;
  final String prescriptionText;

  factory ApiAppointment.fromJson(Map<String, dynamic> json) {
    return ApiAppointment(
      id: (json['id'] ?? '').toString(),
      doctorId: (json['doctorId'] ?? '').toString(),
      doctorName: (json['doctorName'] ?? '').toString(),
      specialty: (json['specialty'] ?? '').toString(),
      dateLabel: (json['dateLabel'] ?? '').toString(),
      timeLabel: (json['timeLabel'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      status: (json['status'] ?? 'upcoming').toString(),
      prescriptionText: (json['prescriptionText'] ?? '').toString(),
    );
  }
}

class AppointmentService {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000/api',
  );

  static Future<List<ApiAppointment>> fetchMine(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/appointments/mine'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode < 200 || response.statusCode >= 300) return [];
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final items = (json['appointments'] as List<dynamic>? ?? []);
      return items.map((e) => ApiAppointment.fromJson(e as Map<String, dynamic>)).toList();
    } on SocketException {
      return [];
    } on FormatException {
      return [];
    }
  }

  static Future<List<ApiAppointment>> fetchDoctorAppointments(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/appointments/doctor'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode < 200 || response.statusCode >= 300) return [];
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final items = (json['appointments'] as List<dynamic>? ?? []);
      return items.map((e) => ApiAppointment.fromJson(e as Map<String, dynamic>)).toList();
    } on SocketException {
      return [];
    } on FormatException {
      return [];
    }
  }

  static Future<ApiAppointment?> book({
    required String token,
    required String doctorId,
    required String dateLabel,
    required String timeLabel,
    String type = 'General checkup',
    String location = 'Clinic',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/appointments'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'doctorId': doctorId,
          'dateLabel': dateLabel,
          'timeLabel': timeLabel,
          'type': type,
          'location': location,
        }),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ApiAppointment.fromJson(json['appointment'] as Map<String, dynamic>);
    } on SocketException {
      return null;
    } on FormatException {
      return null;
    }
  }

  static Future<bool> updateStatus(String token, String appointmentId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/appointments/$appointmentId/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': status}),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}
