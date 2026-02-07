import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text("Profile",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 👤 PROFILE HEADER
            _profileHeader(),

            const SizedBox(height: 25),

            /// ❤️ HEALTH CARD
            _healthCard(),

            const SizedBox(height: 25),

            /// ⚡ QUICK ACTIONS
            const Text("Quick Actions",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),

            _quickActions(),

            const SizedBox(height: 25),

            /// 💎 SUBSCRIPTION CARD
            _subscriptionCard(),

            const SizedBox(height: 25),

            /// ⚙️ MENU OPTIONS
            _menuTile(Icons.shopping_bag, "My Medicine Orders"),
            _menuTile(Icons.calendar_month, "My Appointments"),
            _menuTile(Icons.description, "Prescription History"),
            _menuTile(Icons.settings, "Settings"),
            _menuTile(Icons.help_outline, "Help & Support"),
            _menuTile(Icons.logout, "Logout", isLogout: true),
          ],
        ),
      ),
    );
  }

  /// PROFILE HEADER
  static Widget _profileHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundImage:
                NetworkImage("https://i.pravatar.cc/303"),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Prashik Sasane",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text("prashik@email.com",
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.edit))
        ],
      ),
    );
  }

  /// HEALTH CARD
  static Widget _healthCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff2E7DFF), Color(0xff5BA4FF)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _healthItem("12", "Appointments"),
          _healthItem("05", "Orders"),
          _healthItem("08", "Reports"),
        ],
      ),
    );
  }

  /// QUICK ACTION GRID
  static Widget _quickActions() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _actionItem(Icons.calendar_month, "Appointments"),
        _actionItem(Icons.medication, "Medicines"),
        _actionItem(Icons.document_scanner, "Prescriptions"),
        _actionItem(Icons.camera_alt, "Scan"),
      ],
    );
  }

  /// SUBSCRIPTION CARD
  static Widget _subscriptionCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium,
              color: Colors.orange, size: 40),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Premium Plan",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Text("Unlimited scans & priority doctors",
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Upgrade"),
          )
        ],
      ),
    );
  }

  /// MENU TILE
  static Widget _menuTile(IconData icon, String title,
      {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon,
          color: isLogout ? Colors.red : Colors.blue),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}

/// HEALTH ITEM
class _healthItem extends StatelessWidget {
  final String value;
  final String label;
  const _healthItem(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70))
      ],
    );
  }
}

/// ACTION GRID ITEM
class _actionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  const _actionItem(this.icon, this.title);

  @override
  Widget build(BuildContext context) {
    return Column(
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
