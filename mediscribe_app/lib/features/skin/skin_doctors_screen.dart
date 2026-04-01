import 'package:flutter/material.dart';
import 'package:mediscribe_app/features/doctors/doctor_detail_screen.dart';

class SkinDoctorsScreen extends StatelessWidget {
  const SkinDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Skin Specialists")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundImage: NetworkImage("https://i.pravatar.cc/151"),
              ),
              title: Text("Dr. Dermatologist ${index + 1}"),
              subtitle: const Text("Dermatologist • ⭐ 4.7"),
              trailing: ElevatedButton(
                child: const Text("Book"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorDetailScreen(
                        doctorName: "Dr. Dermatologist ${index + 1}",
                        specialty: "Dermatologist",
                        imageUrl: "https://i.pravatar.cc/${170 + index}",
                        consultationType: "Clinic Visit",
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
