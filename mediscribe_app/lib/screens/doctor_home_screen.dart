import 'package:flutter/material.dart';
import 'package:mediscribe_app/core/app_state.dart';
import 'package:mediscribe_app/services/appointment_service.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(doc?.name ?? 'Doctor', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(doc?.specialty ?? '', style: const TextStyle(fontSize: 12, color: Colors.white54)),
          ],
        ),
        actions: [
          // Online toggle
          Row(
            children: [
              const Text('Online', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(width: 6),
              Switch(
                value: doc?.isOnline ?? false,
                activeColor: const Color(0xFF2E7DFF),
                onChanged: (val) {
                  // TODO: call PUT /api/doctors/:id/online
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(val ? 'You are now online' : 'You are now offline')),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: const Color(0xFF2E7DFF),
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7DFF)))
            : ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  // Stats Row
                  Row(
                    children: [
                      _StatCard(label: 'Total Appointments', value: '${appts.length}'),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Today',
                        value: '${appts.where((a) => a.status == 'upcoming').length}',
                        color: const Color(0xFF2E7DFF),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Upcoming Appointments',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),

                  if (appts.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Text(
                          'No appointments yet.\nPatients will appear here after booking.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    )
                  else
                    ...appts.map((a) => _AppointmentCard(
                          appointment: a,
                          token: appState.token ?? '',
                          onUpdate: _load,
                        )),
                ],
              ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, this.color = Colors.white});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment, required this.token, required this.onUpdate});
  final Appointment appointment;
  final String token;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final statusColor = appointment.status == 'upcoming'
        ? const Color(0xFF2E7DFF)
        : appointment.status == 'completed'
            ? Colors.green
            : Colors.redAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outlined, color: Colors.white54, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Patient • ${appointment.dateLabel} at ${appointment.timeLabel}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  appointment.status,
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('${appointment.specialty} • ${appointment.type}',
              style: const TextStyle(color: Colors.white54, fontSize: 13)),
          if (appointment.status == 'upcoming') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final ok = await AppointmentService.updateStatus(token, appointment.id, 'cancelled');
                      if (ok) onUpdate();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      foregroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final ok = await AppointmentService.updateStatus(token, appointment.id, 'completed');
                      if (ok) onUpdate();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Complete'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
