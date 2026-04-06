import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mediscribe_app/features/labtest/lab_test_booking_screen.dart';
import 'package:mediscribe_app/features/consultant/consultant_doctors_screen.dart';
import 'package:mediscribe_app/features/pharmacy/pharmacy_screen.dart';
import 'package:mediscribe_app/screens/upload_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> _sliderItems = [
    {
      "title": "Teleconsultant",
      "subtitle": "Talk to 50+ specialists online right now.",
      "btnText": "Consult Now",
      "icon": Icons.video_camera_front_rounded, // Better Teleconsult icon
      "color": [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
      "image": "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=200",
      "route": "/teleconsult"
    },
    {
      "title": "30% Discount",
      "subtitle": "On all medicines in our Health Shop today!",
      "btnText": "Shop Now",
      "icon": Icons.local_offer_rounded,
      "color": [const Color(0xFF10B981), const Color(0xFF059669)],
      "image": "https://images.unsplash.com/photo-1587854692152-cbe660dbbb88?w=200",
      "route": "/shop"
    },
    {
      "title": "Fast Delivery",
      "subtitle": "Medicines at your doorstep in 30 mins.",
      "btnText": "Order Now",
      "icon": Icons.bolt_rounded,
      "color": [const Color(0xFFF59E0B), const Color(0xFFD97706)],
      "image": "https://images.unsplash.com/photo-1607619056574-7b8d3ee536b2?w=200",
      "route": "/delivery"
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < _sliderItems.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(_currentPage,
            duration: const Duration(milliseconds: 900), curve: Curves.easeInOutCubic);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text("Our Services",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildAnimatedSlider(),
            const SizedBox(height: 30),
            
            _buildSectionHeader("Specialized Care"),
            const SizedBox(height: 15),

            _buildDetailedServiceCard(
              title: "Teleconsultant",
              subtitle: "Video call with top specialists",
              icon: Icons.video_call_rounded, // Clear Tele-health icon
              color: const Color(0xFF60A5FA),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ConsultantSearchScreen())),
            ),
            _buildDetailedServiceCard(
              title: "Home Lab Tests",
              subtitle: "Get reports in 24 hours at home",
              icon: Icons.biotech_rounded,
              color: const Color(0xFF34D399),
              tag: "Popular",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LabTestBookingScreen())),
            ),
            _buildDetailedServiceCard(
              title: "Health Shop",
              subtitle: "Order medicines & wellness items",
              icon: Icons.shopping_bag_rounded, // Changed from pharmacy icon
              color: const Color(0xFFFB923C),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UltraHealthShop())),
            ),
            _buildDetailedServiceCard(
              title: "Upload Prescription",
              subtitle: "We'll find the medicines for you",
              icon: Icons.description_rounded,
              color: const Color(0xFFA78BFA),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UploadScreen())),
            ),

            const SizedBox(height: 30),
            _buildSectionHeader("Quick Actions"),
            const SizedBox(height: 20),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  _buildQuickAction("Ambulance", Icons.emergency_rounded, Colors.redAccent),
                  _buildQuickAction("Insurance", Icons.verified_user_rounded, Colors.cyan),
                  _buildQuickAction("Nursing", Icons.medical_information_rounded, Colors.pinkAccent),
                  _buildQuickAction("Therapy", Icons.psychology_rounded, Colors.indigoAccent),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.5));
  }

  Widget _buildAnimatedSlider() {
    return Column(
      children: [
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) => setState(() => _currentPage = page),
            itemCount: _sliderItems.length,
            itemBuilder: (context, index) => _buildSliderItem(_sliderItems[index]),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_sliderItems.length, (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 4,
              width: _currentPage == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? Colors.blueAccent : Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: item['color'], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15, bottom: -15,
            child: Icon(item['icon'], size: 120, color: Colors.white.withOpacity(0.12)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item['title'], style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text(item['subtitle'], style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4)),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {},
                          child: Text(item['btnText'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                      child: CircleAvatar(radius: 40, backgroundImage: NetworkImage(item['image'])),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedServiceCard({
    required String title, 
    required String subtitle, 
    required IconData icon, 
    required Color color, 
    String? tag,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Row(
          children: [
            Container(
              height: 54, width: 54,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      if (tag != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                          child: Text(tag, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900)),
                        )
                      ]
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white10, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon, Color color) {
    return Container(
      width: 85,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          Container(
            height: 60, width: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 10),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}