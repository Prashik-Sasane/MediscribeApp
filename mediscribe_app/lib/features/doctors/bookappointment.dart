import 'package:flutter/material.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime selectedDate = DateTime(2026, 1, 15);
  String? selectedTime = "11:00";

  final List<String> times = [
    "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", 
    "12:00", "12:30", "13:00", "13:30", "14:00", "14:30"
  ];

  final List<String> unavailableTimes = ["09:30", "12:30"];

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
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage('https://images.unsplash.com/photo-1559839734-2b71f1e3c770?w=100'),
                    ),
                    const SizedBox(width: 15),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Dr. Jenny William", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("Dentist", style: TextStyle(color: Colors.white38, fontSize: 13)),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 14),
                            Text(" 4.9", style: TextStyle(color: Colors.white, fontSize: 12)),
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
                  Row(
                    children: [
                      const Text("January 2026", style: TextStyle(color: Colors.white70)),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left, color: Colors.white)),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right, color: Colors.white)),
                    ],
                  )
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
          onPressed: () {
            // Navigate to Success or Summary
          },
          child: const Text("Continue", style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 35, // Mocking a month view
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        int day = index - 3; // Shift to start month properly
        if (day < 1 || day > 31) return Container();

        bool isSelected = day == 15;
        return GestureDetector(
          onTap: () => setState(() => selectedDate = DateTime(2026, 1, day)),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2E7DFF) : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                "$day",
                style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
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
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: times.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, index) {
        String time = times[index];
        bool isUnavailable = unavailableTimes.contains(time);
        bool isSelected = selectedTime == time;

        return GestureDetector(
          onTap: isUnavailable ? null : () => setState(() => selectedTime = time),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected 
                  ? const Color(0xFF2E7DFF) 
                  : (isUnavailable ? const Color(0xFFFF5252).withOpacity(0.8) : const Color(0xFF1E293B)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                time,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        );
      },
    );
  }
}