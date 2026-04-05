import 'dart:io' show Platform;
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ExploreMapScreen extends StatefulWidget {
  const ExploreMapScreen({super.key});

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen> {
  GoogleMapController? mapController;

  static const LatLng _center = LatLng(40.7128, -74.0060);
  String _selectedFilter = "All";

  // Mock data based on your "Nearby Hospitals" screenshot
  final List<Map<String, dynamic>> _nearbyLocations = [
    {
      "name": "City Care Medical",
      "specialty": "Ophthalmologist, Otology",
      "rating": 4.8,
      "address": "Royal Ln. Mesa, New Jersey",
      "distance": "1.5 Miles",
      "type": "Clinic",
      "position": const LatLng(40.7150, -74.0090),
      "image": "https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=400"
    },
    {
      "name": "Cure-All Pharmacy",
      "specialty": "General Pharmacy",
      "rating": 4.5,
      "address": "Broadway St, New York",
      "distance": "0.8 Miles",
      "type": "Medical Store",
      "position": const LatLng(40.7100, -74.0020),
      "image": "https://images.unsplash.com/photo-1586015555751-63bb77f4322a?w=400"
    }
  ];

  List<Map<String, dynamic>> get _filteredLocations {
    if (_selectedFilter == "All") return _nearbyLocations;
    return _nearbyLocations.where((loc) => loc['type'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Check if platform is supported (Avoids Windows Error)
    bool isSupported = kIsWeb || Platform.isAndroid || Platform.isIOS;

    if (!isSupported) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: Text(
            "Google Maps is not supported on Windows.\nPlease run on Android, iOS, or Web.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          /// 🗺️ MAP LAYER
          GoogleMap(
            onMapCreated: (controller) {
              mapController = controller;
              _setMapStyle(controller);
            },
            initialCameraPosition: const CameraPosition(target: _center, zoom: 14.5),
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            markers: _buildMarkers(),
          ),

          /// 🔍 TOP UI (Search + Filter Chips)
          _buildTopSection(),

          /// 💳 BOTTOM UI (Horizontal Hospital Cards)
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: _buildHospitalCards(),
          ),

          /// 📍 ACTION BUTTONS
          Positioned(
            bottom: 230,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.my_location, color: Color(0xFF2E7DFF)),
              onPressed: () => mapController?.animateCamera(CameraUpdate.newLatLng(_center)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTopSection() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // Search Bar with Glassmorphism
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withOpacity(0.9),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      icon: Icon(Icons.search, color: Colors.white54, size: 20),
                      hintText: "Search Doctor or Hospital",
                      hintStyle: TextStyle(color: Colors.white30, fontSize: 14),
                      border: InputBorder.none,
                      suffixIcon: Icon(Icons.tune_rounded, color: Color(0xFF2E7DFF), size: 20),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Filter Chips
            _buildFilterRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    final filters = ["All", "Hospital", "Clinic", "Medical Store"];
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, i) {
          bool isSelected = _selectedFilter == filters[i];
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filters[i]),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2E7DFF) : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  filters[i],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHospitalCards() {
    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filteredLocations.length,
        itemBuilder: (context, index) {
          final loc = _filteredLocations[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Header with Heart Icon
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.network(loc['image'], height: 100, width: double.infinity, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.favorite, color: Colors.red.shade400, size: 16),
                      ),
                    ),
                  ],
                ),
                // Text Content
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loc['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(loc['specialty'], style: const TextStyle(color: Colors.white38, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text("${loc['address']} • ${loc['distance']}", style: const TextStyle(color: Colors.white38, fontSize: 10)),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 14),
                              Text(" ${loc['rating']}", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Blue Navigation Circle
                          const CircleAvatar(
                            radius: 14,
                            backgroundColor: Color(0xFF2E7DFF),
                            child: Icon(Icons.near_me, color: Colors.white, size: 14),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    return _filteredLocations.map((loc) {
      return Marker(
        markerId: MarkerId(loc['name']),
        position: loc['position'] as LatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          loc['type'] == "Medical Store" ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueAzure
        ),
      );
    }).toSet();
  }

  Future<void> _setMapStyle(GoogleMapController controller) async {
    const style = '''[
      {"elementType": "geometry", "stylers": [{"color": "#0f172a"}]},
      {"elementType": "labels.text.fill", "stylers": [{"color": "#94a3b8"}]},
      {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#020617"}]}
    ]''';
    await controller.setMapStyle(style);
  }
}