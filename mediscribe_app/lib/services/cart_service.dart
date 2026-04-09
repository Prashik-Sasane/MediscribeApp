import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  int get totalPrice => product.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'];
    final quantityValue = json['quantity'];

    return CartItem(
      product: Product.fromJson(productJson is Map<String, dynamic> ? productJson : <String, dynamic>{}),
      quantity: int.tryParse(quantityValue?.toString() ?? '') ?? 1,
    );
  }
}

class CartService {
  static const String _cartKey = 'mediscribe_cart';

  static Future<List<CartItem>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getString(_cartKey);
    
    if (cartData == null || cartData.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(cartData);
      if (decoded is! List) {
        return [];
      }

      return decoded
          .where((item) => item is Map<String, dynamic> && item['product'] is Map<String, dynamic>)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading cart: $e');
      return [];
    }
  }

  static Future<void> saveCartItems(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((item) => item.toJson()).toList();
    await prefs.setString(_cartKey, jsonEncode(jsonList));
  }

  static Future<void> addToCart(Product product, {int quantity = 1}) async {
    final items = await getCartItems();
    
    // Check if product already exists
    final existingIndex = items.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex != -1) {
      items[existingIndex].quantity += quantity;
    } else {
      items.add(CartItem(product: product, quantity: quantity));
    }
    
    await saveCartItems(items);
  }

  static Future<void> removeFromCart(String productId) async {
    final items = await getCartItems();
    items.removeWhere((item) => item.product.id == productId);
    await saveCartItems(items);
  }

  static Future<void> updateQuantity(String productId, int quantity) async {
    final items = await getCartItems();
    final index = items.indexWhere((item) => item.product.id == productId);
    
    if (index != -1) {
      if (quantity <= 0) {
        items.removeAt(index);
      } else {
        items[index].quantity = quantity;
      }
      await saveCartItems(items);
    }
  }

  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }

  static Future<int> getCartCount() async {
    final items = await getCartItems();
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  static Future<int> getCartTotal() async {
    final items = await getCartItems();
    return items.fold<int>(0, (sum, item) => sum + item.totalPrice);
  }

  static Future<bool> requiresPrescription() async {
    final items = await getCartItems();
    return items.any((item) => item.product.requiresPrescription);
  }
}
