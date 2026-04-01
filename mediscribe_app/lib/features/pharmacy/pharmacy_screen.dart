import 'package:flutter/material.dart';

class PharmacyScreen extends StatelessWidget {
  const PharmacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Health Shop"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.shopping_cart_outlined),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔎 SEARCH BAR
            TextField(
              decoration: InputDecoration(
                hintText: "Search medicine...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 🎁 OFFER BANNER
            Container(
              height: 140,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff2E7DFF), Color(0xff5BA4FF)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "15% OFF\nMedicine at your doorstep",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(Icons.local_shipping,
                        color: Colors.white, size: 50)
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            /// 🧩 CATEGORIES
            _sectionTitle("Categories"),

            const SizedBox(height: 14),

            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _categoryItem(Icons.medication, "Medicines"),
                  _categoryItem(Icons.energy_savings_leaf, "Supplements"),
                  _categoryItem(Icons.monitor_heart, "Devices"),
                  _categoryItem(Icons.spa, "Personal Care"),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// 🛒 PRODUCTS
            _sectionTitle("Bestseller Products"),
            const SizedBox(height: 14),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 220,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemBuilder: (context, index) {
                return _productCard();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// SECTION TITLE
  static Widget _sectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const Text("See All", style: TextStyle(color: Colors.grey))
      ],
    );
  }
}

/// CATEGORY ITEM
class _categoryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  const _categoryItem(this.icon, this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Color(0xff2E7DFF), size: 28),
          const SizedBox(height: 8),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 12))
        ],
      ),
    );
  }
}

/// PRODUCT CARD
class _productCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Center(
              child: Icon(Icons.medication,
                  size: 60, color: Colors.white),
            ),
          ),
          const Text("Cold & Flu Relief",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("₹199",
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Add to Cart"),
          )
        ],
      ),
    );
  }
}
