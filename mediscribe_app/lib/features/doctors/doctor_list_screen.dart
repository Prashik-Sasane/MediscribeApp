import 'package:flutter/material.dart';
import 'doctor_detail_screen.dart';

class DoctorListScreen extends StatelessWidget {
  const DoctorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> doctors = [
      {
        "name": "Dr. Rahul Sharma",
        "speciality": "Cardiologist",
        "image": "https://i.pravatar.cc/201"
      },
      {
        "name": "Dr. Priya Mehta",
        "speciality": "Dermatologist",
        "image": "https://i.pravatar.cc/202"
      },
      {
        "name": "Dr. Aman Verma",
        "speciality": "Neurologist",
        "image": "https://i.pravatar.cc/203"
      },
      {
        "name": "Dr. Sneha Patil",
        "speciality": "Psychologist",
        "image": "https://i.pravatar.cc/204"
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Doctors"),
        backgroundColor: const Color(0xFF1E293B),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          final doctor = doctors[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(doctor["image"]!),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor["name"]!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        doctor["speciality"]!,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      const Row(
                        children: [
                          Icon(Icons.star, color: Colors.orange, size: 16),
                          Text(" 4.8",
                              style: TextStyle(color: Colors.white)),
                        ],
                      )
                    ],
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DoctorDetailScreen(
                          doctorName: doctor["name"]!,
                          specialty: doctor["speciality"]!,
                          imageUrl: doctor["image"]!,
                          consultationType: 'Online',
                        ),
                      ),
                    );
                  },
                  child: const Text("View"),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}