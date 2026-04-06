import 'package:flutter/material.dart';
import 'package:mediscribe_app/screens/appointment.dart';
import 'package:mediscribe_app/screens/location_screen.dart';
import 'package:mediscribe_app/features/service/services_screen.dart';
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

  // Mock Data aligned with visual design
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        _currentAppointmentIndex = (_currentAppointmentIndex + 1) % _mockAppointments.length;
        _pageController.animateToPage(
          _currentAppointmentIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // The base dark color
      // 1. Blue Header Container (Matches visual exactly)
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(170), // Height for location + search
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          color: const Color(0xFF2E7DFF), // The bright blue background
          child: const SafeArea(child: _ModernHeader()),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // 2. Upcoming Appointments (Redesigned visual)
            _UpcomingAppointmentsSlider(
              controller: _pageController,
              currentIndex: _currentAppointmentIndex,
              appointments: _mockAppointments,
            ),
            const SizedBox(height: 28),

            // 3. Dot Indicator for PageView
            _buildDotIndicator(),
            const SizedBox(height: 28),

            // 4. Services Section with custom visual chips
            const _ServiceSection(),
            const SizedBox(height: 32),

            // 5. Nearby Doctors Section
            const _NearbyHospitalsSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _mockAppointments.length,
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

class _ModernHeader extends StatelessWidget {
  const _ModernHeader();

  @override
  Widget build(BuildContext context) {
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
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.orangeAccent, size: 20),
                    const SizedBox(width: 6),
                    const Text(
                      "New York, USA",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 18),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Stack(
                children: [
                  const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        // Search bar moved into header container
        Container(
          height: 55,
          child: const TextField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Search",
              hintStyle: TextStyle(color: Colors.white38, fontSize: 15),
              prefixIcon: Icon(Icons.search_rounded, color: Colors.white54),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 15),
              suffixIcon: Icon(Icons.tune_rounded, color: Colors.white54), // Best icon for settings/filter
            ),
          ),
        ),
      ],
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
                    child: const Text("3", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
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
              child: const Text(
                "See All",
                style: TextStyle(color: Color(0xFF4D91FF)),
              ),
            )
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 190, // Taller for the bottom banner logic
          child: PageView.builder(
            controller: controller,
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B), // Dark card background
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Main card content
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
                    // Visual-first bottom blue banner (Identical to image)
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

class _NearbyHospitalsSection extends StatelessWidget {
  const _NearbyHospitalsSection();

  @override
  Widget build(BuildContext context) {
    final doctors = [
      {
        "name": "City Medical Center",
        "rating": "4.8",
        "distance": "1.2 km",
        "imageUrl": "https://images.pexels.com/photos/7578808/pexels-photo-7578808.jpeg?auto=compress&cs=tinysrgb&w=360",
      },
      {
        "name": "Neuro Specialty",
        "rating": "4.7",
        "distance": "0.9 km",
        "imageUrl": "https://images.pexels.com/photos/7578796/pexels-photo-7578796.jpeg?auto=compress&cs=tinysrgb&w=360",
      },
      {
        "name": "Heart Care Hospital",
        "rating": "4.6",
        "distance": "2.1 km",
        "imageUrl": "https://images.pexels.com/photos/15694269/pexels-photo-15694269.jpeg?auto=compress&cs=tinysrgb&w=360",
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Nearby Doctors", // User-specific visual prompt
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
               TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExploreMapScreen(),
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
          height: 240, // Increased height for visual-first card logic
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            scrollDirection: Axis.horizontal,
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return Container(
                width: 280, // Wider visual cards
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Full image in background (as visual priority)
                      Image.network(
                        doctor['imageUrl']!,
                        height: double.infinity,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(color: Colors.white12, child: const Icon(Icons.apartment_rounded, size: 80)),
                      ),
                      // Gradient Overlay for text readability
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
                      // Text content in the area matching the design
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor['name']!,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                const SizedBox(width: 4),
                                Text("${doctor['rating']!}", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                const Spacer(),
                                Icon(Icons.location_on_outlined, color: Colors.white.withOpacity(0.8), size: 18),
                                const SizedBox(width: 4),
                                Text(doctor['distance']!, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Favorite button indicator
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
                          child: const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 20),
                        ),
                      ),
                    ],
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
