import 'package:flutter/material.dart';
import 'package:mediscribe_app/core/app_state.dart';

import 'schedule_screen.dart';
import '../features/doctors/doctor_list_screen.dart';
import '../features/pharmacy/pharmacy_screen.dart';
import '../features/lab/lab_tests_screen.dart';
import '../features/mental/mental_doctors_screen.dart';
import '../features/skin/skin_doctors_screen.dart';
import '../features/clinics/clinics_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    final userName = appState.currentUser?.name ?? 'Guest';
    final userCoins = appState.currentUser?.coins ?? 0;
    final nextAppointment =
        appState.appointments.isEmpty ? null : appState.appointments.first;
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text("Home"),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(userName: userName),
                const SizedBox(height: 25),
                _CoinsCard(coins: userCoins),
                const SizedBox(height: 25),
                _AppointmentSection(nextAppointment: nextAppointment),
                const SizedBox(height: 25),
                const _ServicesGrid(),
                const SizedBox(height: 25),
                const _TopDoctorSection(),
                const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.userName});
  final String userName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Welcome, $userName 👋",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Text("Find your doctor easily",
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        Icon(Icons.notifications_none, color: Colors.white),
        SizedBox(width: 10),
        Icon(Icons.chat_bubble_outline, color: Colors.white),
      ],
    );
  }
}

class _CoinsCard extends StatelessWidget {
  const _CoinsCard({required this.coins});
  final int coins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$coins Coins",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text("+ Top Up"),
          )
        ],
      ),
    );
  }
}

class _AppointmentSection extends StatelessWidget {
  const _AppointmentSection({required this.nextAppointment});
  final Appointment? nextAppointment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("My Appointment"),
        const SizedBox(height: 12),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ScheduleScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              nextAppointment == null
                  ? "No appointment booked yet"
                  : "${nextAppointment!.doctorName} • ${nextAppointment!.timeLabel}",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        )
      ],
    );
  }
}

class _ServicesGrid extends StatelessWidget {
  const _ServicesGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        ServiceItem(Icons.chat, "Chat Doctor"),
        ServiceItem(Icons.shopping_bag, "Health Shop"),
        ServiceItem(Icons.calendar_month, "Appointment"),
        ServiceItem(Icons.home, "Home Lab"),
        ServiceItem(Icons.psychology, "Mental Health"),
        ServiceItem(Icons.face, "Skin Health"),
        ServiceItem(Icons.local_hospital, "Clinic"),
        ServiceItem(Icons.more_horiz, "See More"),
      ],
    );
  }
}

class _TopDoctorSection extends StatelessWidget {
  const _TopDoctorSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Top Doctor"),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const CircleAvatar(radius: 35),
              const SizedBox(width: 14),
              const Expanded(
                child: Text("Dr. Rahul Sharma",
                    style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DoctorListScreen(),
                    ),
                  );
                },
                child: const Text("Book"),
              )
            ],
          ),
        )
      ],
    );
  }
}

class ServiceItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const ServiceItem(this.icon, this.title, {super.key});

  void _navigate(BuildContext context) {
    Widget? screen;

    switch (title) {
      case "Chat Doctor":
      case "Appointment":
        screen = const DoctorListScreen();
        break;
      case "Health Shop":
        screen = const PharmacyScreen();
        break;
      case "Home Lab":
        screen = const LabTestsScreen();
        break;
      case "Mental Health":
        screen = const MentalDoctorsScreen();
        break;
      case "Skin Health":
        screen = const SkinDoctorsScreen();
        break;
      case "Clinic":
        screen = const ClinicsScreen();
        break;
    }

    if (screen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _navigate(context),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xffEAF2FF),
            child: Icon(icon, color: const Color(0xff2E7DFF)),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          )
        ],
      ),
    );
  }
}

Widget _sectionTitle(String title) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white)),
      const Text("See All", style: TextStyle(color: Colors.grey))
    ],
  );
}