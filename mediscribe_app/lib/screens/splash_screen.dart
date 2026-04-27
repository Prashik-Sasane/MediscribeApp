import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  double _opacity = 0.0;
  double _scale = 0.8;

  @override
  void initState() {
    super.initState();

    // Start animation after a short delay
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        _opacity = 1.0;
        _scale = 1.0;
      });
    });

    // Navigate to Login after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => LoginScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          // Smooth professional gradient
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF0F4F8)], 
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Animated Logo
            AnimatedOpacity(
              duration: const Duration(seconds: 1),
              opacity: _opacity,
              child: AnimatedScale(
                duration: const Duration(seconds: 1),
                scale: _scale,
                curve: Curves.easeOutBack,
                child: Image.asset(
                  'assets/images/mediscribe.png',
                  width: 180,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Subtitle or Branding
            AnimatedOpacity(
              duration: const Duration(seconds: 1),
              opacity: _opacity,
              child: Text(
                "MEDISCRIBE",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: Colors.blueGrey.shade800,
                ),
              ),
            ),
            const Spacer(),
            // Professional Loading Indicator
            const Padding(
              padding: EdgeInsets.only(bottom: 50),
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}