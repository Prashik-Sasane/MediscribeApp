import 'package:flutter/material.dart';

class LabTestBookingScreen extends StatefulWidget {
  const LabTestBookingScreen({super.key});

  @override
  State<LabTestBookingScreen> createState() => _LabTestBookingScreenState();
}

class _LabTestBookingScreenState extends State<LabTestBookingScreen> {
  int selectedCategory = 0;

  final List<Map<String, dynamic>> categories = [
    {"name": "All Tests", "icon": Icons.grid_view_rounded},
    {"name": "Diabetes", "icon": Icons.water_drop_rounded},
    {"name": "Heart", "icon": Icons.favorite_rounded},
    {"name": "Full Body", "icon": Icons.accessibility_new_rounded},
    {"name": "Kidney", "icon": Icons.medication_liquid_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A).withOpacity(0.8),
        elevation: 0,
        centerTitle: false,
        title: const Text("Lab Tests", 
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _buildAppBarAction(Icons.history_rounded),
          _buildAppBarAction(Icons.shopping_cart_outlined),
          const SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          // Background decorative glow
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2E7DFF).withOpacity(0.05),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 110, left: 20, right: 20, bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModernSearchBar(),
                const SizedBox(height: 30),
                
                _buildSectionHeader("Browse by Category"),
                const SizedBox(height: 15),
                _buildCategoryChips(),
                
                const SizedBox(height: 30),
                _buildSectionHeader("Exclusive Health Packages"),
                const SizedBox(height: 15),
                
                _buildPremiumPackageCard(
                  title: "Executive Full Body Checkup",
                  tests: "Includes 84 parameters",
                  price: "89",
                  oldPrice: "140",
                  tag: "VALUED CHOICE",
                  tagColor: Colors.amber,
                  features: ["NABL Certified", "Home Collection", "Report in 24h"],
                ),
                _buildPremiumPackageCard(
                  title: "Sugar & Insulin Screening",
                  tests: "Includes 5 parameters",
                  price: "35",
                  oldPrice: "50",
                  tag: "BEST SELLER",
                  tagColor: const Color(0xFF10B981),
                  features: ["Fast Tracking", "Doctor Consultation"],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarAction(IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 22),
        onPressed: () {},
      ),
    );
  }

  Widget _buildModernSearchBar() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: const TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search tests, packages or symptoms...",
          hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF2E7DFF)),
          suffixIcon: Icon(Icons.tune_rounded, color: Colors.white38, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const Icon(Icons.arrow_forward_rounded, color: Colors.white24, size: 20),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedCategory == index;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2E7DFF) : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? Colors.white24 : Colors.white.withOpacity(0.05),
                ),
              ),
              child: Row(
                children: [
                  Icon(categories[index]['icon'], 
                    size: 18, color: isSelected ? Colors.white : Colors.white54),
                  const SizedBox(width: 8),
                  Text(categories[index]['name'], 
                    style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumPackageCard({
    required String title,
    required String tests,
    required String price,
    required String oldPrice,
    required String tag,
    required Color tagColor,
    required List<String> features,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1E293B), const Color(0xFF1E293B).withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: tagColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                      child: Text(tag, style: TextStyle(color: tagColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                    ),
                    const Icon(Icons.bookmark_border_rounded, color: Colors.white24),
                  ],
                ),
                const SizedBox(height: 15),
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(tests, style: const TextStyle(color: Color(0xFF10B981), fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 15),
                
                // Feature horizontal list
                Wrap(
                  spacing: 10,
                  children: features.map((f) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: Colors.white38, size: 14),
                      const SizedBox(width: 4),
                      Text(f, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  )).toList(),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("\$$price", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text("\$$oldPrice", style: const TextStyle(color: Colors.white24, fontSize: 14, decoration: TextDecoration.lineThrough)),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7DFF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text("Book Now", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}