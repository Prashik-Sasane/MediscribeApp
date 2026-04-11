import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mediscribe_app/core/app_state.dart';
import 'package:mediscribe_app/screens/appointment.dart';
import 'package:mediscribe_app/screens/location_screen.dart';
import 'package:mediscribe_app/features/service/services_screen.dart';
import 'package:mediscribe_app/features/doctors/doctor_detail_screen.dart';
import 'package:mediscribe_app/features/pharmacy/pharmacy_screen.dart';
import 'package:mediscribe_app/features/labtest/lab_test_booking_screen.dart';
import 'package:mediscribe_app/services/location_service.dart';
import 'package:mediscribe_app/services/doctor_api_service.dart';
import 'package:mediscribe_app/services/nearby_places_service.dart';
import 'package:mediscribe_app/services/notification_service.dart';
import 'package:mediscribe_app/services/search_service.dart';
import 'package:mediscribe_app/services/order_service.dart';
import 'package:mediscribe_app/screens/cart_screen.dart';
import 'package:mediscribe_app/widgets/healthcare/search_result_tile.dart';
import 'package:mediscribe_app/widgets/healthcare/order_card.dart';
import 'package:mediscribe_app/widgets/healthcare/order_tracking_sheet.dart';
import 'package:mediscribe_app/screens/rate_appointment_screen.dart';
import 'package:mediscribe_app/services/auth_api_service.dart';
import 'package:mediscribe_app/services/incoming_call_service.dart';
import 'package:mediscribe_app/widgets/healthcare/address_picker_sheet.dart';
import 'dart:async';
import 'package:mediscribe_app/services/product_service.dart';
import 'package:mediscribe_app/widgets/healthcare/product_card.dart';
import 'package:mediscribe_app/models/product.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentAppointmentIndex = 0;
  Timer? _autoScrollTimer;

  // Search state
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _searching = false;
  Timer? _searchDebounce;
  OverlayEntry? _searchOverlayEntry;
  final GlobalKey _searchKey = GlobalKey();
  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;

  // Recent Orders
  List<Map<String, dynamic>> _recentOrders = [];
  bool _ordersLoading = true;

  // Location & Nearby doctors
  bool _locationLoading = true;
  List<NearbyDoctor> _nearbyDoctors = [];
  List<NearbyPlace> _nearbyPlaces = [];
  bool _placesLoading = false;
  String _currentLocation = 'Detecting location...';
  Map<String, dynamic>? _userAddress; // Store user's saved address
  double? _currentLat;
  double? _currentLng;

  // Initialization flags
  bool _hasInitializedDependencies = false;

  // Fallback mock data (shown when not logged in / no appointments loaded)
  final List<Map<String, String>> _mockAppointments = [
    {
      "name": "Dr. Jenny William",
      "specialty": "Dentist",
      "rating": "4.9",
      "date": "Tuesday, 20 January",
      "time": "09:00 - 10:00",
      "imageUrl":
          "https://img.freepik.com/free-photo/friendly-smiling-woman-doctor-nurse-wearing-medical-mask-holding-stethoscope_114579-111162.jpg?t=st=1729446001~exp=1729449601~hmac=9e1261563f45c840f6c53545b746f365551c9d9241b18d451a941a8779b00e31&w=360",
    },
    {
      "name": "Dr. Mark Rayson",
      "specialty": "Cardiologist",
      "rating": "4.8",
      "date": "Thursday, 22 January",
      "time": "14:00 - 15:00",
      "imageUrl":
          "https://img.freepik.com/free-photo/handsome-young-doctor-man-with-stethoscope-grey-wall_23-2148110996.jpg?t=st=1729446059~exp=1729449659~hmac=5c68b3711d9d92e597c45657a8716b66e6b541d40a588b39417c880f019623e6&w=360",
    },
    {
      "name": "Dr. Sarah Kim",
      "specialty": "Neurologist",
      "rating": "4.9",
      "date": "Friday, 23 January",
      "time": "11:30 - 12:30",
      "imageUrl":
          "https://img.freepik.com/free-photo/attractive-female-doctor-presenting_23-2148332159.jpg?w=360",
    },
  ];

  List<Map<String, String>> _buildDisplayAppointments(
      List<Appointment> apiAppts) {
    // Only show real upcoming appointments, no mock data
    if (apiAppts.isEmpty) return [];
    return apiAppts
        .where((a) => a.status == 'upcoming')
        .take(5)
        .map((a) => {
              "name": a.doctorName,
              "specialty": a.specialty,
              "rating": "4.8",
              "date": a.dateLabel,
              "time": a.timeLabel,
              "imageUrl": "https://i.pravatar.cc/150?u=${a.doctorId}",
            })
        .toList()
        .cast<Map<String, String>>();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _startAutoScroll();
    _initLocation();
    
    // Initialize search animation
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _searchAnimation = CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeOutCubic,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppScope.of(context).loadAppointments();
      // Initialize incoming call listener
      IncomingCallService.initialize(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load data that depends on AppScope (token/user state)
    // Only run once to avoid infinite loops
    if (!_hasInitializedDependencies) {
      _hasInitializedDependencies = true;
      _loadUserAddress();
      _loadRecentOrders();
    }
  }

  Future<void> _loadUserAddress() async {
    try {
      final token = AppScope.of(context).token;
      if (token == null) return;

      final addresses = await AuthApiService.getAddresses(token);
      if (mounted && addresses.isNotEmpty) {
        final defaultAddr = addresses.firstWhere(
          (a) => a['isDefault'] == true,
          orElse: () => addresses.first,
        );
        setState(() => _userAddress = Map<String, dynamic>.from(defaultAddr));
      }
    } catch (e) {
      print('Home: Error loading address: $e');
    }
  }

  Future<void> _loadRecentOrders() async {
    final token = AppScope.of(context).token;
    if (token == null) {
      setState(() => _ordersLoading = false);
      return;
    }
    final orders = await OrderService.fetchMyOrders(token);
    if (mounted) {
      setState(() {
        _recentOrders = orders.take(3).toList();
        _ordersLoading = false;
      });
    }
  }

  Future<void> _showAddAddressDialog() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddressPickerSheet(
        onSelected: (addr) async {
          setState(() => _userAddress = addr);

          // Update location display
          final city = addr['city'] ?? addr['state'] ?? 'My Location';
          setState(() => _currentLocation = city);

          Navigator.pop(context);

          // Reload nearby doctors if we have coordinates
          // For now, just show a message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Location set to ${addr['city'] ?? addr['label']}'),
                backgroundColor: const Color(0xFF2E7DFF),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _showLocationOptionsDialog() async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Set Your Location',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose how you want to set your location:',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            // Option 1: Enable GPS
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7DFF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.gps_fixed, color: Color(0xFF2E7DFF)),
              ),
              title: const Text('Use GPS Location',
                  style: TextStyle(color: Colors.white)),
              subtitle: const Text('Automatically detect your current location',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
              onTap: () => Navigator.pop(context, 1),
            ),
            const SizedBox(height: 8),
            // Option 2: Pick from map
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.map, color: Color(0xFF10B981)),
              ),
              title: const Text('Pick on Map',
                  style: TextStyle(color: Colors.white)),
              subtitle: const Text('Select location from interactive map',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
              onTap: () => Navigator.pop(context, 2),
            ),
            const SizedBox(height: 8),
            // Option 3: Manual address
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.location_on, color: Colors.amber),
              ),
              title: const Text('Enter Address Manually',
                  style: TextStyle(color: Colors.white)),
              subtitle: const Text('Type your address details',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
              onTap: () => Navigator.pop(context, 3),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 0),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );

    if (result == null || result == 0) return;

    switch (result) {
      case 1: // GPS Location
        await _enableGPSAndSetLocation();
        break;
      case 2: // Pick from map
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExploreMapScreen()),
          );
        }
        break;
      case 3: // Manual address
        await _showAddAddressDialog();
        break;
    }
  }

  Future<void> _enableGPSAndSetLocation() async {
    if (!mounted) return;

    // Show loading
    setState(() {
      _locationLoading = true;
      _currentLocation = 'Enabling GPS...';
    });

    try {
      // Try to get location
      Position? position = await LocationService.getCurrentLocation();

      if (position == null) {
        // GPS still failed, offer manual option
        if (!mounted) return;

        final retry = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text('GPS Unavailable',
                style: TextStyle(color: Colors.white)),
            content: const Text(
              'Unable to get your GPS location. Please make sure:\n\n'
              '• Location services are enabled\n'
              '• Location permission is granted\n'
              '• You have internet connection\n\n'
              'Would you like to enter your address manually instead?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7DFF),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Enter Manually'),
              ),
            ],
          ),
        );

        if (retry == true && mounted) {
          await _showAddAddressDialog();
        } else if (mounted) {
          setState(() {
            _currentLocation = 'Set your location';
            _locationLoading = false;
          });
        }
        return;
      }

      // Success - got GPS location
      final address = await LocationService.reverseGeocode(
        position.latitude,
        position.longitude,
      );

      String city = 'My Location';
      final addressParts = address.split(',');
      if (addressParts.length >= 3) {
        city = addressParts[addressParts.length - 4]?.trim() ??
            addressParts[addressParts.length - 3]?.trim() ??
            'My Location';
      }

      if (mounted) {
        setState(() {
          _currentLocation = city;
          _locationLoading = false;
        });

        // Load nearby doctors
        _loadNearbyDoctors(position.latitude, position.longitude);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location set to $city'),
            backgroundColor: const Color(0xFF2E7DFF),
          ),
        );
      }
    } catch (e) {
      print('GPS Error: $e');
      if (mounted) {
        setState(() {
          _currentLocation = 'Set your location';
          _locationLoading = false;
        });
      }
    }
  }

  Future<void> _initLocation() async {
    try {
      setState(() {
        _locationLoading = true;
        _currentLocation = 'Detecting location...';
      });

      // Get current GPS position
      Position? position = await LocationService.getCurrentLocation();
      if (position == null) {
        print('Home: GPS location unavailable, using saved address');
        // Fallback to saved address
        if (_userAddress != null) {
          final city =
              _userAddress!['city'] ?? _userAddress!['state'] ?? 'My Location';
          if (mounted) {
            setState(() {
              _currentLocation = city;
              _locationLoading = false;
            });
          }
          return;
        } else {
          if (mounted) {
            setState(() {
              _currentLocation = 'Set your location';
              _locationLoading = false;
            });
          }
          return;
        }
      }

      // Reverse geocode to get city name
      final address = await LocationService.reverseGeocode(
        position.latitude,
        position.longitude,
      );

      // Extract city from address
      String city = 'My Location';
      final addressParts = address.split(',');
      if (addressParts.length >= 3) {
        city = addressParts[addressParts.length - 4]?.trim() ??
            addressParts[addressParts.length - 3]?.trim() ??
            'My Location';
      }

      if (!mounted) return;
      setState(() {
        _currentLocation = city;
        _locationLoading = false;
      });

      // Load nearby doctors based on actual GPS location
      _loadNearbyDoctors(position.latitude, position.longitude);
    } catch (e) {
      print('Location error: $e');
      // Fallback to saved address on error
      if (_userAddress != null) {
        final city =
            _userAddress!['city'] ?? _userAddress!['state'] ?? 'My Location';
        if (mounted) {
          setState(() {
            _currentLocation = city;
            _locationLoading = false;
          });
        }
      } else if (mounted) {
        setState(() {
          _currentLocation = 'Set your location';
          _locationLoading = false;
        });
      }
    }
  }

  Future<void> _loadNearbyDoctors(double lat, double lng) async {
    try {
      print('Home: Loading nearby doctors at lat=$lat, lng=$lng');
      
      // Save coordinates
      _currentLat = lat;
      _currentLng = lng;
      
      // Load doctors from backend
      final doctors =
          await DoctorApiService.getNearbyDoctors(lat: lat, lng: lng);
      print('Home: Found ${doctors.length} nearby doctors');

      // Load places from OpenStreetMap
      _loadNearbyPlaces(lat, lng);

      if (mounted) {
        setState(() {
          _nearbyDoctors = doctors;
          _locationLoading = false;
        });
      }
    } catch (e) {
      print('Home: Error loading nearby doctors: $e');
      if (mounted) {
        setState(() {
          _locationLoading = false;
        });
      }
    }
  }

  Future<void> _loadNearbyPlaces(double lat, double lng) async {
    if (_placesLoading) return;
    
    setState(() => _placesLoading = true);

    try {
      print('Home: Loading nearby places from OpenStreetMap...');
      final places = await NearbyPlacesService.fetchNearbyPlaces(
        lat: lat,
        lng: lng,
      );
      print('Home: Found ${places.length} nearby places');

      if (mounted) {
        setState(() {
          _nearbyPlaces = places;
          _placesLoading = false;
        });
        
        // If API returned 0 places, show fallback sample places
        if (places.isEmpty) {
          print('Home: API returned 0 places, showing sample places');
          _loadSamplePlaces(lat, lng);
        }
      }
    } catch (e) {
      print('Home: Error loading nearby places: $e');
      if (mounted) {
        setState(() => _placesLoading = false);
        // On error, show sample places
        print('Home: Error occurred, showing sample places');
        _loadSamplePlaces(lat, lng);
      }
    }
  }

  // Sample places to show when API fails or returns 0
  void _loadSamplePlaces(double lat, double lng) {
    final samplePlaces = [
      NearbyPlace(
        name: 'City General Hospital',
        type: 'Hospital',
        address: 'Main Road, ${_currentLocation}',
        rating: 4.5,
        position: LatLng(lat + 0.01, lng + 0.01),
        phone: '+91 1234567890',
      ),
      NearbyPlace(
        name: 'Health Care Clinic',
        type: 'Clinic',
        address: 'Station Road, ${_currentLocation}',
        rating: 4.3,
        position: LatLng(lat - 0.01, lng + 0.015),
        phone: '+91 9876543210',
      ),
      NearbyPlace(
        name: 'MedPlus Pharmacy',
        type: 'Medical Store',
        address: 'Market Street, ${_currentLocation}',
        rating: 4.7,
        position: LatLng(lat + 0.015, lng - 0.01),
        phone: '+91 8765432109',
      ),
      NearbyPlace(
        name: 'Apollo Clinic',
        type: 'Clinic',
        address: 'Gandhi Chowk, ${_currentLocation}',
        rating: 4.6,
        position: LatLng(lat - 0.015, lng - 0.015),
        phone: '+91 7654321098',
      ),
      NearbyPlace(
        name: 'Wellness Medical Store',
        type: 'Medical Store',
        address: 'Hospital Road, ${_currentLocation}',
        rating: 4.4,
        position: LatLng(lat + 0.02, lng + 0.005),
        phone: '+91 6543210987',
      ),
      NearbyPlace(
        name: 'Life Care Hospital',
        type: 'Hospital',
        address: 'Civil Lines, ${_currentLocation}',
        rating: 4.8,
        position: LatLng(lat - 0.005, lng + 0.02),
        phone: '+91 5432109876',
      ),
    ];

    if (mounted) {
      setState(() {
        _nearbyPlaces = samplePlaces;
      });
    }
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    if (query.length < 2) {
      _removeSearchOverlay();
      if (!mounted) return;
      setState(() => _searchResults = []);
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      setState(() => _searching = true);
        
      print('Home: Searching for "$query"...');
      final results = await SearchService.globalSearch(query);
      print('Home: Search returned ${results.length} results');
        
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _searching = false;
      });
        
      // Show overlay with animation
      if (_searchResults.isNotEmpty) {
        _showSearchOverlay(query);
      }
    });
  }
  
  void _showSearchOverlay(String query) {
    _removeSearchOverlay();
      
    _searchOverlayEntry = OverlayEntry(
      builder: (context) => _SearchDropdownOverlay(
        searchResults: _searchResults,
        searchQuery: query,
        animation: _searchAnimation,
        onResultTap: (result) {
          handleSearchResultTap(result);
        },
        searchKey: _searchKey,
      ),
    );
      
    Overlay.of(context).insert(_searchOverlayEntry!);
    _searchAnimationController.forward();
  }
  
  void _removeSearchOverlay() {
    if (_searchAnimationController.isAnimating) {
      _searchAnimationController.reverse();
    }
    _searchOverlayEntry?.remove();
    _searchOverlayEntry = null;
  }

  void _showOrderTracking(BuildContext context, Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OrderTrackingSheet(order: order),
    );
  }

  Future<void> handleSearchResultTap(Map<String, dynamic> result) async {
    final type = result['type'];
    final id = result['id'];
    _searchController.clear();

    // Close search overlay
    _removeSearchOverlay();
    
    if (mounted) {
      setState(() => _searchResults = []);
    }

    switch (type) {
      case 'doctor':
        // Show loading or just fetch
        final doctor = await DoctorApiService.getDoctorById(id);
        if (doctor != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => DoctorDetailScreen(doctor: doctor)),
          );
        }
        break;
      case 'medicine':
        // Navigate to pharmacy with search query and address
        final title = result['title'] ?? '';
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UltraHealthShop(
              initialSearchQuery: title,
              initialAddress: _userAddress, // Pass address from home screen
            ),
          ),
        );
        break;
      case 'lab_test':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LabTestBookingScreen(
              labTestId: id,
              initialAddress: _userAddress, // Pass address from home screen
            ),
          ),
        );
        break;
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _searchDebounce?.cancel();
    _searchController.dispose();
    _pageController.dispose();
    _searchAnimationController.dispose();
    _removeSearchOverlay();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final displayAppts = _buildDisplayAppointments(
        AppScope.of(context).appointments,
      );

      if (displayAppts.isEmpty || !_pageController.hasClients) return;

      final total = displayAppts.length;
      _currentAppointmentIndex =
          (_currentAppointmentIndex + 1) % (total > 0 ? total : 1);
      _pageController.animateToPage(
        _currentAppointmentIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastOutSlowIn,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    final displayAppointments =
        _buildDisplayAppointments(appState.appointments);
    final upcomingCount =
        appState.appointments.where((a) => a.status == 'upcoming').length;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(170),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          color: const Color(0xFF2E7DFF),
          child: SafeArea(
            child: _ModernHeader(
              city: _currentLocation,
              upcomingCount: upcomingCount,
              searchController: _searchController,
              searching: _searching,
              onSearchChanged: _onSearchChanged,
              onLocationTap: () {
                // Show location options dialog
                _showLocationOptionsDialog();
              },
              searchKey: _searchKey,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          GestureDetector(
            behavior:
                HitTestBehavior.translucent, // ✅ important for full tap detection
            onTap: () {
              FocusScope.of(context).unfocus(); // hide keyboard
              _removeSearchOverlay();
              setState(() {
                _searchResults = []; // close dropdown
              });
            },
            child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Only show slider if there are upcoming appointments
              if (displayAppointments.isNotEmpty) ...[
                _UpcomingAppointmentsSlider(
                  controller: _pageController,
                  currentIndex: _currentAppointmentIndex,
                  appointments: displayAppointments,
                ),
                const SizedBox(height: 28),
                _buildDotIndicator(displayAppointments),
                const SizedBox(height: 28),
              ],

              const _ServiceSection(),
              const SizedBox(height: 32),

              if (_recentOrders.isNotEmpty) ...[
                _RecentOrdersSection(
                  orders: _recentOrders,
                  onOrderTap: (order) {
                    _showOrderTracking(context, order);
                  },
                ),
                const SizedBox(height: 32),
              ],

              const _RecommendedMedicinesSection(),
              const SizedBox(height: 32),

              // Show nearby places (hospitals, clinics, medical stores)
              if (_nearbyPlaces.isNotEmpty || _placesLoading) ...[
                _NearbyPlacesSection(
                  places: _nearbyPlaces,
                  loading: _placesLoading,
                  lat: _currentLat ?? 18.5204,
                  lng: _currentLng ?? 73.8567,
                ),
                const SizedBox(height: 32),
              ],

              _NearbyDoctorsSection(
                doctors: _nearbyDoctors,
                loading: _locationLoading,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(List<Map<String, String>> appointments) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        appointments.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentAppointmentIndex == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentAppointmentIndex == index
                ? const Color.fromARGB(255, 223, 198, 3)
                : Colors.white38,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

// Search Dropdown Overlay with Animation and Blur
class _SearchDropdownOverlay extends StatelessWidget {
  final List<Map<String, dynamic>> searchResults;
  final String searchQuery;
  final Animation<double> animation;
  final Function(Map<String, dynamic>) onResultTap;
  final GlobalKey searchKey;

  const _SearchDropdownOverlay({
    required this.searchResults,
    required this.searchQuery,
    required this.animation,
    required this.onResultTap,
    required this.searchKey,
  });

  @override
  Widget build(BuildContext context) {
    // Get the position of the search bar
    final renderBox = searchKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return const SizedBox.shrink();

    final offset = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final dropdownTop = offset.dy + renderBox.size.height + 8; // 8px gap
    final dropdownHeight = (screenHeight * 0.4).clamp(200.0, 350.0);

    return Positioned(
      top: dropdownTop,
      left: 10,
      right: 10,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -20 * (1 - animation.value)),
            child: Opacity(
              opacity: animation.value,
              child: child,
            ),
          );
        },
        child: GestureDetector(
          onTap: () {}, // Prevent taps from going through
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  constraints: BoxConstraints(maxHeight: dropdownHeight),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF2E7DFF).withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final result = searchResults[index];
                      return SearchResultTile(
                        result: result,
                        searchQuery: searchQuery,
                        onTap: () => onResultTap(result),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernHeader extends StatefulWidget {
  final String city;
  final int upcomingCount;
  final TextEditingController searchController;
  final bool searching;
  final Function(String) onSearchChanged;
  final VoidCallback? onLocationTap;
  final GlobalKey searchKey;

  const _ModernHeader({
    required this.city,
    required this.upcomingCount,
    required this.searchController,
    required this.searching,
    required this.onSearchChanged,
    this.onLocationTap,
    required this.searchKey,
  });

  @override
  State<_ModernHeader> createState() => _ModernHeaderState();
}

class _ModernHeaderState extends State<_ModernHeader> {
  @override
  void initState() {
    super.initState();
    // Listen for notification changes
    NotificationService.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = NotificationService.getUnreadCount();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Location",
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
                GestureDetector(
                  onTap: widget.onLocationTap ??
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ExploreMapScreen()),
                        );
                      },
                  child: Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.orangeAccent, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        widget.city,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.white70, size: 18),
                    ],
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => _showNotifications(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  children: [
                    const Icon(Icons.notifications_none_rounded,
                        color: Colors.white, size: 24),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                              color: Colors.redAccent, shape: BoxShape.circle),
                          constraints:
                              const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            unreadCount > 9 ? '9+' : '$unreadCount',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        // Search bar only (no dropdown)
        _SearchBarOnly(
          searchController: widget.searchController,
          searching: widget.searching,
          onSearchChanged: widget.onSearchChanged,
          searchKey: widget.searchKey,
        ),
      ],
    );
  }

  void _showNotifications(BuildContext context) {
    final notifications = NotificationService.getNotifications();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      if (notifications.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            NotificationService.markAllAsRead();
                            setState(() {});
                          },
                          child: const Text(
                            'Mark all read',
                            style: TextStyle(color: Color(0xFF2E7DFF)),
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24),

            // Notifications list
            if (notifications.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.notifications_none,
                        size: 60, color: Colors.white38),
                    SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: TextStyle(color: Colors.white38, fontSize: 16),
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: notification.type ==
                                NotificationType.success
                            ? Colors.green.withOpacity(0.2)
                            : notification.type == NotificationType.warning
                                ? Colors.orange.withOpacity(0.2)
                                : notification.type == NotificationType.error
                                    ? Colors.red.withOpacity(0.2)
                                    : const Color(0xFF2E7DFF).withOpacity(0.2),
                        child: Text(
                          notification.getIcon(),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      title: Text(
                        notification.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: notification.isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            notification.message,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.getTimeAgo(),
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 11),
                          ),
                        ],
                      ),
                      trailing: !notification.isRead
                          ? Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2E7DFF),
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                      onTap: () {
                        NotificationService.markAsRead(index);
                        setState(() {});

                        // Handle notification actions
                        if (notification.data != null) {
                          final action = notification.data!['action'];
                          if (action == 'rate_doctor') {
                            Navigator.pop(context); // Close notification sheet
                            _navigateToRateAppointment(
                              context,
                              notification.data!['appointmentId'],
                              notification.data!['doctorName'],
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ),

            // Clear all button
            if (notifications.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton(
                  onPressed: () {
                    NotificationService.clearAll();
                    setState(() {});
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: const Text(
                    'Clear All Notifications',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToRateAppointment(
      BuildContext context, String appointmentId, String doctorName) {
    // Get auth token
    final appState = AppScope.of(context);
    final token = appState.token;

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to rate doctor'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Navigate to rating screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RateAppointmentScreen(
          appointmentId: appointmentId,
          doctorName: doctorName,
          token: token,
        ),
      ),
    );
  }
}

class _SearchBarOnly extends StatelessWidget {
  final TextEditingController searchController;
  final bool searching;
  final Function(String) onSearchChanged;
  final GlobalKey searchKey;

  const _SearchBarOnly({
    required this.searchController,
    required this.searching,
    required this.onSearchChanged,
    required this.searchKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: searchKey,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search doctors, clinics, locations...",
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          suffixIcon: searching
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white54)),
                )
              : const Icon(Icons.tune_rounded, color: Colors.white54),
        ),
        onChanged: onSearchChanged,
      ),
    );
  }
}

class _UpcomingAppointmentsSlider extends StatelessWidget {
  final PageController controller;
  final int currentIndex;
  final List<Map<String, String>> appointments;

  const _UpcomingAppointmentsSlider({
    required this.controller,
    required this.currentIndex,
    required this.appointments,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text("Upcoming Appointments",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                        color: Color(0xFF4D91FF), shape: BoxShape.circle),
                    child: Text("${appointments.length}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11)),
                  )
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AppointmentsScreen(),
                    ),
                  );
                },
                child: const Text("See All",
                    style: TextStyle(color: Color(0xFF4D91FF))),
              )
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: controller,
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                appointment['imageUrl']!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                    color: Colors.white12,
                                    child: const Icon(Icons.person)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(appointment['name']!,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                  Text(appointment['specialty']!,
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 14)),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded,
                                          color: Colors.amber, size: 18),
                                      const SizedBox(width: 4),
                                      Text(appointment['rating']!,
                                          style: const TextStyle(
                                              color: Colors.white70)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 55,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7DFF),
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(24)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              color: Colors.white.withOpacity(0.9), size: 18),
                          const SizedBox(width: 10),
                          Text(appointment['date']!,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13)),
                          const Spacer(),
                          Text("|",
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.4))),
                          const Spacer(),
                          Icon(Icons.schedule_outlined,
                              color: Colors.white.withOpacity(0.9), size: 18),
                          const SizedBox(width: 10),
                          Text(appointment['time']!,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HealthStatsSection extends StatelessWidget {
  const _HealthStatsSection();

  @override
  Widget build(BuildContext context) {
    // This isn't in the provided visual, but I'm retaining it as you
    // requested "add in this code". It adds depth to the healthcare app.
    final stats = [
      {
        'label': 'Heart Rate',
        'val': '82 bpm',
        'icon': Icons.favorite,
        'color': Colors.redAccent
      },
      {
        'label': 'Blood Group',
        'val': 'O+ Positive',
        'icon': Icons.water_drop,
        'color': Colors.blueAccent
      },
    ];

    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: stat == stats.first ? 12 : 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (stat['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: (stat['color'] as Color).withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(stat['icon'] as IconData, color: stat['color'] as Color),
                const SizedBox(height: 12),
                Text(stat['val'] as String,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Text(stat['label'] as String,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ServiceSection extends StatelessWidget {
  const _ServiceSection();

  @override
  Widget build(BuildContext context) {
    // Icons chosen to be the "best" relevant visual descriptors
    final services = [
      {
        "name": "Teleconsultation",
        "icon": Icons.favorite_rounded
      }, // Perfect for dental visual
      {"name": "Home Lab", "icon": Icons.favorite_rounded},
      {
        "name": "Health Shop",
        "icon": Icons.psychology_rounded
      }, // Better brain icon
      {"name": "Medication", "icon": Icons.medication_liquid_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Services",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ServicesScreen(),
                    ),
                  );
                },
                child: const Text(
                  "See All",
                  style: TextStyle(color: Color(0xFF4D91FF)),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 60,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            scrollDirection: Axis.horizontal,
            itemCount: services.length,
            itemBuilder: (context, index) {
              final isFirst = index == 0;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  // First chip is highlighted blue, others are dark slate grey
                  color: isFirst
                      ? const Color(0xFF2E7DFF)
                      : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(30), // Oval/Chip shape
                ),
                child: Row(
                  children: [
                    Icon(services[index]['icon'] as IconData,
                        color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      services[index]['name'] as String,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecommendedMedicinesSection extends StatefulWidget {
  const _RecommendedMedicinesSection();

  @override
  State<_RecommendedMedicinesSection> createState() =>
      _RecommendedMedicinesSectionState();
}

class _RecommendedMedicinesSectionState
    extends State<_RecommendedMedicinesSection> {
  List<Product> _recommendations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    try {
      print('Home: Fetching recommendations...');
      final products = await ProductService.fetchProducts(query: 'popular');
      print('Home: Fetched ${products.length} products');

      if (mounted) {
        setState(() {
          _recommendations = products.take(6).toList();
          _loading = false;
        });
      }
    } catch (e) {
      print('Home: Error fetching recommendations: $e');
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _recommendations.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Recommended for You",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(
            height: 220,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7DFF)),
            ),
          ),
        ],
      );
    }

    if (_recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Recommended for You",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: _recommendations.length,
            itemBuilder: (context, index) {
              final product = _recommendations[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 16),
                child: ProductCard(
                  product: product,
                  onAddToCart: () {
                    // Logic to add to cart
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecentOrdersSection extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  final Function(Map<String, dynamic>) onOrderTap;

  const _RecentOrdersSection({
    required this.orders,
    required this.onOrderTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Your Recent Orders",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MyOrdersScreen())),
                child: const Text("View All",
                    style: TextStyle(color: Color(0xFF2E7DFF))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                child: OrderCard(
                  order: order,
                  onTap: () => onOrderTap(order),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SearchBarWithDropdown extends StatelessWidget {
  final TextEditingController searchController;
  final List<Map<String, dynamic>> searchResults;
  final bool searching;
  final Function(String) onSearchChanged;
  final Function(Map<String, dynamic>) onResultTap;

  const _SearchBarWithDropdown({
    required this.searchController,
    required this.searchResults,
    required this.searching,
    required this.onSearchChanged,
    required this.onResultTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 55,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            controller: searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Search doctors, clinics, locations...",
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
              prefixIcon:
                  const Icon(Icons.search_rounded, color: Colors.white54),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
              suffixIcon: searching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white54)),
                    )
                  : const Icon(Icons.tune_rounded, color: Colors.white54),
            ),
            onChanged: onSearchChanged,
          ),
        ),
        if (searchResults.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final result = searchResults[index];
                return SearchResultTile(
                  result: result,
                  onTap: () => onResultTap(result),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _NearbyDoctorsSection extends StatelessWidget {
  final List<NearbyDoctor> doctors;
  final bool loading;

  const _NearbyDoctorsSection({required this.doctors, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Nearby Doctors",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ExploreMapScreen()),
                  );
                },
                child: const Text("See All",
                    style: TextStyle(color: Color(0xFF4D91FF))),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        loading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: CircularProgressIndicator(color: Color(0xFF2E7DFF)),
                ),
              )
            : doctors.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text("No doctors found nearby.",
                          style: TextStyle(color: Colors.white38)),
                    ),
                  )
                : SizedBox(
                    height: 240,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      scrollDirection: Axis.horizontal,
                      itemCount: doctors.length,
                      itemBuilder: (context, index) {
                        final doctor = doctors[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DoctorDetailScreen(doctor: doctor),
                              ),
                            );
                          },
                          child: Container(
                            width: 280,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  Image.network(
                                    doctor.imageUrl,
                                    height: double.infinity,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(
                                      color: Colors.white12,
                                      child: const Icon(Icons.person, size: 80),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.8),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          doctor.name,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.star_rounded,
                                                color: Colors.amber, size: 18),
                                            const SizedBox(width: 4),
                                            Text("${doctor.rating}",
                                                style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14)),
                                            const Spacer(),
                                            Icon(Icons.location_on_outlined,
                                                color: Colors.white
                                                    .withOpacity(0.8),
                                                size: 18),
                                            const SizedBox(width: 4),
                                            Text(
                                                "${doctor.distanceKm.toStringAsFixed(1)} km",
                                                style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 20,
                                    right: 20,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                          color: Colors.white12,
                                          shape: BoxShape.circle),
                                      child: const Icon(Icons.favorite_rounded,
                                          color: Colors.redAccent, size: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ],
    );
  }
}

class _NearbyPlacesSection extends StatelessWidget {
  final List<NearbyPlace> places;
  final bool loading;
  final double lat;
  final double lng;

  const _NearbyPlacesSection({
    required this.places,
    required this.loading,
    required this.lat,
    required this.lng,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Nearby Hospitals & Clinics",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ExploreMapScreen()),
                  );
                },
                child: const Text("See All",
                    style: TextStyle(color: Color(0xFF4D91FF))),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        loading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: CircularProgressIndicator(color: Color(0xFF2E7DFF)),
                ),
              )
            : places.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text("No hospitals or clinics found nearby.",
                          style: TextStyle(color: Colors.white38)),
                    ),
                  )
                : SizedBox(
                    height: 160,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      scrollDirection: Axis.horizontal,
                      itemCount: places.length,
                      itemBuilder: (context, index) {
                        final place = places[index];
                        IconData icon;
                        Color color;
                        
                        switch (place.type) {
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ExploreMapScreen()),
                            );
                          },
                          child: Container(
                            width: 260,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: color.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 45,
                                        height: 45,
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(icon, color: color, size: 24),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              place.name,
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
                                                const Icon(Icons.star,
                                                    color: Colors.amber,
                                                    size: 14),
                                                const SizedBox(width: 4),
                                                Text(
                                                  place.rating.toStringAsFixed(1),
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on_outlined,
                                          color: Colors.white.withOpacity(0.6),
                                          size: 14),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          place.address,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.6),
                                            fontSize: 11,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ],
    );
  }
}
