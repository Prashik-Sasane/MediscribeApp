import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://mediscribeapp.onrender.com/api',
  );

  /// Create Razorpay order
  static Future<Map<String, dynamic>?> createRazorpayOrder({
    required String token,
    required int amount,
    required String orderType,
    required String orderId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment/create-order'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
          'currency': 'INR',
          'receipt': 'order_${DateTime.now().millisecondsSinceEpoch}',
          'orderType': orderType,
          'orderId': orderId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('Failed to create Razorpay order: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating Razorpay order: $e');
      return null;
    }
  }

  /// Verify Razorpay payment
  static Future<bool> verifyPayment({
    required String token,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String orderId,
    required String orderType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment/verify'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
          'orderId': orderId,
          'orderType': orderType,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        print('Payment verification failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error verifying payment: $e');
      return false;
    }
  }
}
