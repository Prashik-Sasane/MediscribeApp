// This file should ideally be created or updated to show orders if it's currently a cart
import 'package:flutter/material.dart';
import 'package:mediscribe_app/core/app_state.dart';
import 'package:mediscribe_app/services/order_service.dart';
import 'package:mediscribe_app/widgets/healthcare/order_card.dart';
import 'package:mediscribe_app/widgets/healthcare/order_tracking_sheet.dart';

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
    if (token == null) return;

    final orders = await OrderService.fetchMyOrders(token);
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
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
        title: const Text('My Orders', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7DFF)))
          : _orders.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, color: Colors.white10, size: 100),
                      SizedBox(height: 16),
                      Text('No orders yet', style: TextStyle(color: Colors.white54, fontSize: 18)),
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
                child: const Icon(Icons.medication_outlined, color: Colors.white54),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
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
                      '₹$price',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₹$mrp',
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
    required this.onCheckout,
  });

  final int subtotal;
  final int itemCount;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subtotal • $itemCount items',
                    style: const TextStyle(color: Colors.white60),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹$subtotal',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: onCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7DFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Checkout',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

