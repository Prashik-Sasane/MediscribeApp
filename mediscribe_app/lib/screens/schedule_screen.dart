import 'package:flutter/material.dart';
import 'package:mediscribe_app/features/doctors/doctor_detail_screen.dart';
import 'package:mediscribe_app/features/doctors/doctor_list_screen.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  // Mock data for the list
  final List<Map<String, dynamic>> doctors = [
     {
      "name": "Dr. James Chen",
      "specialty": "Cardiologist",
      "rating": 4.8,
      "reviews": 420,
      "price": 40,
      "image": "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=200",
    },
    {
      "name": "Dr. James Chen",
      "specialty": "Cardiologist",
      "rating": 4.8,
      "reviews": 420,
      "price": 40,
      "image": "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=200",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark Navy background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Find Doctors", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: const TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: TextStyle(color: Colors.white38, fontSize: 15),
                        prefixIcon: Icon(Icons.search_rounded, color: Colors.white54),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                        suffixIcon: Icon(Icons.tune_rounded, color: Colors.white54), // Best icon for settings/filter
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                // Filter Button
                GestureDetector(
                  onTap: () => _showFilterSheet(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7DFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Doctor List
          Expanded(
            child: ListView.builder(
              itemCount: doctors.length,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (context, index) {
                final doc = doctors[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to Detail Page (Created in previous step)
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DoctorDetailScreen()),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        // Left Side: Image
                        ClipRRect(
                          // borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            doc['image'],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 15),
                        // Right Side: Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doc['name'], 
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(doc['specialty'], style: const TextStyle(color: Colors.white38, fontSize: 13)),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 16),
                                  Text(" ${doc['rating']} ", 
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  Text("(${doc['reviews']} Reviews)", 
                                    style: const TextStyle(color: Colors.white38, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text("\$${doc['price']}/Consultation", 
                                style: const TextStyle(color: Color(0xFF2E7DFF), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => const FilterBottomSheet(),
    );
  }
}