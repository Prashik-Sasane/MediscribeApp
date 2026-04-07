import 'package:flutter/material.dart';
import 'package:mediscribe_app/features/doctors/bookappointment.dart';
import 'package:mediscribe_app/services/doctor_api_service.dart';

class DoctorDetailScreen extends StatelessWidget {
  final NearbyDoctor doctor;
  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Doctor Details", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.favorite_border, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: NetworkImage(doctor.imageUrl),
            ),
            const SizedBox(height: 16),
            Text(doctor.name,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            Text(doctor.specialty, style: const TextStyle(color: Colors.white54, fontSize: 16)),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(Icons.people_alt_outlined, "Consultations", "${(doctor.rating * 200).toInt()}+"),
                  _buildStatItem(Icons.work_outline, "Years Exp.", "5+"),
                  _buildStatItem(Icons.star_outline, "Rating", "${doctor.rating.toStringAsFixed(1)}"),
                  _buildStatItem(Icons.chat_bubble_outline, "Reviews", "${(doctor.rating * 300).toInt()}+"),
                ],
              ),
            ),

            _buildSectionHeader("About Doctor"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Experienced ${doctor.specialty.toLowerCase()} with a patient-focused approach. Offers consultations at ₹${doctor.fee} per visit.",
                style: const TextStyle(color: Colors.white70, height: 1.5),
              ),
            ),

            _buildSectionHeader("Consultation Fee"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "₹${doctor.fee}",
                      style: const TextStyle(color: Color(0xFF2E7DFF), fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Distance: ${doctor.distanceKm.toStringAsFixed(1)} km away",
                      style: const TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            _buildSectionHeader("Doctor Contact"),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(doctor.imageUrl),
                backgroundColor: const Color(0xFF1E293B),
              ),
              title: Text(doctor.name, style: const TextStyle(color: Colors.white)),
              subtitle: Text(doctor.specialty, style: const TextStyle(color: Colors.white38)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIconButton(Icons.chat),
                  const SizedBox(width: 10),
                  _buildIconButton(Icons.phone),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        color: const Color(0xFF0F172A),
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7DFF),
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BookingScreen(doctor: doctor)),
            );
          },
          child: const Text("Book Appointment", style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFF1E293B),
          child: Icon(icon, color: const Color(0xFF2E7DFF), size: 20),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}