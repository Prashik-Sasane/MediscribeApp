import 'package:flutter/material.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("My Appointments", 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          
          /// 🏷️ CUSTOM TAB BAR
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF2E7DFF),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white38,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(text: "Upcoming"),
                Tab(text: "Completed"),
                Tab(text: "Cancelled"),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// 📂 TAB VIEWS
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAppointmentList("upcoming"),
                _buildAppointmentList("completed"),
                _buildAppointmentList("cancelled"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(String status) {
    // This is where you would normally map your appointments from AppState
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 3,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return _AppointmentActionCard(status: status);
      },
    );
  }
}

/// 📇 INDIVIDUAL APPOINTMENT CARD
class _AppointmentActionCard extends StatelessWidget {
  final String status;
  const _AppointmentActionCard({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  "https://i.pravatar.cc/150?u=$status",
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Dr. James Chen", 
                        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("Radiologist Specialist", 
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (i) => Icon(Icons.star_rounded, 
                          color: i < 4 ? Colors.amber : Colors.white24, size: 16)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 16),
          
          /// 📅 DATE & TIME ROW
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, color: Colors.white38, size: 16),
              const SizedBox(width: 8),
              const Text("Dec 10, 2025 | 10:00 AM", 
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          
          const SizedBox(height: 20),

          /// 🔘 DYNAMIC BUTTONS BASED ON STATUS
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (status == "upcoming") {
      return Row(
        children: [
          Expanded(child: _outlineButton("Cancel Appointment", Colors.redAccent)),
          const SizedBox(width: 12),
          Expanded(child: _filledButton("Reschedule", const Color(0xFF2E7DFF))),
        ],
      );
    } else if (status == "completed") {
      return Row(
        children: [
          Expanded(child: _outlineButton("Rebook", const Color(0xFF2E7DFF))),
          const SizedBox(width: 12),
          Expanded(child: _filledButton("View E-Receipt", const Color(0xFF2E7DFF))),
        ],
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: _filledButton("Rebook Now", const Color(0xFF2E7DFF)),
      );
    }
  }

  Widget _filledButton(String label, Color color) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _outlineButton(String label, Color color) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(0.5)),
        foregroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}