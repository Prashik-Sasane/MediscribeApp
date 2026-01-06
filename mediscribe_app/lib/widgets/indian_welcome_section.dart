import 'dart:async';
import 'package:flutter/material.dart';

class IndianWelcomeSection extends StatefulWidget {
  const IndianWelcomeSection({super.key});

  @override
  State<IndianWelcomeSection> createState() => _IndianWelcomeSectionState();
}

class _IndianWelcomeSectionState extends State<IndianWelcomeSection> {
  final List<String> _greetings = [
    'Hello',
    'नमस्ते',
    'नमस्कार',
    'வணக்கம்',
    'నమస్తే',
    'ನಮಸ್ಕಾರ',
  ];

  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startRotation();
  }

  void _startRotation() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _greetings.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // "Namaste" with illustration
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Namaste',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.2,
              ),
            ),
            const SizedBox(width: 8),
            Image.asset(
              'assets/images/namaste_hands.png',
              height: 60,
              width: 60,
              fit: BoxFit.contain,
              // TODO: Add this asset to pubspec.yaml under:
              // flutter:
              //   assets:
              //     - assets/images/
              errorBuilder: (context, error, stackTrace) {
                // Fallback if image not found
                return Icon(
                  Icons.person_outline,
                  size: 36,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Animated rotating greeting
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: child,
              ),
            );
          },
          child: Text(
            _greetings[_currentIndex],
            key: ValueKey<int>(_currentIndex),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),

        // Tagline
        Text(
          'Digitising prescriptions, the Indian way',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
