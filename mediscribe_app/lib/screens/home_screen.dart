import 'package:flutter/material.dart';
import 'upload_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(
                        "https://i.pravatar.cc/300"),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Bimasp",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        Text("Kretya Studio, Bekasi",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  const Icon(Icons.notifications_none),
                  const SizedBox(width: 10),
                  const Icon(Icons.chat_bubble_outline),
                ],
              ),

              const SizedBox(height: 25),

 
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("10.231 Coins",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2E7DFF),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {},
                      child: const Text("+ Top Up"),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 25),

              /// 📅 MY APPOINTMENT
              _sectionTitle("My Appointment"),

              const SizedBox(height: 12),

              _appointmentCard(),

              const SizedBox(height: 25),

              /// 🧩 SERVICES GRID
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  _serviceItem(Icons.chat, "Chat Doctor"),
                  _serviceItem(Icons.shopping_bag, "Health Shop"),
                  _serviceItem(Icons.calendar_month, "Appointment"),
                  _serviceItem(Icons.home, "Home Lab"),
                  _serviceItem(Icons.psychology, "Mental Health"),
                  _serviceItem(Icons.face, "Skin Health"),
                  _serviceItem(Icons.local_hospital, "Clinic"),
                  _serviceItem(Icons.more_horiz, "See More"),
                ],
              ),

              const SizedBox(height: 25),

              /// 👨‍⚕️ TOP DOCTOR
              _sectionTitle("Top Doctor"),
              const SizedBox(height: 12),

              _doctorCard(context),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// SECTION TITLE
  static Widget _sectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
        const Text("See All", style: TextStyle(color: Colors.grey))
      ],
    );
  }

  /// APPOINTMENT CARD
  static Widget _appointmentCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundImage:
                NetworkImage("https://i.pravatar.cc/301"),
            radius: 28,
          ),
          SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Dr. Ragil Hutapea",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Clinical Psychologist",
                  style: TextStyle(color: Colors.grey)),
              SizedBox(height: 6),
              Text("08:00 PM  •  Tue, Apr 2",
                  style: TextStyle(color: Colors.green)),
            ],
          )
        ],
      ),
    );
  }

  /// DOCTOR CARD
  static Widget _doctorCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundImage:
                NetworkImage("https://i.pravatar.cc/302"),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Dr. Ragil Hutapea",
                    style:
                        TextStyle(fontWeight: FontWeight.bold)),
                Text("Clinical Psychologist",
                    style: TextStyle(color: Colors.grey)),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.star,
                        color: Colors.orange, size: 18),
                    Text(" 5.0 (128)")
                  ],
                )
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff2E7DFF),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {},
            child: const Text("Book"),
          )
        ],
      ),
    );
  }
}

/// SERVICE GRID ITEM
class _serviceItem extends StatelessWidget {
  final IconData icon;
  final String title;
  const _serviceItem(this.icon, this.title);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xffEAF2FF),
          child: Icon(icon, color: Color(0xff2E7DFF)),
        ),
        const SizedBox(height: 6),
        Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12))
      ],
    );
  }
}
