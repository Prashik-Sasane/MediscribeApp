import 'package:flutter/material.dart';
import 'package:mediscribe_app/core/app_state.dart';
import 'package:mediscribe_app/features/chat/chat_screen.dart';

class DoctorPatientChatList extends StatefulWidget {
  const DoctorPatientChatList({super.key});

  @override
  State<DoctorPatientChatList> createState() => _DoctorPatientChatListState();
}

class _DoctorPatientChatListState extends State<DoctorPatientChatList> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final appState = AppScope.of(context);
    setState(() => _loading = true);
    await appState.loadDoctorAppointments();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    final appointments = appState.doctorAppointments;
    final token = appState.token ?? '';

    // Get unique patients from upcoming appointments
    final patientMap = <String, dynamic>{};
    for (var appt in appointments) {
      if (appt.status == 'upcoming' && appt.patientName != null) {
        patientMap[appt.patientName!] = appt;
      }
    }

    final patients = patientMap.values.toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Patient Chats',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7DFF)),
            )
          : patients.isEmpty
              ? const Center(
                  child: Text(
                    'No patients to chat with',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    return _PatientChatCard(
                      patientName: patient.patientName ?? 'Patient',
                      patientPhone: patient.patientPhone,
                      appointmentId: patient.id,
                      appointmentTime: '${patient.dateLabel} at ${patient.timeLabel}',
                      token: token,
                    );
                  },
                ),
    );
  }
}

class _PatientChatCard extends StatelessWidget {
  final String patientName;
  final String? patientPhone;
  final String appointmentId;
  final String appointmentTime;
  final String token;

  const _PatientChatCard({
    required this.patientName,
    required this.patientPhone,
    required this.appointmentId,
    required this.appointmentTime,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // Patient Avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF2E7DFF).withOpacity(0.2),
            child: Text(
              patientName[0].toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF2E7DFF),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Patient Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appointmentTime,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                if (patientPhone != null && patientPhone!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 14, color: Color(0xFF34D399)),
                      const SizedBox(width: 4),
                      Text(
                        patientPhone!,
                        style: const TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Chat Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    appointmentId: appointmentId,
                    doctorName: patientName,
                    token: token,
                    isDoctor: true,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7DFF).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.chat_bubble,
                color: Color(0xFF2E7DFF),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
