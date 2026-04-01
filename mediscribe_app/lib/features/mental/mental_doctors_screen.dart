import 'package:flutter/material.dart';
import 'package:mediscribe_app/features/doctors/doctor_detail_screen.dart';

class MentalDoctorsScreen extends StatelessWidget {
  const MentalDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mental Health Specialists")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundImage: NetworkImage("https://i.pravatar.cc/150"),
              ),
              title: Text("Dr. Psychologist ${index + 1}"),
              subtitle: const Text("Psychologist • ⭐ 4.8"),
              trailing: ElevatedButton(
                child: const Text("Book"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorDetailScreen(
                        doctorName: "Dr. Psychologist ${index + 1}",
                        specialty: "Psychologist",
                        imageUrl: "https://i.pravatar.cc/${150 + index}",
                        consultationType: "Video Call",
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
