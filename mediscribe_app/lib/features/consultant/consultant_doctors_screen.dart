import 'package:flutter/material.dart';

class ConsultantSearchScreen extends StatefulWidget {
  const ConsultantSearchScreen({super.key});

  @override
  State<ConsultantSearchScreen> createState() => _ConsultantSearchScreenState();
}

class _ConsultantSearchScreenState extends State<ConsultantSearchScreen> {
  String selectedSpecialty = "All";
  final List<String> specialties = ["All", "Cardiologist", "Dermatologist", "Pediatrician", "Neurologist"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: CustomScrollView(
        slivers: [
          // 1. Premium Glassmorphic AppBar
          SliverAppBar(
            expandedHeight: 120.0,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF0F172A),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              title: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Find Specialist", 
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  Text("Available specialists right now", 
                    style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.tune_rounded, color: Colors.white), onPressed: () {}),
            ],
          ),

          // 2. Search & Specialty Filters
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildGlassSearchBar(),
                  const SizedBox(height: 20),
                  _buildSpecialtyBar(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // 3. Doctor Results
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildPremiumDoctorCard(
                  name: "Dr. Sarah Jenkins",
                  specialty: "Senior Cardiologist",
                  rating: "4.9",
                  reviews: "120",
                  experience: "12 Years",
                  price: "30",
                  imageUrl: "https://images.unsplash.com/photo-1559839734-2b71f1e3c770?w=200",
                  isOnline: true,
                ),
                _buildPremiumDoctorCard(
                  name: "Dr. Marcus Thorne",
                  specialty: "Dermatologist",
                  rating: "4.8",
                  reviews: "85",
                  experience: "8 Years",
                  price: "25",
                  imageUrl: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=200",
                  isOnline: true,
                ),
                _buildPremiumDoctorCard(
                  name: "Dr. Elena Rodriguez",
                  specialty: "Neurologist",
                  rating: "5.0",
                  reviews: "210",
                  experience: "15 Years",
                  price: "45",
                  imageUrl: "https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=200",
                  isOnline: false,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: const TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(Icons.search_rounded, color: Color(0xFF2E7DFF)),
          hintText: "Search doctor by name...",
          hintStyle: TextStyle(color: Colors.white30, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSpecialtyBar() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: specialties.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedSpecialty == specialties[index];
          return GestureDetector(
            onTap: () => setState(() => selectedSpecialty = specialties[index]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2E7DFF) : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF2E7DFF).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
              ),
              child: Center(
                child: Text(specialties[index],
                  style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumDoctorCard({
    required String name,
    required String specialty,
    required String rating,
    required String reviews,
    required String experience,
    required String price,
    required String imageUrl,
    required bool isOnline,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: isOnline ? const Color(0xFF10B981) : Colors.transparent, width: 2),
                      ),
                      child: CircleAvatar(radius: 35, backgroundImage: NetworkImage(imageUrl)),
                    ),
                    if (isOnline)
                      Positioned(
                        right: 5,
                        top: 5,
                        child: Container(
                          height: 12,
                          width: 12,
                          decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(specialty, style: const TextStyle(color: Color(0xFF2E7DFF), fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(rating, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          Text("  •  $reviews Reviews", style: const TextStyle(color: Colors.white24, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Consultation Fee", style: TextStyle(color: Colors.white24, fontSize: 11)),
                    Text("\$$price", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOnline ? const Color(0xFF2E7DFF) : const Color(0xFF334155),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  ),
                  child: Text(isOnline ? "Consult Now" : "Schedule", 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}