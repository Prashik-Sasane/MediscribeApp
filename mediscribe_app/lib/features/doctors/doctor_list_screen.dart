import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mediscribe_app/services/doctor_api_service.dart';
import 'doctor_detail_screen.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  bool _loading = true;
  String? _error;
  List<NearbyDoctor> _doctors = [];

  @override
  void initState() {
    super.initState();
    _loadNearbyDoctors();
  }

  Future<void> _loadNearbyDoctors() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final hasService = await Geolocator.isLocationServiceEnabled();
      if (!hasService) {
        setState(() {
          _loading = false;
          _error = 'Location is turned off. Please enable GPS.';
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _loading = false;
          _error = 'Location permission denied.';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final doctors = await DoctorApiService.getNearbyDoctors(
        lat: position.latitude,
        lng: position.longitude,
      );
      setState(() {
        _loading = false;
        _doctors = doctors;
        if (doctors.isEmpty) {
          _error = 'No nearby doctors found or backend is unreachable.';
        }
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'Could not load nearby doctors.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Nearby Doctors"),
        backgroundColor: const Color(0xFF1E293B),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadNearbyDoctors,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _doctors.length,
        itemBuilder: (context, index) {
          final doctor = _doctors[index];

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
                  backgroundImage: NetworkImage(doctor.imageUrl),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${doctor.specialty} • ${doctor.distanceKm.toStringAsFixed(1)} km',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 16),
                          Text(" ${doctor.rating.toStringAsFixed(1)}",
                              style: const TextStyle(color: Colors.white)),
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
                          doctorName: doctor.name,
                          specialty: doctor.specialty,
                          imageUrl: doctor.imageUrl,
                          consultationType: 'Online',
                          feeLabel: '₹${doctor.fee}',
                          locationLabel: '${doctor.distanceKm.toStringAsFixed(1)} km away',
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