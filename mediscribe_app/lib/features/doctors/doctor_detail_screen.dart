import 'package:flutter/material.dart';
import 'package:mediscribe_app/screens/appointment.dart';
import 'package:mediscribe_app/features/doctors/bookappointment.dart';
class DoctorDetailScreen extends StatelessWidget {
  const DoctorDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark Navy
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
            // Doctor Image & Basic Info
            const CircleAvatar(
              radius: 80,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1559839734-2b71f1e3c770?w=400'),
            ),
            const SizedBox(height: 16),
            const Text("Dr. Jenny William", 
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("Dentist", style: TextStyle(color: Colors.white54, fontSize: 16)),
            
            // Stats Row (Patients, Experience, Rating, Reviews)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(Icons.people_alt_outlined, "3,500+", "Patients"),
                  _buildStatItem(Icons.work_outline, "6+", "Years Exp."),
                  _buildStatItem(Icons.star_outline, "4.9+", "Rating"),
                  _buildStatItem(Icons.chat_bubble_outline, "5,000+", "Reviews"),
                ],
              ),
            ),

            // About Doctor Section
            _buildSectionHeader("About Doctor"),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Dr. Jenny William is an experienced dentist with over 6 years of practice. She specializes in advanced dental procedures and patient-focused care.",
                style: TextStyle(color: Colors.white70, height: 1.5),
              ),
            ),

            // Doctor Contact
            _buildSectionHeader("Doctor Contact"),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: const CircleAvatar(backgroundColor: Color(0xFF1E293B), child: Icon(Icons.person, color: Colors.white)),
              title: const Text("Dr. Jenny William", style: TextStyle(color: Colors.white)),
              subtitle: const Text("Dentist", style: TextStyle(color: Colors.white38)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIconButton(Icons.chat),
                  const SizedBox(width: 10),
                  _buildIconButton(Icons.phone),
                ],
              ),
            ),
            
            const SizedBox(height: 100), // Space for bottom button
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => const BookingScreen()));
            },
          child: const Text("Book Appointment", style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
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

  void _showBookingSuccess(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      // shape: const RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text("Booking Successful!", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Your appointment with Dr. Jenny has been scheduled.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close sheet
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AppointmentsScreen()));
              },
              child: const Text("View My Appointments"),
            )
          ],
        ),
      ),
    );
  }
}