import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mediscribe_app/core/app_state.dart';
import 'package:mediscribe_app/screens/appointment.dart';
import 'package:mediscribe_app/screens/location_screen.dart';
import 'package:mediscribe_app/features/service/services_screen.dart';
import 'package:mediscribe_app/features/doctors/doctor_detail_screen.dart';
import 'package:mediscribe_app/services/location_service.dart';
import 'package:mediscribe_app/services/doctor_api_service.dart';
import 'package:mediscribe_app/services/notification_service.dart';
import 'package:mediscribe_app/screens/rate_appointment_screen.dart';
import 'package:mediscribe_app/services/auth_api_service.dart';
import 'package:mediscribe_app/services/incoming_call_service.dart';
import 'dart:async';

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

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  int _currentAppointmentIndex = 0;
  Timer? _autoScrollTimer;

  // Search state
  final TextEditingController _searchController = TextEditingController();
  List<PlaceResult> _searchResults = [];
  bool _searching = false;
  Timer? _searchDebounce;

  // Location & Nearby doctors
  bool _locationLoading = true;
  List<NearbyDoctor> _nearbyDoctors = [];
  String _currentLocation = 'Detecting location...';

  // Fallback mock data (shown when not logged in / no appointments loaded)
  final List<Map<String, String>> _mockAppointments = [
    {
      "name": "Dr. Jenny William",
      "specialty": "Dentist",
      "rating": "4.9",
      "date": "Tuesday, 20 January",
      "time": "09:00 - 10:00",
      "imageUrl": "https://img.freepik.com/free-photo/friendly-smiling-woman-doctor-nurse-wearing-medical-mask-holding-stethoscope_114579-111162.jpg?t=st=1729446001~exp=1729449601~hmac=9e1261563f45c840f6c53545b746f365551c9d9241b18d451a941a8779b00e31&w=360",
    },
    {
      "name": "Dr. Mark Rayson",
      "specialty": "Cardiologist",
      "rating": "4.8",
      "date": "Thursday, 22 January",
      "time": "14:00 - 15:00",
      "imageUrl": "https://img.freepik.com/free-photo/handsome-young-doctor-man-with-stethoscope-grey-wall_23-2148110996.jpg?t=st=1729446059~exp=1729449659~hmac=5c68b3711d9d92e597c45657a8716b66e6b541d40a588b39417c880f019623e6&w=360",
    },
    {
      "name": "Dr. Sarah Kim",
      "specialty": "Neurologist",
      "rating": "4.9",
      "date": "Friday, 23 January",
      "time": "11:30 - 12:30",
      "imageUrl": "https://img.freepik.com/free-photo/attractive-female-doctor-presenting_23-2148332159.jpg?w=360",
    },
  ];

  List<Map<String, String>> _buildDisplayAppointments(List<Appointment> apiAppts) {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppScope.of(context).loadAppointments();
      // Initialize incoming call listener
      IncomingCallService.initialize(context);
    });
  }

  Future<void> _initLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final city = AppScope.of(context).currentUser?.city ?? 'My Location';
      if (!mounted) return;
      setState(() {
        _currentLocation = city;
      });
      _loadNearbyDoctors(position.latitude, position.longitude);
    } catch (_) {}
  }

  Future<void> _loadNearbyDoctors(double lat, double lng) async {
    final doctors = await DoctorApiService.getNearbyDoctors(lat: lat, lng: lng);
    if (mounted) setState(() {
      _nearbyDoctors = doctors;
      _locationLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    if (query.length < 2) {
      if (!mounted) return;
      setState(() => _searchResults = []);
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() => _searching = true);
      final results = await LocationService.searchPlaces(query);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _searching = false;
      });
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _searchDebounce?.cancel();
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final displayAppts = _buildDisplayAppointments(
        AppScope.of(context).appointments,
      );
      
      if (displayAppts.isEmpty || !_pageController.hasClients) return;
      
      final total = displayAppts.length;
      _currentAppointmentIndex = (_currentAppointmentIndex + 1) % (total > 0 ? total : 1);
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
    final displayAppointments = _buildDisplayAppointments(appState.appointments);
    final upcomingCount = appState.appointments.where((a) => a.status == 'upcoming').length;

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
              searchResults: _searchResults,
              searching: _searching,
              onSearchChanged: _onSearchChanged,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
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

            _NearbyDoctorsSection(
              doctors: _nearbyDoctors,
              loading: _locationLoading,
            ),
            const SizedBox(height: 40),
          ],
        ),
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
            color: _currentAppointmentIndex == index ? const Color.fromARGB(255, 223, 198, 3) : Colors.white38,
            borderRadius: BorderRadius.circular(4),
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
  final List<PlaceResult> searchResults;
  final bool searching;
  final Function(String) onSearchChanged;

  const _ModernHeader({
    required this.city,
    required this.upcomingCount,
    required this.searchController,
    required this.searchResults,
    required this.searching,
    required this.onSearchChanged,
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ExploreMapScreen()),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.orangeAccent, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        widget.city,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 18),
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
                    const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            unreadCount > 9 ? '9+' : '$unreadCount',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
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
        // Search bar with dropdown
        Column(
          children: [
            Container(
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: widget.searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search doctors, clinics, locations...",
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  suffixIcon: widget.searching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54)),
                        )
                      : const Icon(Icons.tune_rounded, color: Colors.white54),
                ),
                onChanged: widget.onSearchChanged,
              ),
            ),
            if (widget.searchResults.isNotEmpty) ...[
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.searchResults.length,
                  itemBuilder: (context, index) {
                    final place = widget.searchResults[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on_outlined, color: Color(0xFF2E7DFF)),
                      title: Text(place.displayName, style: const TextStyle(color: Colors.white, fontSize: 13)),
                      subtitle: Text(place.address, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      onTap: () {
                        widget.searchController.text = place.displayName;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ExploreMapScreen()),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ],
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
                    Icon(Icons.notifications_none, size: 60, color: Colors.white38),
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
                        backgroundColor: notification.type == NotificationType.success
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
                          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            notification.message,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.getTimeAgo(),
                            style: const TextStyle(color: Colors.white38, fontSize: 11),
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

  void _navigateToRateAppointment(BuildContext context, String appointmentId, String doctorName) {
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
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Color(0xFF4D91FF), shape: BoxShape.circle),
                    child: Text("${appointments.length}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
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
                child: const Text("See All", style: TextStyle(color: Color(0xFF4D91FF))),
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
                                errorBuilder: (c, e, s) => Container(color: Colors.white12, child: const Icon(Icons.person)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(appointment['name']!,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                  Text(appointment['specialty']!,
                                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                      const SizedBox(width: 4),
                                      Text(appointment['rating']!, style: const TextStyle(color: Colors.white70)),
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
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today_outlined, color: Colors.white.withOpacity(0.9), size: 18),
                          const SizedBox(width: 10),
                          Text(appointment['date']!, style: const TextStyle(color: Colors.white, fontSize: 13)),
                          const Spacer(),
                          Text("|", style: TextStyle(color: Colors.white.withOpacity(0.4))),
                          const Spacer(),
                          Icon(Icons.schedule_outlined, color: Colors.white.withOpacity(0.9), size: 18),
                          const SizedBox(width: 10),
                          Text(appointment['time']!, style: const TextStyle(color: Colors.white, fontSize: 13)),
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
      {'label': 'Heart Rate', 'val': '82 bpm', 'icon': Icons.favorite, 'color': Colors.redAccent},
      {'label': 'Blood Group', 'val': 'O+ Positive', 'icon': Icons.water_drop, 'color': Colors.blueAccent},
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
              border: Border.all(color: (stat['color'] as Color).withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(stat['icon'] as IconData, color: stat['color'] as Color),
                const SizedBox(height: 12),
                Text(stat['val'] as String,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(stat['label'] as String,
                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
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
      {"name": "Teleconsultation", "icon": Icons.favorite_rounded}, // Perfect for dental visual
      {"name": "Home Lab", "icon": Icons.favorite_rounded},
      {"name": "Health Shop", "icon": Icons.psychology_rounded}, // Better brain icon
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
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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
                  color: isFirst ? const Color(0xFF2E7DFF) : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(30), // Oval/Chip shape
                ),
                child: Row(
                  children: [
                    Icon(services[index]['icon'] as IconData, color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      services[index]['name'] as String,
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
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
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ExploreMapScreen()),
                  );
                },
                child: const Text("See All", style: TextStyle(color: Color(0xFF4D91FF))),
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
                      child: Text("No doctors found nearby.", style: TextStyle(color: Colors.white38)),
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
                                builder: (_) => DoctorDetailScreen(doctor: doctor),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          doctor.name,
                                          style: const TextStyle(
                                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                            const SizedBox(width: 4),
                                            Text("${doctor.rating}",
                                                style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                            const Spacer(),
                                            Icon(Icons.location_on_outlined,
                                                color: Colors.white.withOpacity(0.8), size: 18),
                                            const SizedBox(width: 4),
                                            Text("${doctor.distanceKm.toStringAsFixed(1)} km",
                                                style: const TextStyle(color: Colors.white70, fontSize: 14)),
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
                                          color: Colors.white12, shape: BoxShape.circle),
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
