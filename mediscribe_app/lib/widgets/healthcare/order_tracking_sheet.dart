import 'package:flutter/material.dart';

class OrderTrackingSheet extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderTrackingSheet({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order['status']?.toString().toLowerCase() ?? 'pending';
    final steps = ["pending", "confirmed", "dispatched", "delivered"];
    final currentStepIndex = steps.indexOf(status);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order Tracking",
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "#${order['id']?.toString().substring(0, 8).toUpperCase()}",
                style: const TextStyle(color: Color(0xFF2E7DFF), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildTimeline(steps, currentStepIndex),
          const SizedBox(height: 32),
          const Text(
            "Order Details",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ...(order['items'] as List? ?? []).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item['name'] ?? 'Product', style: const TextStyle(color: Colors.white70)),
                Text("x${item['qty'] ?? 1}", style: const TextStyle(color: Colors.white38)),
              ],
            ),
          )),
          const Divider(color: Colors.white10, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Amount", style: TextStyle(color: Colors.white54)),
              Text("₹${order['total'] ?? 0}",
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTimeline(List<String> steps, int currentIndex) {
    return Column(
      children: List.generate(steps.length, (index) {
        final isCompleted = index <= currentIndex;
        final isLast = index == steps.length - 1;
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isCompleted ? const Color(0xFF2E7DFF) : Colors.white10,
                    shape: BoxShape.circle,
                    border: isCompleted ? null : Border.all(color: Colors.white24),
                  ),
                  child: isCompleted 
                    ? const Icon(Icons.check, color: Colors.white, size: 12)
                    : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted ? const Color(0xFF2E7DFF) : Colors.white10,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  steps[index].toUpperCase(),
                  style: TextStyle(
                    color: isCompleted ? Colors.white : Colors.white24,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  _getStatusSubtitle(steps[index]),
                  style: TextStyle(
                    color: isCompleted ? Colors.white54 : Colors.white10,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  String _getStatusSubtitle(String status) {
    switch (status) {
      case 'pending': return "We have received your order";
      case 'confirmed': return "Pharmacy has confirmed your order";
      case 'dispatched': return "Your order is on the way";
      case 'delivered': return "Order successfully delivered";
      default: return "";
    }
  }
}
