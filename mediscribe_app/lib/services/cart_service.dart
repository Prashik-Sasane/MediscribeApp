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
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'] ?? 1,
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
      final List<dynamic> jsonList = jsonDecode(cartData);
      return jsonList.map((json) => CartItem.fromJson(json)).toList();
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
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  static Future<int> getCartTotal() async {
    final items = await getCartItems();
    return items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  static Future<bool> requiresPrescription() async {
    final items = await getCartItems();
    return items.any((item) => item.product.requiresPrescription);
  }
}
