import 'package:flutter/material.dart';
import 'package:mediscribe_app/core/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    final user = appState.currentUser;
    final name  = user?.name  ?? 'Jenny William';
    final email = user?.email ?? 'jenny.william@gmail.com';
    final appointmentCount = appState.appointments.length;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("My Profile",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 110),

            _ProfessionalHeader(
              name: name,
              email: email,
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HealthStatsRow(appointments: appointmentCount, orders: 5, reports: 8),

                  const SizedBox(height: 32),

                  const Text("Quick Actions",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const _QuickActionGrid(),

                  const SizedBox(height: 32),

                  const _PremiumCard(),

                  const SizedBox(height: 32),

                  const Text("General Settings",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildMenuSection([
                    _MenuData(Icons.shopping_bag_outlined, "Medicine Orders"),
                    _MenuData(Icons.calendar_today_outlined, "Appointment History"),
                    _MenuData(Icons.description_outlined, "Medical Records"),
                    _MenuData(Icons.notifications_none_rounded, "Notifications"),
                  ]),

                  const SizedBox(height: 24),

                  _buildMenuTile(Icons.logout_rounded, "Logout",
                      isLogout: true,
                      onTap: () => appState.logout()),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for Sectioned Menu
  Widget _buildMenuSection(List<_MenuData> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: items.map((item) => _buildMenuTile(item.icon, item.title)).toList(),
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, {bool isLogout = false, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isLogout ? Colors.red.withOpacity(0.1) : const Color(0xFF2E7DFF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isLogout ? Colors.redAccent : const Color(0xFF4D91FF), size: 22),
      ),
      title: Text(title,
          style: TextStyle(
            color: isLogout ? Colors.redAccent : Colors.white.withOpacity(0.9),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          )),
      trailing: Icon(Icons.arrow_forward_ios_rounded,
          color: isLogout ? Colors.transparent : Colors.white24, size: 14),
      onTap: onTap ?? () {},
    );
  }
}

// --- SUB-WIDGETS ---

class _ProfessionalHeader extends StatelessWidget {
  final String name;
  final String email;

  const _ProfessionalHeader({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2E7DFF), width: 3),
                ),
                child: const CircleAvatar(
                  radius: 55,
                  backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7DFF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(name,
              style: const TextStyle(
                  color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(email,
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
        ],
      ),
    );
  }
}

class _HealthStatsRow extends StatelessWidget {
  final int appointments, orders, reports;
  const _HealthStatsRow({required this.appointments, required this.orders, required this.reports});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7DFF), Color(0xFF1A56B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF2E7DFF).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(appointments.toString(), "Visits"),
          _vDivider(),
          _statItem(orders.toString(), "Orders"),
          _vDivider(),
          _statItem(reports.toString(), "Reports"),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(height: 30, width: 1, color: Colors.white24);

  Widget _statItem(String val, String label) {
    return Column(
      children: [
        Text(val,
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid();

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'icon': Icons.calendar_today_rounded, 'label': 'Schedule'},
      {'icon': Icons.medication_rounded, 'label': 'Meds'},
      {'icon': Icons.qr_code_scanner_rounded, 'label': 'Scan'},
      {'icon': Icons.history_rounded, 'label': 'History'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((act) {
        return Column(
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Icon(act['icon'] as IconData, color: const Color(0xFF4D91FF), size: 26),
            ),
            const SizedBox(height: 10),
            Text(act['label'] as String,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        );
      }).toList(),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9F1C).withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFF9F1C).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFF9F1C), size: 40),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Join Premium",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Get priority doctor consultations",
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_rounded, color: const Color(0xFFFF9F1C).withOpacity(0.8)),
        ],
      ),
    );
  }
}

class _MenuData {
  final IconData icon;
  final String title;
  _MenuData(this.icon, this.title);
}