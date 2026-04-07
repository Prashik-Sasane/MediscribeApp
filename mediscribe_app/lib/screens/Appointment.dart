import 'package:flutter/material.dart';
import 'package:mediscribe_app/core/app_state.dart';

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
    // Load from backend on first open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppScope.of(context).loadAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0F172A);
    final appState = AppScope.of(context);
    final all = appState.appointments;
    final upcoming  = all.where((a) => a.status == 'upcoming').toList();
    final completed = all.where((a) => a.status == 'completed').toList();
    final cancelled = all.where((a) => a.status == 'cancelled').toList();

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
          
          /// CUSTOM TAB BAR
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

          /// TAB VIEWS
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(upcoming,  "upcoming",  appState),
                _buildList(completed, "completed", appState),
                _buildList(cancelled, "cancelled", appState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Appointment> items, String status, AppState appState) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No $status appointments',
          style: const TextStyle(color: Colors.white38),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => appState.loadAppointments(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return _AppointmentActionCard(
            appointment: items[index],
            onCancel: status == 'upcoming'
                ? () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final ok = await appState.cancelAppointment(items[index].id);
                    messenger.showSnackBar(SnackBar(
                      content: Text(ok ? 'Appointment cancelled' : 'Failed to cancel'),
                    ));
                  }
                : null,
          );
        },
      ),
    );
  }
}

/// INDIVIDUAL APPOINTMENT CARD
class _AppointmentActionCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onCancel;
  const _AppointmentActionCard({required this.appointment, this.onCancel});

  String get status => appointment.status;

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
                  "https://i.pravatar.cc/150?u=${appointment.doctorId}",
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80, height: 80,
                    color: const Color(0xFF1E293B),
                    child: const Icon(Icons.person, color: Colors.white38, size: 40),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appointment.doctorName,
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(appointment.specialty,
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
          
          /// DATE & TIME ROW
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, color: Colors.white38, size: 16),
              const SizedBox(width: 8),
              Text("${appointment.dateLabel} | ${appointment.timeLabel}",
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          
          if (appointment.prescriptionText.isNotEmpty) ...
            [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(appointment.prescriptionText,
                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ),
            ],
          
          const SizedBox(height: 20),

          /// DYNAMIC BUTTONS BASED ON STATUS
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (status == "upcoming") {
      return Row(
        children: [
          Expanded(child: _outlineButton("Cancel Appointment", Colors.redAccent, onCancel)),
          const SizedBox(width: 12),
          Expanded(child: _filledButton("Reschedule", const Color(0xFF2E7DFF), null)),
        ],
      );
    } else if (status == "completed") {
      return Row(
        children: [
          Expanded(child: _outlineButton("Rebook", const Color(0xFF2E7DFF), null)),
          const SizedBox(width: 12),
          Expanded(child: _filledButton("View E-Receipt", const Color(0xFF2E7DFF), null)),
        ],
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: _filledButton("Rebook Now", const Color(0xFF2E7DFF), null),
      );
    }
  }

  Widget _filledButton(String label, Color color, VoidCallback? onTap) {
    return ElevatedButton(
      onPressed: onTap,
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

  Widget _outlineButton(String label, Color color, VoidCallback? onTap) {
    return OutlinedButton(
      onPressed: onTap,
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