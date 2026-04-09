import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../models/lab_test.dart';
import '../../services/lab_service.dart';
import '../../services/auth_api_service.dart';
import '../../services/payment_service.dart'; // Import PaymentService
import '../../screens/cart_screen.dart'; // Reuse MyOrdersScreen for booking history
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;

import '../../widgets/healthcare/address_picker_sheet.dart';

class LabTestBookingScreen extends StatefulWidget {
  const LabTestBookingScreen({super.key});

  @override
  State<LabTestBookingScreen> createState() => _LabTestBookingScreenState();
}

class _LabTestBookingScreenState extends State<LabTestBookingScreen> {
  int selectedCategory = 0;
  List<LabTest> _labTests = [];
  bool _isLoading = false;
  Map<String, dynamic>? _selectedAddress;

  final List<Map<String, dynamic>> categories = [
    {"name": "All Tests", "icon": Icons.grid_view_rounded},
    {"name": "Blood", "icon": Icons.water_drop_rounded},
    {"name": "Diabetes", "icon": Icons.water_drop_rounded},
    {"name": "Thyroid", "icon": Icons.favorite_rounded},
    {"name": "Full Body", "icon": Icons.accessibility_new_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _fetchLabTests();
    _fetchDefaultAddress();
  }

  Future<void> _fetchDefaultAddress() async {
    final token = AppScope.of(context).token;
    if (token == null) return;
    // AuthApiService import is needed here as well
    final addresses = await AuthApiService.getAddresses(token);
    if (addresses.isNotEmpty) {
      final defaultAddr = addresses.firstWhere((a) => a['isDefault'] == true, orElse: () => addresses.first);
      setState(() => _selectedAddress = Map<String, dynamic>.from(defaultAddr));
    }
  }

  void _onSelectAddress() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddressPickerSheet(
        onSelected: (addr) {
          setState(() => _selectedAddress = addr);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _fetchLabTests({String? query, String? category}) async {
    setState(() => _isLoading = true);
    final tests = await LabService.fetchLabTests(
      query: query,
      category: category == "All Tests" ? null : category,
    );
    setState(() {
      _labTests = tests;
      _isLoading = false;
    });
  }

  void _onCategoryChanged(int index) {
    setState(() => selectedCategory = index);
    _fetchLabTests(category: categories[index]['name']);
  }

  void _onSearch(String q) {
    _fetchLabTests(query: q, category: categories[selectedCategory]['name']);
  }

  Future<void> _bookTest(LabTest test) async {
    final state = AppScope.of(context);
    final token = state.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to book a test")),
      );
      return;
    }

    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an address for home collection")),
      );
      return;
    }

    // Show Booking Confirmation Dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Confirm Booking", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(test.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Price: \$${test.price}", style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            const Text("Payment Method:", style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7DFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2E7DFF)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.credit_card, color: Color(0xFF2E7DFF)),
                  const SizedBox(width: 8),
                  const Text("Stripe (Card Payment)", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text("This booking includes home collection and reports within 24 hours.", 
                style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7DFF)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Pay with Stripe"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Processing payment...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Create booking first
      final bookingId = await LabService.createBooking(
        token: token,
        labTestId: test.id,
        address: _selectedAddress!,
        preferredDate: DateTime.now().add(const Duration(days: 1)),
        timeSlot: "Morning (7AM - 10AM)",
        amount: test.price,
      );

      if (bookingId == null) {
        Navigator.pop(context); // Close loading
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to create booking")),
          );
        }
        return;
      }

      // Process Stripe Payment
      final result = await PaymentService.processStripePayment(
        token: token,
        amount: test.price.toDouble(),
        orderType: 'lab_test',
        orderId: bookingId,
        publishableKey: 'pk_test_your_stripe_key_here', // Replace with your test key
      );

      Navigator.pop(context); // Close loading

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Payment successful! Test booked."),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to My Orders/History
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? "Payment failed"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      Navigator.pop(context); // Close loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A).withOpacity(0.8),
        elevation: 0,
        centerTitle: false,
        title: const Text("Lab Tests", 
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.white, size: 22),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
            ),
          ),
          _buildAppBarAction(Icons.shopping_cart_outlined),
          const SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          // Background decorative glow
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2E7DFF).withOpacity(0.05),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 110, left: 20, right: 20, bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAddressBar(),
                const SizedBox(height: 20),
                _buildModernSearchBar(),
                const SizedBox(height: 30),
                
                _buildSectionHeader("Browse by Category"),
                const SizedBox(height: 15),
                _buildCategoryChips(),
                
                const SizedBox(height: 30),
                _buildSectionHeader("Available Lab Tests"),
                const SizedBox(height: 15),
                
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: Color(0xFF2E7DFF)),
                    ),
                  )
                else if (_labTests.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text("No tests found", style: TextStyle(color: Colors.white54)),
                    ),
                  )
                else
                  ..._labTests.map((test) => _buildPremiumPackageCard(
                    title: test.name,
                    tests: test.description,
                    price: test.price.toString(),
                    oldPrice: (test.price * 1.5).toInt().toString(),
                    tag: test.tags.isNotEmpty ? test.tags.first.toUpperCase() : "AVAILABLE",
                    tagColor: test.tags.contains("popular") ? const Color(0xFF10B981) : Colors.amber,
                    features: ["Home Collection", "Report in 24h"],
                    onBook: () => _bookTest(test),
                  )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarAction(IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 22),
        onPressed: () {},
      ),
    );
  }

  Widget _buildAddressBar() {
    return InkWell(
      onTap: _onSelectAddress,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_rounded, color: Color(0xFF2E7DFF), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedAddress != null ? "Home Collection at ${_selectedAddress!['label']}" : "Select Collection Address",
                    style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _selectedAddress != null ? _selectedAddress!['fullAddress'] : "Tap to select address",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  Widget _buildModernSearchBar() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: TextField(
        onChanged: _onSearch,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: "Search tests, packages or symptoms...",
          hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF2E7DFF)),
          suffixIcon: Icon(Icons.tune_rounded, color: Colors.white38, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const Icon(Icons.arrow_forward_rounded, color: Colors.white24, size: 20),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedCategory == index;
          return GestureDetector(
            onTap: () => _onCategoryChanged(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2E7DFF) : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? Colors.white24 : Colors.white.withOpacity(0.05),
                ),
              ),
              child: Row(
                children: [
                  Icon(categories[index]['icon'], 
                    size: 18, color: isSelected ? Colors.white : Colors.white54),
                  const SizedBox(width: 8),
                  Text(categories[index]['name'], 
                    style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumPackageCard({
    required String title,
    required String tests,
    required String price,
    required String oldPrice,
    required String tag,
    required Color tagColor,
    required List<String> features,
    required VoidCallback onBook,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1E293B), const Color(0xFF1E293B).withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: tagColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                      child: Text(tag, style: TextStyle(color: tagColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                    ),
                    const Icon(Icons.bookmark_border_rounded, color: Colors.white24),
                  ],
                ),
                const SizedBox(height: 15),
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(tests, style: const TextStyle(color: Color(0xFF10B981), fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 15),
                
                // Feature horizontal list
                Wrap(
                  spacing: 10,
                  children: features.map((f) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: Colors.white38, size: 14),
                      const SizedBox(width: 4),
                      Text(f, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  )).toList(),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("\$$price", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text("\$$oldPrice", style: const TextStyle(color: Colors.white24, fontSize: 14, decoration: TextDecoration.lineThrough)),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: onBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7DFF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text("Book Now", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}