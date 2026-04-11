import 'package:flutter/material.dart';
import 'package:mediscribe_app/core/app_state.dart';
import 'package:mediscribe_app/services/cart_service.dart';
import 'package:mediscribe_app/services/order_service.dart';
import 'package:mediscribe_app/services/payment_service.dart';
import 'package:mediscribe_app/services/auth_api_service.dart';
import 'package:mediscribe_app/widgets/healthcare/order_card.dart';
import 'package:mediscribe_app/widgets/healthcare/order_tracking_sheet.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final state = AppScope.of(context);
    final token = state.token;

    if (token == null) {
      print('MyOrders: No token available');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      print('MyOrders: Fetching orders...');
      final orders = await OrderService.fetchMyOrders(token);
      print('MyOrders: Fetched ${orders.length} orders');
      print('MyOrders: Orders data: $orders');

      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('MyOrders: Error fetching orders: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh orders when screen becomes visible
    _fetchOrders();
  }

  void _showTracking(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OrderTrackingSheet(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('My Orders',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7DFF)))
          : _orders.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined,
                          color: Colors.white10, size: 100),
                      SizedBox(height: 16),
                      Text('No orders yet',
                          style:
                              TextStyle(color: Colors.white54, fontSize: 18)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return OrderCard(
                      order: order,
                      onTap: () => _showTracking(order),
                    );
                  },
                ),
    );
  }
}

// Cart Screen with CartService integration
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = [];
  bool _isLoading = true;
  Map<String, dynamic>? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _loadCart();
    _loadUserAddress();
  }

  Future<void> _loadUserAddress() async {
    final token = AppScope.of(context).token;
    if (token == null) return;

    final addresses = await AuthApiService.getAddresses(token);
    if (addresses.isNotEmpty) {
      final defaultAddress = addresses.firstWhere(
        (addr) => addr['isDefault'] == true,
        orElse: () => addresses.first,
      );
      setState(() {
        _selectedAddress = Map<String, dynamic>.from(defaultAddress);
      });
    }
  }

  Future<void> _loadCart() async {
    setState(() => _isLoading = true);
    final items = await CartService.getCartItems();
    setState(() {
      _cartItems = items;
      _isLoading = false;
    });
  }

  Future<void> _updateQuantity(String productId, int quantity) async {
    await CartService.updateQuantity(productId, quantity);
    await _loadCart();
  }

  Future<void> _removeItem(String productId) async {
    await CartService.removeFromCart(productId);
    await _loadCart();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item removed from cart'),
          backgroundColor: Color(0xFF2E7DFF),
        ),
      );
    }
  }

  Future<void> _selectAddress() async {
    // Show address selection/add dialog
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AddressDialog(currentAddress: _selectedAddress),
    );

    if (result != null) {
      setState(() {
        _selectedAddress = result;
      });
    }
  }

  Future<void> _checkout() async {
    final state = AppScope.of(context);
    final token = state.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to checkout')),
      );
      return;
    }

    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    // Require address before checkout
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or add a delivery address'),
          backgroundColor: Colors.orange,
        ),
      );
      await _selectAddress();
      return;
    }

    // Calculate totals
    final subtotal = _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
    final total = subtotal;

    // Show payment confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        backgroundColor: const Color(0xFF1E293B),

        title: const Text(
          'Confirm Order',
          style: TextStyle(color: Colors.white),
        ),

        // ✅ FIXED CONTENT
        content: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total: \$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Payment Method:',
                style: TextStyle(color: Colors.white54),
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7DFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2E7DFF)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.credit_card, color: Color(0xFF2E7DFF)),
                    SizedBox(width: 8),
                    Text(
                      'Stripe (Card Payment)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ✅ ACTIONS (correct)
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7DFF),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Pay with Stripe'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

// ✅ LOADING DIALOG (this part is already correct)
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text(
                    'Processing payment...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    try {
      // Create order
      final items = _cartItems
          .map((item) => OrderItem(
                productId: item.product.id,
                name: item.product.name,
                qty: item.quantity,
                price: item.product.price,
              ))
          .toList();

      print('Cart: Creating order with ${items.length} items, total: $total');
      final orderId = await OrderService.createOrder(
        token: token,
        items: items,
        total: total.toInt(),
      );
      print('Cart: Order created with ID: $orderId');

      if (orderId == null) {
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create order')),
          );
        }
        return;
      }

      // Process Stripe Payment
      final result = await PaymentService.processStripePayment(
        token: token,
        amount: total.toDouble(),
        orderType: 'pharmacy',
        orderId: orderId,
        publishableKey:
            'pk_test_51TKLGCA0vwEId8d1ChT5p251LabT0MZ61Hlq4Jq233SOHNEa6yM80fDFRYOqfXDaHtFn8BredvwBtH974pt3olZu00Sn9lvWwp',
      );

      // Close loading dialog
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (result['success'] == true) {
        // Clear cart
        await CartService.clearCart();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment successful! Order placed.'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to My Orders
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Payment failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog on error
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'Shopping Cart',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7DFF)))
          : _cartItems.isEmpty
              ? const _EmptyCart()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _cartItems.length,
                  itemBuilder: (context, index) {
                    final item = _cartItems[index];
                    return _CartItemCard(
                      name: item.product.name,
                      imageUrl: item.product.imageUrl != null &&
                              item.product.imageUrl!.isNotEmpty
                          ? item.product.imageUrl!
                          : '',
                      price: item.product.price,
                      mrp: (item.product.price * 1.2).toInt(),
                      quantity: item.quantity,
                      onMinus: () => _updateQuantity(
                        item.product.id,
                        item.quantity - 1,
                      ),
                      onPlus: () => _updateQuantity(
                        item.product.id,
                        item.quantity + 1,
                      ),
                      onRemove: () => _removeItem(item.product.id),
                    );
                  },
                ),
      bottomNavigationBar: _cartItems.isNotEmpty
          ? _CheckoutBar(
              subtotal:
                  _cartItems.fold(0, (sum, item) => sum + item.totalPrice),
              itemCount: _cartItems.fold(0, (sum, item) => sum + item.quantity),
              address: _selectedAddress,
              onAddressTap: _selectAddress,
              onCheckout: _checkout,
            )
          : null,
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 86,
              width: 86,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.shopping_bag_outlined,
                  color: Colors.white70, size: 38),
            ),
            const SizedBox(height: 14),
            const Text(
              'Your cart is empty',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add products from Health Shop to see them here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.mrp,
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
    required this.onRemove,
  });

  final String name;
  final String imageUrl;
  final int price;
  final int mrp;
  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111B2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              imageUrl,
              height: 70,
              width: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 70,
                width: 70,
                color: Colors.white.withOpacity(0.05),
                child: const Icon(Icons.medication_outlined,
                    color: Colors.white54),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '\$$price',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$$mrp',
                      style: const TextStyle(
                        color: Colors.white54,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _QtyButton(
                      icon: Icons.remove,
                      onTap: onMinus,
                    ),
                    Container(
                      width: 42,
                      alignment: Alignment.center,
                      child: Text(
                        '$quantity',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _QtyButton(
                      icon: Icons.add,
                      onTap: onPlus,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: onRemove,
                      child: const Text(
                        'Remove',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 34,
        width: 34,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({
    required this.subtotal,
    required this.itemCount,
    this.address,
    required this.onAddressTap,
    required this.onCheckout,
  });

  final int subtotal;
  final int itemCount;
  final Map<String, dynamic>? address;
  final VoidCallback onAddressTap;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Address section
            if (address != null)
              GestureDetector(
                onTap: onAddressTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Color(0xFF2E7DFF), size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${address?['street'] ?? ''}, ${address?['city'] ?? ''}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.edit,
                          color: Color(0xFF2E7DFF), size: 16),
                    ],
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: onAddressTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Row(
                    children: [
                      Icon(Icons.add_location,
                          color: Color(0xFF2E7DFF), size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Add delivery address',
                        style: TextStyle(
                          color: Color(0xFF2E7DFF),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 4),
            // Checkout button
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Subtotal • $itemCount items',
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$$subtotal',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: onCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7DFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text(
                        'Checkout',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressDialog extends StatefulWidget {
  final Map<String, dynamic>? currentAddress;

  const _AddressDialog({this.currentAddress});

  @override
  State<_AddressDialog> createState() => _AddressDialogState();
}

class _AddressDialogState extends State<_AddressDialog> {
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;

  @override
  void initState() {
    super.initState();
    _streetController =
        TextEditingController(text: widget.currentAddress?['street'] ?? '');
    _cityController =
        TextEditingController(text: widget.currentAddress?['city'] ?? '');
    _stateController =
        TextEditingController(text: widget.currentAddress?['state'] ?? '');
    _zipController =
        TextEditingController(text: widget.currentAddress?['zip'] ?? '');
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: const Color(0xFF1E293B),
      title: const Text(
        'Delivery Address',
        style: TextStyle(color: Colors.white),
      ),

      // ✅ CONTENT
      content: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _streetController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Street Address',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _cityController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'City',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _stateController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'State',
                        labelStyle: TextStyle(color: Colors.white54),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _zipController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'ZIP Code',
                        labelStyle: TextStyle(color: Colors.white54),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // ✅ ACTIONS
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.white54),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7DFF),
          ),
          onPressed: () {
            if (_streetController.text.isEmpty ||
                _cityController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill in street and city'),
                ),
              );
              return;
            }

            Navigator.pop(context, {
              'street': _streetController.text,
              'city': _cityController.text,
              'state': _stateController.text,
              'zip': _zipController.text,
            });
          },
          child: const Text('Save Address'),
        ),
      ],
    );
  }
}
