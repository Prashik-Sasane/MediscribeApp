import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:mediscribe_app/core/app_state.dart';
import 'package:mediscribe_app/services/appointment_service.dart';
import 'package:mediscribe_app/features/consultant/consultant_doctors_screen.dart';
import 'package:mediscribe_app/screens/chat_screen.dart';
import 'package:mediscribe_app/screens/doctor_patient_chat_list.dart';
import 'package:mediscribe_app/screens/webrtc_call_screen.dart';
import 'package:mediscribe_app/services/incoming_call_service.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize incoming call listener
      IncomingCallService.initialize(context);
    });
  }

  Future<void> _load() async {
    final appState = AppScope.of(context);
    setState(() => _loading = true);
    await appState.loadDoctorAppointments();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    final doc = appState.currentUser;
    final appts = appState.doctorAppointments;
    
    // Logic for "Next Patient" (First upcoming appointment)
    final upcomingAppts = appts.where((a) => a.status == 'upcoming').toList();
    final nextPatient = upcomingAppts.isNotEmpty ? upcomingAppts.first : null;
    final remainingAppts = upcomingAppts.length > 1 ? upcomingAppts.sublist(1) : [];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: RefreshIndicator(
        onRefresh: _load,
        color: const Color(0xFF2E7DFF),
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7DFF)))
            : CustomScrollView(
                slivers: [
                  // 1. TOP BAR (Sliver for smooth scrolling)
                  SliverAppBar(
                    expandedHeight: 80,
                    floating: true,
                    backgroundColor: const Color(0xFF1E293B),
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    title: _buildTopBar(doc),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.all(18),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // 2. DASHBOARD CARDS
                        Row(
                          children: [
                            _StatCard(label: 'Patients', value: '${appts.length}', icon: Icons.people_outline),
                            const SizedBox(width: 10),
                            _StatCard(label: 'Today', value: '${upcomingAppts.length}', color: const Color(0xFF2E7DFF), icon: Icons.calendar_today_outlined),
                            const SizedBox(width: 10),
                            _StatCard(label: 'Earnings', value: '\$2.4k', color: Colors.greenAccent, icon: Icons.account_balance_wallet_outlined),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // 2.5 QUICK ACTIONS
                        _buildQuickActions(),

                        const SizedBox(height: 30),

                        // 3. NEXT PATIENT (BIG CARD)
                        if (nextPatient != null) ...[
                          _buildSectionHeader("Next Patient", "View Schedule"),
                          const SizedBox(height: 12),
                          _buildNextPatientHero(nextPatient, appState),
                          const SizedBox(height: 30),
                        ],

                        // 4. UPCOMING APPOINTMENTS LIST
                        _buildSectionHeader("Upcoming Appointments", "See All"),
                        const SizedBox(height: 12),

                        if (upcomingAppts.isEmpty)
                          _buildEmptyState()
                        else
                          ...upcomingAppts.map((a) => _AppointmentCard(
                                appointment: a,
                                token: appState.token ?? '',
                                onUpdate: _load,
                              )),

                        const SizedBox(height: 30),

                        // 5. BOTTOM SECTION (Analytics Mini-Teaser)
                        _buildAnalyticsTeaser(),
                        const SizedBox(height: 40),
                      ]),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTopBar(doc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome back,", style: TextStyle(color: Colors.white54, fontSize: 12)),
            Text("Dr. ${doc?.name ?? 'Doctor'}", 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Text(
                doc?.isOnline ?? false ? 'ONLINE' : 'OFFLINE',
                style: TextStyle(
                  color: doc?.isOnline ?? false ? Colors.greenAccent : Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(width: 4),
              Switch(
                value: doc?.isOnline ?? false,
                activeColor: Colors.greenAccent,
                onChanged: (val) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(val ? 'System: You are now online' : 'System: You are now offline')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNextPatientHero(appointment, dynamic appState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7DFF), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF2E7DFF).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appointment.patientName ?? "Patient Name", 
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("${appointment.timeLabel} • ${appointment.type}", 
                        style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    if (appointment.patientPhone != null && appointment.patientPhone!.isNotEmpty)
                      Text(
                        "📞 ${appointment.patientPhone}",
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.videocam, color: Colors.white),
              )
            ],
          ),
          const Divider(color: Colors.white24, height: 30),
          Row(
            children: [
              const Icon(Icons.psychology_outlined, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              const Text("Problem: ", style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text(appointment.specialty ?? "General Checkup", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _startConsultation(context, appointment, appState),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2E7DFF),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 0,
            ),
            child: const Text("START CONSULTATION", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(action, style: const TextStyle(color: Color(0xFF2E7DFF), fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.video_call,
                  label: 'Teleconsultation',
                  color: const Color(0xFF60A5FA),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ConsultantSearchScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'Patient Chats',
                  color: const Color(0xFF34D399),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DoctorPatientChatList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTeaser() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.analytics_outlined, color: Colors.orangeAccent),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Weekly Analytics", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text("Your efficiency is up by 12% this week.", style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white24),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 40),
        child: Text(
          'No other appointments for today.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }

  void _startConsultation(BuildContext context, dynamic appointment, dynamic appState) {
    // Check if running on mobile platform (WebRTC only works on Android/iOS)
    final isMobile = Platform.isAndroid || Platform.isIOS;
    
    if (!isMobile) {
      // Show message for desktop/web platforms
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Video Call Not Available',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Video consultations are only available on mobile devices (Android/iOS). '
            'Please use the mobile app to start video calls.\n\n'
            'You can still chat with the patient using the chat feature.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Color(0xFF2E7DFF))),
            ),
          ],
        ),
      );
      return;
    }

    // Mobile platform - start WebRTC call
    final patientName = appointment.patientName ?? 'Patient';
    final patientEmail = appointment.patientEmail ?? '';
    
    // Use patient's email for Socket.io routing (matches how users register)
    final targetUserId = patientEmail;
    
    if (targetUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patient email not available. Cannot start video call.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebRTCCallScreen(
          targetUserId: targetUserId,
          targetName: patientName,
          targetImageUrl: '',
          isIncoming: false,
        ),
      ),
    );
  }
}

// Updated Stat Card with Icons
class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, this.color = Colors.white});
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color.withOpacity(0.7), size: 20),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment, required this.token, required this.onUpdate});
  final dynamic appointment;
  final String token;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(15)),
            child: const Icon(Icons.person_outline, color: Color(0xFF2E7DFF)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.patientName ?? 'Patient',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text('${appointment.dateLabel} • ${appointment.timeLabel}', 
                    style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 28),
            onPressed: () async {
              final ok = await AppointmentService.updateStatus(token, appointment.id, 'completed');
              if (ok) onUpdate();
            },
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}