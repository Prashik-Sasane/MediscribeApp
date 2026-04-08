import 'package:flutter/material.dart';
import 'package:mediscribe_app/features/doctors/bookappointment.dart';
import 'package:mediscribe_app/services/doctor_api_service.dart';
import 'package:mediscribe_app/screens/webrtc_call_screen.dart';
import 'package:mediscribe_app/screens/chat_screen.dart';
import 'package:mediscribe_app/core/app_state.dart';
import 'package:mediscribe_app/widgets/phone_verification_dialog.dart';
import 'package:mediscribe_app/screens/payment_screen.dart';

class DoctorDetailScreen extends StatelessWidget {
  final NearbyDoctor doctor;
  const DoctorDetailScreen({super.key, required this.doctor});

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
        title: const Text("Doctor Details", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.favorite_border, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundColor: const Color(0xFF1E293B),
                  child: doctor.imageUrl.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            doctor.imageUrl,
                            fit: BoxFit.cover,
                            width: 160,
                            height: 160,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.person, size: 80, color: Colors.white);
                            },
                          ),
                        )
                      : const Icon(Icons.person, size: 80, color: Colors.white),
                ),
                if (doctor.isVerified)
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(doctor.name,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                if (doctor.isVerified) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified, color: Colors.green, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'VERIFIED',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            Text(doctor.specialty, style: const TextStyle(color: Colors.white54, fontSize: 16)),
            if (doctor.licenseNumber.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'License: ${doctor.licenseNumber}',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(Icons.people_alt_outlined, "Consultations", "${doctor.reviews}+"),
                  _buildStatItem(Icons.work_outline, "Years Exp.", "${doctor.experience}+"),
                  _buildStatItem(Icons.star_outline, "Rating", doctor.rating.toStringAsFixed(1)),
                  _buildStatItem(Icons.chat_bubble_outline, "Reviews", "${doctor.reviews}"),
                ],
              ),
            ),

            _buildSectionHeader("About Doctor"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                doctor.bio.isNotEmpty
                    ? doctor.bio
                    : "Experienced ${doctor.specialty.toLowerCase()} with ${doctor.experience}+ years of practice. Offers consultations at ₹${doctor.fee} per visit.",
                style: const TextStyle(color: Colors.white70, height: 1.5),
              ),
            ),

            _buildSectionHeader("Consultation Fee"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "₹${doctor.fee}",
                      style: const TextStyle(color: Color(0xFF2E7DFF), fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Distance: ${doctor.distanceKm.toStringAsFixed(1)} km away",
                      style: const TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            // Premium Features Section
            _buildSectionHeader("Premium Features"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2E7DFF).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    _buildFeatureItem(
                      icon: Icons.video_call,
                      title: 'Video Consultation',
                      description: 'Connect face-to-face from anywhere',
                      color: const Color(0xFF60A5FA),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      icon: Icons.chat_bubble_outline,
                      title: 'Instant Chat',
                      description: '24/7 messaging with your doctor',
                      color: const Color(0xFF34D399),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      icon: Icons.schedule,
                      title: 'Flexible Scheduling',
                      description: 'Book appointments at your convenience',
                      color: const Color(0xFFFB923C),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      icon: Icons.verified_user,
                      title: 'Verified & Trusted',
                      description: 'All doctors are medically verified',
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ),

            _buildSectionHeader("Doctor Contact"),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: CircleAvatar(
                backgroundImage: doctor.imageUrl.isNotEmpty
                    ? NetworkImage(doctor.imageUrl)
                    : null,
                backgroundColor: const Color(0xFF1E293B),
                child: doctor.imageUrl.isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              title: Text(doctor.name, style: const TextStyle(color: Colors.white)),
              subtitle: Text(doctor.specialty, style: const TextStyle(color: Colors.white38)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _openChat(context),
                    child: _buildIconButton(Icons.chat),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _openVideoCall(context),
                    child: _buildIconButton(Icons.videocam),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        color: const Color(0xFF0F172A),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Chat & Video Call buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openChat(context),
                    icon: const Icon(Icons.chat, color: Color(0xFF2E7DFF)),
                    label: const Text(
                      'Chat',
                      style: TextStyle(color: Color(0xFF2E7DFF)),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2E7DFF)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openVideoCall(context),
                    icon: const Icon(Icons.videocam, color: Color(0xFF2E7DFF)),
                    label: const Text(
                      'Video Call',
                      style: TextStyle(color: Color(0xFF2E7DFF)),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2E7DFF)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Book Appointment button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7DFF),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BookingScreen(doctor: doctor)),
                );
              },
              child: const Text("Book Appointment", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFF1E293B),
          child: Icon(icon, color: const Color(0xFF2E7DFF), size: 20),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.check_circle, color: color, size: 20),
      ],
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Future<void> _openChat(BuildContext context) async {
    final appState = AppScope.of(context);
    final token = appState.token;
    
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to chat with doctor'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check phone number first
    final hasPhone = await showPhoneVerificationDialog(context);
    if (!hasPhone) return;

    // Check if user has an existing appointment with this doctor
    final existingAppointment = appState.appointments.firstWhere(
      (a) => a.doctorId == doctor.id && a.status == 'upcoming',
      orElse: () => Appointment(doctorName: '', specialty: '', dateLabel: '', timeLabel: '', type: '', location: ''),
    );

    if (existingAppointment.id.isNotEmpty) {
      // Open chat with existing appointment
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            appointmentId: existingAppointment.id,
            doctorName: doctor.name,
            token: token,
            isDoctor: false,
          ),
        ),
      );
    } else {
      // No appointment - prompt to book with payment
      final shouldBook = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Book Appointment',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'You need to book and pay for an appointment with Dr. ${doctor.name} (₹${doctor.fee}) to start chatting.',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7DFF),
              ),
              child: const Text('Proceed to Payment'),
            ),
          ],
        ),
      );

      if (shouldBook == true && context.mounted) {
        final paymentResult = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              doctorId: doctor.id,
              doctorName: doctor.name,
              specialty: doctor.specialty,
              fee: doctor.fee,
              dateLabel: 'Select Date',
              timeLabel: 'Select Time',
            ),
          ),
        );

        if (paymentResult == true && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment booked! You can now chat with the doctor.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  Future<void> _openVideoCall(BuildContext context) async {
    final appState = AppScope.of(context);
    final token = appState.token;
    
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to start video call'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check phone number first
    final hasPhone = await showPhoneVerificationDialog(context);
    if (!hasPhone) return;

    // Check if user has an existing appointment
    final existingAppointment = appState.appointments.firstWhere(
      (a) => a.doctorId == doctor.id && a.status == 'upcoming',
      orElse: () => Appointment(doctorName: '', specialty: '', dateLabel: '', timeLabel: '', type: '', location: ''),
    );

    if (existingAppointment.id.isNotEmpty) {
      // Open WebRTC video call
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebRTCCallScreen(
            targetUserId: doctor.email.isNotEmpty ? doctor.email : doctor.id,
            targetName: doctor.name,
            // targetImageUrl: doctor.imageUrl,
            isIncoming: false,
          ),
        ),
      );
    } else {
      // No appointment - prompt to book with payment
      final shouldBook = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Book Video Consultation',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'You need to book and pay for an appointment with Dr. ${doctor.name} (₹${doctor.fee}) to start video consultation.',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7DFF),
              ),
              child: const Text('Proceed to Payment'),
            ),
          ],
        ),
      );

      if (shouldBook == true && context.mounted) {
        final paymentResult = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              doctorId: doctor.id,
              doctorName: doctor.name,
              specialty: doctor.specialty,
              fee: doctor.fee,
              dateLabel: 'Select Date',
              timeLabel: 'Select Time',
            ),
          ),
        );

        if (paymentResult == true && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment booked! You can now start video consultation.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }
}