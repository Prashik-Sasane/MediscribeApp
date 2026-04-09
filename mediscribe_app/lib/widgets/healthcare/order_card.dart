import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = order['status']?.toString().toLowerCase() ?? 'pending';
    final items = order['items'] as List? ?? [];
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order #${order['id']?.toString().substring(0, 8).toUpperCase() ?? 'N/A'}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order['createdAt']?.toString().split('T').first ?? 'Recent',
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
                _buildStatusBadge(status),
              ],
            ),
            const Divider(color: Colors.white10, height: 24),
            Text(
              "${items.length} Items: ${items.take(2).map((i) => i['name']).join(', ')}${items.length > 2 ? '...' : ''}",
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "₹${order['total'] ?? 0}",
                  style: const TextStyle(color: Color(0xFF2E7DFF), fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Row(
                  children: [
                    Text("Track Order", style: TextStyle(color: Colors.white54, fontSize: 12)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 12),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'delivered': color = Colors.green; break;
      case 'dispatched': color = Colors.orange; break;
      case 'cancelled': color = Colors.red; break;
      default: color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}
