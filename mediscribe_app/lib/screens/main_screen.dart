import 'package:flutter/material.dart';
import 'package:mediscribe_app/core/app_state.dart';
import 'home_screen.dart';
import 'doctor_home_screen.dart';
import 'package:mediscribe_app/screens/schedule_screen.dart';
// import 'package:mediscribe_app/features/doctors/doctor_list_screen.dart';
// import 'package:mediscribe_app/features/doctors/doctor_detail_screen.dart';
import 'package:mediscribe_app/screens/find_doctors_screen.dart';
import 'upload_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  List<Widget> _buildScreens(bool isDoctor) {
    if (isDoctor) {
      return const [
        DoctorHomeScreen(),
        ScheduleScreen(),
        UploadScreen(),
        ProfileScreen(),
      ];
    }
    return const [
      HomeScreen(),
      DoctorListScreen(),
      UploadScreen(),
      ProfileScreen(),
    ];
  }

  List<BottomNavigationBarItem> _buildItems(bool isDoctor) {
    if (isDoctor) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Appointments"),
        BottomNavigationBarItem(icon: Icon(Icons.document_scanner), label: "Scan"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ];
    }
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Appointments"),
      BottomNavigationBarItem(icon: Icon(Icons.document_scanner), label: "Scan"),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    final isDoctor = appState.isDoctor;
    final screens = _buildScreens(isDoctor);
    final items = _buildItems(isDoctor);

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xff2E7DFF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        items: items,
      ),
    );
  }
}
