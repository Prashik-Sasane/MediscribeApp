import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

class PaymentService {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://mediscribeapp.onrender.com/api',
  );

  /// Initialize Stripe with publishable key
  static void initializeStripe(String publishableKey) {
    Stripe.publishableKey = publishableKey;
  }

  /// Create Stripe PaymentIntent
  static Future<Map<String, dynamic>?> createStripePayment({
    required String token,
    required double amount,
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
          'currency': 'usd',
          'orderType': orderType,
          'orderId': orderId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data;
        }
      }
      print('Failed to create Stripe payment: ${response.body}');
      return null;
    } catch (e) {
      print('Error creating Stripe payment: $e');
      return null;
    }
  }

  /// Present Stripe payment sheet
  static Future<bool> presentPaymentSheet({
    required String clientSecret,
    String merchantDisplayName = 'Mediscribe',
  }) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: merchantDisplayName,
          // style: ThemeMode.dark,
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      return true;
    } catch (e) {
      print('Error presenting payment sheet: $e');
      return false;
    }
  }

  /// Verify Stripe payment after completion
  static Future<bool> verifyStripePayment({
    required String token,
    required String paymentIntentId,
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
          'paymentIntentId': paymentIntentId,
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

  /// Complete payment flow: create intent, present sheet, verify
  static Future<Map<String, dynamic>> processStripePayment({
    required String token,
    required double amount,
    required String orderType,
    required String orderId,
    String publishableKey = 'pk_test_your_key_here',
  }) async {
    try {
      // Initialize Stripe
      initializeStripe(publishableKey);

      // Step 1: Create PaymentIntent
      final paymentData = await createStripePayment(
        token: token,
        amount: amount,
        orderType: orderType,
        orderId: orderId,
      );

      if (paymentData == null) {
        return {'success': false, 'message': 'Failed to create payment'};
      }

      // Step 2: Present Payment Sheet
      final paymentSuccess = await presentPaymentSheet(
        clientSecret: paymentData['clientSecret'],
      );

      if (!paymentSuccess) {
        return {'success': false, 'message': 'Payment cancelled'};
      }

      // Step 3: Verify Payment
      final verified = await verifyStripePayment(
        token: token,
        paymentIntentId: paymentData['paymentIntentId'],
        orderId: orderId,
        orderType: orderType,
      );

      if (verified) {
        return {
          'success': true,
          'paymentIntentId': paymentData['paymentIntentId'],
          'message': 'Payment successful',
        };
      } else {
        return {'success': false, 'message': 'Payment verification failed'};
      }
    } catch (e) {
      print('Stripe payment error: $e');
      return {'success': false, 'message': 'Payment failed: $e'};
    }
  }
}
