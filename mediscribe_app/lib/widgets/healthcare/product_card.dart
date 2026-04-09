import 'package:flutter/material.dart';
import '../../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: NetworkImage(product.imageUrl),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                if (product.requiresPrescription)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Rx Required",
                        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                const Positioned(
                  right: 15,
                  top: 15,
                  child: Icon(Icons.favorite_border, color: Colors.red, size: 20),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  "By ${product.category}",
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "₹${product.price}",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                        if (product.mrp > product.price)
                          Text(
                            "₹${product.mrp}",
                            style: const TextStyle(
                              color: Colors.white24,
                              fontSize: 10,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    GestureDetector(
                      onTap: onAddToCart,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Color(0xFF2E7DFF), shape: BoxShape.circle),
                        child: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 18),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
