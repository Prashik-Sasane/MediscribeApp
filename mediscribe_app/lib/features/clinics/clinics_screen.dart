// import 'package:flutter/material.dart';
// import 'package:mediscribe_app/features/doctors/doctor_detail_screen.dart';

// class ClinicsScreen extends StatelessWidget {
//   const ClinicsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Nearby Clinics")),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: 6,
//         itemBuilder: (context, index) {
//           return Card(
//             child: ListTile(
//               leading: const Icon(Icons.local_hospital),
//               title: Text("City Clinic ${index + 1}"),
//               subtitle: const Text("Open • 2 km away"),
//               trailing: ElevatedButton(
//                 child: const Text("Visit"),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => DoctorDetailScreen(
//                         doctorName: "Dr. Clinic ${index + 1}",
//                         specialty: "General Physician",
//                         imageUrl: "https://i.pravatar.cc/${240 + index}",
//                         consultationType: "Clinic Visit",
//                         locationLabel: "2.0 km away",
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
