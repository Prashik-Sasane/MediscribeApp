import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/location_service.dart';

class ExploreMapScreen extends StatefulWidget {
  const ExploreMapScreen({super.key});

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen> {
  final MapController _mapController = MapController();
  LatLng _currentPosition = const LatLng(18.5204, 73.8567); // Default: Pune
  bool _locationLoading = true;
  String _selectedFilter = "All";
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  // Search suggestions
  List<Map<String, dynamic>> _searchSuggestions = [];
  bool _searching = false;
  
  // Map markers
  List<Map<String, dynamic>> _nearbyPlaces = [];
  bool _placesLoading = false;
  bool _hasLoadedPlaces = false; // Prevent reload
  
  // Selected place on map
  Map<String, dynamic>? _selectedPlace;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null && mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _locationLoading = false;
        });
        _mapController.move(_currentPosition, 14.5);
        _loadNearbyPlaces(position.latitude, position.longitude);
      } else if (mounted) {
        setState(() => _locationLoading = false);
        _loadNearbyPlaces(18.5204, 73.8567); // Fallback to Pune
      }
    } catch (e) {
      print('Map: Error getting location: $e');
      if (mounted) {
        setState(() => _locationLoading = false);
        _loadNearbyPlaces(18.5204, 73.8567); // Fallback to Pune
      }
    }
  }

  // Search for city/location using Nominatim
  Future<void> _searchLocation(String query) async {
    if (query.length < 2) {
      setState(() => _searchSuggestions = []);
      return;
    }

    setState(() => _searching = true);

    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5&countrycodes=in',
        ).replace(queryParameters: {
          'q': query,
          'format': 'json',
          'limit': '5',
          'countrycodes': 'in',
        }),
        headers: {'User-Agent': 'MediscribeApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          _searchSuggestions = data.map((item) => {
            'display_name': item['display_name'],
            'lat': double.parse(item['lat']),
            'lon': double.parse(item['lon']),
          }).toList();
          _searching = false;
        });
      }
    } catch (e) {
      print('Search error: $e');
      if (mounted) setState(() => _searching = false);
    }
  }

  // Navigate to searched location
  void _navigateToLocation(Map<String, dynamic> location) {
    final lat = location['lat'] as double;
    final lon = location['lon'] as double;
    
    setState(() {
      _currentPosition = LatLng(lat, lon);
      _searchSuggestions = [];
      _searchController.clear();
      _searchFocusNode.unfocus();
      _hasLoadedPlaces = false; // Reset to allow reload for new location
    });
    
    _mapController.move(_currentPosition, 14.5);
    _loadNearbyPlaces(lat, lon);
  }

  // Load nearby places from Overpass API
  Future<void> _loadNearbyPlaces(double lat, double lon) async {
    if (_placesLoading || _hasLoadedPlaces) return; // Prevent duplicate loading
    
    setState(() => _placesLoading = true);

    try {
      final query = '''
        [out:json][timeout:25];
        (
          node["amenity"="hospital"](around:5000,$lat,$lon);
          node["amenity"="clinic"](around:5000,$lat,$lon);
          node["amenity"="pharmacy"](around:5000,$lat,$lon);
          node["amenity"="doctors"](around:5000,$lat,$lon);
        );
        out center;
      ''';

      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        body: {'data': query},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List;

        final places = elements.map((e) {
          final tags = e['tags'] as Map? ?? {};
          final placeLat = (e['lat'] ?? e['center']?['lat'])?.toDouble() ?? lat;
          final placeLon = (e['lon'] ?? e['center']?['lon'])?.toDouble() ?? lon;
          
          String type = 'Other';
          final amenity = tags['amenity']?.toString().toLowerCase() ?? '';
          
          if (amenity == 'hospital') type = 'Hospital';
          else if (amenity == 'clinic') type = 'Clinic';
          else if (amenity == 'pharmacy') type = 'Medical Store';
          else if (amenity == 'doctors') type = 'Doctor';

          return {
            'name': tags['name'] ?? '$type Nearby',
            'type': type,
            'amenity': amenity,
            'position': LatLng(placeLat, placeLon),
            'address': tags['addr:street'] ?? tags['address'] ?? 'Address not available',
            'phone': tags['phone'] ?? tags['contact:phone'] ?? '',
            'rating': 4.0 + (placeLat % 1), // Mock rating based on position
          };
        }).toList();

        if (mounted) {
          setState(() {
            _nearbyPlaces = places.where((p) => 
              _selectedFilter == 'All' || p['type'] == _selectedFilter
            ).toList();
            _placesLoading = false;
            _hasLoadedPlaces = true; // Mark as loaded
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _placesLoading = false;
            _hasLoadedPlaces = true;
          });
        }
      }
    } catch (e) {
      print('Error loading places: $e');
      if (mounted) {
        setState(() {
          _placesLoading = false;
          _hasLoadedPlaces = true;
        });
      }
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng latlng) {
    setState(() {
      _selectedPlace = null;
    });
  }

  void _onPlaceTap(Map<String, dynamic> place) {
    final pos = place['position'] as LatLng;
    setState(() {
      _selectedPlace = place;
    });
    _mapController.move(pos, 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          /// 🗺️ MAP LAYER - Fully Interactive OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 14.5,
              onTap: _onMapTap,
              interactiveFlags: InteractiveFlag.all, // Enable all interactions
            ),
            children: [
              // OpenStreetMap tiles
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.mediscribe_app',
                maxZoom: 19,
                tileProvider: NetworkTileProvider(),
              ),
              // Markers
              MarkerLayer(
                markers: [
                  // Current location marker (blue dot)
                  Marker(
                    point: _currentPosition,
                    width: 50,
                    height: 50,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7DFF).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7DFF),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Nearby places markers with proper icons
                  ..._nearbyPlaces.map((place) {
                    IconData icon;
                    Color color;
                    
                    switch (place['type']) {
                      case 'Hospital':
                        icon = Icons.local_hospital;
                        color = Colors.red;
                        break;
                      case 'Clinic':
                        icon = Icons.medical_services;
                        color = const Color(0xFF2E7DFF);
                        break;
                      case 'Medical Store':
                        icon = Icons.local_pharmacy;
                        color = Colors.green;
                        break;
                      case 'Doctor':
                        icon = Icons.person;
                        color = Colors.purple;
                        break;
                      default:
                        icon = Icons.location_on;
                        color = const Color(0xFF2E7DFF);
                    }

                    return Marker(
                      point: place['position'] as LatLng,
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => _onPlaceTap(place),
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(icon, color: Colors.white, size: 22),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
              // Loading overlay
              if (_placesLoading)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF2E7DFF),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Loading places...',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
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
            bottom: _selectedPlace != null ? 260 : 230,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'map_my_location',
                  mini: true,
                  backgroundColor: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.my_location, color: Color(0xFF2E7DFF)),
                  onPressed: () {
                    _getCurrentLocation();
                  },
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'map_zoom_in',
                  mini: true,
                  backgroundColor: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.zoom_in, color: Color(0xFF2E7DFF)),
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1,
                    );
                  },
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'map_zoom_out',
                  mini: true,
                  backgroundColor: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.zoom_out, color: Color(0xFF2E7DFF)),
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1,
                    );
                  },
                ),
              ],
            ),
          ),

          /// 📌 SELECTED PLACE INFO
          if (_selectedPlace != null)
            Positioned(
              bottom: 220,
              left: 20,
              right: 80,
              child: _buildSelectedPlaceCard(),
            ),
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
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      icon: const Icon(Icons.search, color: Colors.white54, size: 20),
                      hintText: "Search city, hospital, clinic...",
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                      border: InputBorder.none,
                      suffixIcon: _searching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF2E7DFF),
                                ),
                              ),
                            )
                          : const Icon(Icons.tune_rounded, color: Color(0xFF2E7DFF), size: 20),
                    ),
                    onChanged: _searchLocation,
                  ),
                ),
              ),
            ),
            // Search suggestions
            if (_searchSuggestions.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                constraints: const BoxConstraints(maxHeight: 250),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: _searchSuggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _searchSuggestions[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on, color: Color(0xFF2E7DFF), size: 20),
                      title: Text(
                        suggestion['display_name'].split(',')[0],
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        suggestion['display_name'].split(',').skip(1).take(2).join(','),
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _navigateToLocation(suggestion),
                    );
                  },
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
    final filters = ["All", "Hospital", "Clinic", "Medical Store", "Doctor"];
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, i) {
          bool isSelected = _selectedFilter == filters[i];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filters[i];
                _hasLoadedPlaces = false; // Reset to reload with filter
              });
              // Reload places with new filter
              _loadNearbyPlaces(_currentPosition.latitude, _currentPosition.longitude);
            },
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
    if (_placesLoading && _nearbyPlaces.isEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF2E7DFF)),
              const SizedBox(height: 12),
              Text(
                'Loading nearby places...',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    if (_nearbyPlaces.isEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_off, color: Colors.white38, size: 40),
              const SizedBox(height: 8),
              Text(
                'No places found nearby',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _nearbyPlaces.length,
        itemBuilder: (context, index) {
          final place = _nearbyPlaces[index];
          IconData icon;
          Color color;
          
          switch (place['type']) {
            case 'Hospital':
              icon = Icons.local_hospital;
              color = Colors.red;
              break;
            case 'Clinic':
              icon = Icons.medical_services;
              color = const Color(0xFF2E7DFF);
              break;
            case 'Medical Store':
              icon = Icons.local_pharmacy;
              color = Colors.green;
              break;
            case 'Doctor':
              icon = Icons.person;
              color = Colors.purple;
              break;
            default:
              icon = Icons.location_on;
              color = const Color(0xFF2E7DFF);
          }

          return GestureDetector(
            onTap: () => _onPlaceTap(place),
            child: Container(
              width: 280,
              margin: const EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _selectedPlace == place
                      ? const Color(0xFF2E7DFF)
                      : Colors.white.withOpacity(0.05),
                  width: _selectedPlace == place ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Header
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.3),
                          color.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(icon, color: color, size: 50),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              place['type'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Text Content
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              place['rating'].toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          place['address'],
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedPlaceCard() {
    if (_selectedPlace == null) return const SizedBox.shrink();

    IconData icon;
    Color color;
    
    switch (_selectedPlace!['type']) {
      case 'Hospital':
        icon = Icons.local_hospital;
        color = Colors.red;
        break;
      case 'Clinic':
        icon = Icons.medical_services;
        color = const Color(0xFF2E7DFF);
        break;
      case 'Medical Store':
        icon = Icons.local_pharmacy;
        color = Colors.green;
        break;
      case 'Doctor':
        icon = Icons.person;
        color = Colors.purple;
        break;
      default:
        icon = Icons.location_on;
        color = const Color(0xFF2E7DFF);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.5), width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedPlace!['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          _selectedPlace!['rating'].toStringAsFixed(1),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Open navigation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Navigating to ${_selectedPlace!["name"]}'),
                      backgroundColor: const Color(0xFF2E7DFF),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7DFF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.directions, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}