import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String id;
  final String senderId;
  final String senderRole;
  final String senderName;
  final String text;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderRole,
    required this.senderName,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: (json['id'] ?? '').toString(),
      senderId: (json['senderId'] ?? '').toString(),
      senderRole: (json['senderRole'] ?? 'patient').toString(),
      senderName: (json['senderName'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}

class ChatService {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000/api',
  );

  static Future<List<ChatMessage>> getMessages(String token, String appointmentId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/chat/$appointmentId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode < 200 || response.statusCode >= 300) return [];
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final items = (json['messages'] as List<dynamic>? ?? []);
      return items.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
    } on SocketException {
      return [];
    } on FormatException {
      return [];
    }
  }

  static Future<ChatMessage?> sendMessage(String token, String appointmentId, String text) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/$appointmentId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'text': text}),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ChatMessage.fromJson(json['message'] as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
