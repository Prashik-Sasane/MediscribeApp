import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class OrderItem {
  final String productId;
  final String name;
  final int qty;
  final int price;
  const OrderItem({required this.productId, required this.name, required this.qty, required this.price});
  Map<String, dynamic> toJson() => {'productId': productId, 'name': name, 'qty': qty, 'price': price};
}

class OrderService {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://mediscribeapp.onrender.com/api',
  );

  static Future<bool> placeOrder({
    required String token,
    required List<OrderItem> items,
    required int total,
    String address = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/orders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'items': items.map((e) => e.toJson()).toList(),
          'total': total,
          'address': address,
        }),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchMyOrders(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/orders/mine'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode < 200 || response.statusCode >= 300) return [];
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(json['orders'] as List? ?? []);
    } on SocketException {
      return [];
    } on FormatException {
      return [];
    }
  }
}
