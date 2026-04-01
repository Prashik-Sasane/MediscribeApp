import 'package:flutter/material.dart';
import 'package:mediscribe_app/core/app_state.dart';

class DoctorDetailScreen extends StatefulWidget {
  const DoctorDetailScreen({
    super.key,
    required this.doctorName,
    required this.specialty,
    required this.imageUrl,
    this.consultationType = 'Clinic Visit',
    this.feeLabel = '₹500',
    this.locationLabel = '2 km away',
  });

  final String doctorName;
  final String specialty;
  final String imageUrl;
  final String consultationType;
  final String feeLabel;
  final String locationLabel;

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {

  int selectedDateIndex = 0;
  int selectedTimeIndex = -1;

  final List<String> dates = ["Mon 12", "Tue 13", "Wed 14", "Thu 15", "Fri 16"];
  final List<String> times = ["09:00 AM", "10:30 AM", "12:00 PM", "02:30 PM", "05:00 PM"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(title: const Text("Doctor Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(widget.imageUrl),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.doctorName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        Text(widget.specialty,
                            style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.star,color: Colors.orange,size:18),
                            Text(" 4.9 (220 Reviews)",
                                style: const TextStyle(color: Colors.white))
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Nearby: ${widget.locationLabel}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// STATS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statItem("10+", "Years Exp"),
                _statItem("2K+", "Patients"),
                _statItem(widget.feeLabel, "Fee"),
              ],
            ),

            const SizedBox(height: 25),

            /// ABOUT
            const Text("About Doctor",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              "Experienced Cardiologist specializing in heart health, hypertension and preventive care.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 25),

            /// SELECT DATE
            const Text("Select Date",
                style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 10),

            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dates.length,
                itemBuilder: (context,index){
                  final selected = selectedDateIndex == index;
                  return GestureDetector(
                    onTap: (){
                      setState(()=> selectedDateIndex = index);
                    },
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xff2E7DFF)
                            : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          dates[index],
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            /// TIME SLOTS
            const Text("Available Time",
                style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(times.length, (index){
                final selected = selectedTimeIndex == index;
                return GestureDetector(
                  onTap: (){
                    setState(()=> selectedTimeIndex = index);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xff2E7DFF)
                          : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      times[index],
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 30),

            /// BOOK BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: selectedTimeIndex == -1 ? null : (){
                  _bookAppointment(context);
                },
                child: const Text("Book Appointment"),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _bookAppointment(BuildContext context) {
    final appState = AppScope.of(context);
    appState.bookAppointment(
      Appointment(
        doctorName: widget.doctorName,
        specialty: widget.specialty,
        dateLabel: dates[selectedDateIndex],
        timeLabel: times[selectedTimeIndex],
        type: widget.consultationType,
        location: widget.locationLabel,
      ),
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Success 🎉"),
        content: Text(
          'Appointment with ${widget.doctorName} on ${dates[selectedDateIndex]} at ${times[selectedTimeIndex]}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }
}

class _statItem extends StatelessWidget {
  final String value;
  final String label;
  const _statItem(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
