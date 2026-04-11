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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order #${order['id']?.toString().substring(0, 8).toUpperCase() ?? 'N/A'}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        order['createdAt']?.toString().split('T').first ?? 'Recent',
                        style: const TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                _buildStatusBadge(status),
              ],
            ),
            const Divider(color: Colors.white10, height: 12),
            // Product images and info
            Row(
              children: [
                // Show up to 3 product images
                ...items.take(3).map((item) => _buildProductImage(item)).toList(),
                if (items.length > 3)
                  Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7DFF).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF2E7DFF).withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '+${items.length - 3}',
                        style: const TextStyle(
                          color: Color(0xFF2E7DFF),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "${items.length} Item${items.length > 1 ? 's' : ''}: ${items.take(1).map((i) => i['name'] ?? 'Product').join(', ')}${items.length > 1 ? '...' : ''}",
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "₹${order['total'] ?? 0}",
                  style: const TextStyle(color: Color(0xFF2E7DFF), fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text("Track Order", style: TextStyle(color: Colors.white54, fontSize: 10)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 9),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(Map<String, dynamic> item) {
    final imageUrl = item['imageUrl'] ?? item['image'];
    
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageUrl != null && imageUrl.toString().startsWith('http')
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => _buildDefaultProductIcon(item),
              )
            : _buildDefaultProductIcon(item),
      ),
    );
  }

  Widget _buildDefaultProductIcon(Map<String, dynamic> item) {
    return Container(
      color: const Color(0xFF2E7DFF).withOpacity(0.1),
      child: Icon(
        Icons.inventory_2_rounded,
        color: const Color(0xFF2E7DFF).withOpacity(0.5),
        size: 18,
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
