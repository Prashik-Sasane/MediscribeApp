import 'package:flutter/material.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final primary = Theme.of(context).colorScheme.primary;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text("My Schedule")),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// TODAY DATE
            Text(
              "Today, 12 March",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor),
            ),

            const SizedBox(height: 18),

            /// 📆 HORIZONTAL DATE STRIP
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _dateItem("Mon", "11", false),
                  _dateItem("Tue", "12", true),
                  _dateItem("Wed", "13", false),
                  _dateItem("Thu", "14", false),
                  _dateItem("Fri", "15", false),
                  _dateItem("Sat", "16", false),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// UPCOMING TITLE
            Text("Upcoming Appointments",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor)),

            const SizedBox(height: 14),

            /// APPOINTMENT LIST
            Expanded(
              child: ListView(
                children: [
                  _appointmentCard(context,
                      "Dr. Sarah Johnson",
                      "Dermatologist",
                      "10:00 AM",
                      "Online",
                      Colors.green),

                  _appointmentCard(context,
                      "Dr. Rahul Sharma",
                      "Cardiologist",
                      "02:30 PM",
                      "Clinic Visit",
                      Colors.orange),

                  _appointmentCard(context,
                      "Dr. Emily Watson",
                      "Psychologist",
                      "06:00 PM",
                      "Video Call",
                      Colors.blue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// APPOINTMENT CARD
  static Widget _appointmentCard(
      BuildContext context,
      String name,
      String specialty,
      String time,
      String type,
      Color statusColor) {
    final surface = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage:
                NetworkImage("https://i.pravatar.cc/304"),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor)),
                Text(specialty,
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 6),
                Text(time,
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(type,
                style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}

/// DATE ITEM
class _dateItem extends StatelessWidget {
  final String day;
  final String date;
  final bool selected;

  const _dateItem(this.day, this.date, this.selected);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).colorScheme.surface;

    return Container(
      width: 65,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: selected ? primary : surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(day,
              style: TextStyle(
                  color: selected ? Colors.white : Colors.grey)),
          const SizedBox(height: 6),
          Text(date,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : Colors.white)),
        ],
      ),
    );
  }
}
