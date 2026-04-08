import 'package:flutter/material.dart';
import 'package:mediscribe_app/core/app_state.dart';
import 'package:mediscribe_app/screens/Appointment.dart';
import 'package:mediscribe_app/services/doctor_api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BookingScreen extends StatefulWidget {
  final NearbyDoctor doctor;
  const BookingScreen({super.key, required this.doctor});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime selectedDate = DateTime.now().add(const Duration(days: 3));
  String? selectedTime;
  bool _booking = false;
  List<String> availableSlots = [];
  bool _loadingSlots = false;

  final List<String> allTimes = [
    "09:00", "09:30", "10:00", "10:30", "11:00", "11:30",
    "12:00", "12:30", "13:00", "13:30", "14:00", "14:30",
    "15:00", "15:30", "16:00", "16:30", "17:00"
  ];

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const List<String> _dayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  String get _monthName => '${_monthNames[selectedDate.month - 1]} ${selectedDate.year}';
  String get _dateLabel {
    final day = _dayNames[selectedDate.weekday - 1];
    return '$day, ${_monthNames[selectedDate.month - 1]} ${selectedDate.day}';
  }

  @override
  void initState() {
    super.initState();
    _loadAvailableSlots();
  }

  Future<void> _loadAvailableSlots() async {
    setState(() => _loadingSlots = true);
    
    try {
      final dateStr = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/doctors/${widget.doctor.id}/available-slots?date=$dateStr'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final slots = data['slots'] as List;
        setState(() {
          availableSlots = slots
              .where((s) => s['available'] == true)
              .map((s) => s['time'] as String)
              .toList();
          selectedTime = availableSlots.isNotEmpty ? availableSlots[0] : null;
        });
      }
    } catch (e) {
      print('Error loading slots: $e');
    } finally {
      if (mounted) {
        setState(() => _loadingSlots = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Book Appointment", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Doctor Mini-Card
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(widget.doctor.imageUrl),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.doctor.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(widget.doctor.specialty, style: const TextStyle(color: Colors.white38, fontSize: 13)),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            Text(" ${widget.doctor.rating.toStringAsFixed(1)}", style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // 2. Select Date Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Select Date", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(_monthName, style: const TextStyle(color: Colors.white70))
                  ],
                ),
                _buildCalendarGrid(),
              const SizedBox(height: 25),

              // 3. Select Time Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Select Time", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  _buildStatusLegend(),
                ],
              ),
              const SizedBox(height: 15),
              _buildTimeGrid(),
              const SizedBox(height: 100), // Space for bottom button
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7DFF),
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          onPressed: _booking ? null : _bookAppointment,
          child: _booking
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Confirm Booking", style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }

  Future<void> _bookAppointment() async {
    final messenger = ScaffoldMessenger.of(context);
    final appState = AppScope.of(context);
    setState(() => _booking = true);

    final ok = await appState.bookAppointment(
      Appointment(
        doctorId: widget.doctor.id,
        doctorName: widget.doctor.name,
        specialty: widget.doctor.specialty,
        dateLabel: _dateLabel,
        timeLabel: selectedTime ?? '09:00',
        type: 'General checkup',
        location: 'Clinic',
      ),
    );

    if (!mounted) return;
    setState(() => _booking = false);

    if (ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Appointment booked successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AppointmentsScreen()),
        (route) => route.isFirst,
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Booking failed. Please try again.'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Widget _buildCalendarGrid() {
    final now = DateTime(selectedDate.year, selectedDate.month, 1);
    final firstWeekday = now.weekday;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: firstWeekday + daysInMonth,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        if (index < firstWeekday) return Container();
        int day = index - firstWeekday + 1;
        bool isSelected = day == selectedDate.day;
        bool isPast = DateTime(selectedDate.year, selectedDate.month, day).isBefore(DateTime.now().subtract(const Duration(days: 1)));

        return GestureDetector(
          onTap: isPast ? null : () {
            setState(() => selectedDate = DateTime(selectedDate.year, selectedDate.month, day));
            _loadAvailableSlots();
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF2E7DFF)
                  : (isPast ? Colors.white.withOpacity(0.05) : const Color(0xFF1E293B)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                "$day",
                style: TextStyle(
                  color: isPast ? Colors.white24 : (isSelected ? Colors.white : Colors.white60),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusLegend() {
    return Row(
      children: [
        _legendItem(Colors.white24, "Available"),
        const SizedBox(width: 10),
        _legendItem(const Color(0xFFFF5252), "Not-Available"),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }

  Widget _buildTimeGrid() {
    if (_loadingSlots) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: Color(0xFF2E7DFF)),
        ),
      );
    }

    if (availableSlots.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'No available slots for this date',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allTimes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, index) {
        String time = allTimes[index];
        bool isAvailable = availableSlots.contains(time);
        bool isSelected = selectedTime == time;

        return GestureDetector(
          onTap: isAvailable ? () => setState(() => selectedTime = time) : null,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected 
                  ? const Color(0xFF2E7DFF) 
                  : (isAvailable ? const Color(0xFF1E293B) : const Color(0xFFFF5252).withOpacity(0.3)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                time,
                style: TextStyle(
                  color: isSelected ? Colors.white : (isAvailable ? Colors.white : Colors.white24),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}