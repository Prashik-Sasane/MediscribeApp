import 'package:flutter/material.dart';
import 'package:mediscribe_app/features/doctors/doctor_detail_screen.dart';
import 'package:mediscribe_app/services/doctor_api_service.dart';

class ConsultantSearchScreen extends StatefulWidget {
  const ConsultantSearchScreen({super.key});

  @override
  State<ConsultantSearchScreen> createState() => _ConsultantSearchScreenState();
}

class _ConsultantSearchScreenState extends State<ConsultantSearchScreen> {
  String selectedSpecialty = "All";
  final List<String> specialties = ["All", "Cardiologist", "Dermatologist", "Pediatrician", "Neurologist", "Dentist", "General Physician"];
  List<NearbyDoctor> doctors = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() => _loading = true);
    final fetchedDoctors = await DoctorApiService.getAllDoctors(
      specialty: selectedSpecialty == "All" ? '' : selectedSpecialty,
      searchQuery: _searchQuery,
    );
    if (mounted) {
      setState(() {
        doctors = fetchedDoctors;
        _loading = false;
      });
    }
  }

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
          _loading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF2E7DFF))),
                )
              : doctors.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_search_outlined,
                              size: 80,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No doctors found',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Try adjusting your filters',
                              style: TextStyle(color: Colors.white38, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final doc = doctors[index];
                            return _buildPremiumDoctorCard(
                              name: doc.name,
                              specialty: doc.specialty,
                              rating: doc.rating.toStringAsFixed(1),
                              reviews: doc.reviews.toString(),
                              experience: '${doc.experience} Years',
                              price: doc.fee.toString(),
                              imageUrl: doc.imageUrl.isNotEmpty
                                  ? doc.imageUrl
                                  : 'https://i.pravatar.cc/300?u=${doc.id}',
                              isOnline: doc.isOnline,
                              doctor: doc,
                            );
                          },
                          childCount: doctors.length,
                        ),
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
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          icon: Icon(Icons.search_rounded, color: Color(0xFF2E7DFF)),
          hintText: "Search doctor by name...",
          hintStyle: TextStyle(color: Colors.white30, fontSize: 14),
          border: InputBorder.none,
        ),
        onChanged: (value) {
          _searchQuery = value;
          _loadDoctors();
        },
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
            onTap: () {
              setState(() => selectedSpecialty = specialties[index]);
              _loadDoctors();
            },
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
    required NearbyDoctor doctor,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorDetailScreen(doctor: doctor),
          ),
        );
      },
      child: Container(
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
      ),
    );
  }
}