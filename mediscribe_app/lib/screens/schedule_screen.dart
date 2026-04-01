import 'package:flutter/material.dart';
import 'package:mediscribe_app/core/app_state.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _selectedDate = 1;

  @override
  Widget build(BuildContext context) {
    final appointments = AppScope.of(context).appointments;
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
                children: List.generate(6, (index) {
                  final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
                  final dates = ["11", "12", "13", "14", "15", "16"];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDate = index),
                    child: _dateItem(days[index], dates[index], _selectedDate == index),
                  );
                }),
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
              child: appointments.isEmpty
                  ? const Center(
                      child: Text('No appointments yet. Book from Doctors tab.'),
                    )
                  : ListView.builder(
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final a = appointments[index];
                        return _appointmentCard(
                          context,
                          a.doctorName,
                          a.specialty,
                          '${a.dateLabel} • ${a.timeLabel}',
                          a.type,
                          a.type == 'Clinic Visit' ? Colors.orange : Colors.green,
                        );
                      },
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
