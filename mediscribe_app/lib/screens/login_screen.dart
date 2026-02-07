import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mediscribe_app/core/color.dart';
import '../widgets/primary_button.dart';
import '../widgets/indian_welcome_section.dart';
import 'main_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // Multi-language greetings
  final List<Map<String, String>> _greetings = [
    {'text': 'Hello', 'lang': 'English'},
    {'text': 'नमस्ते', 'lang': 'Hindi'},
    {'text': 'नमस्कार', 'lang': 'Marathi'},
    {'text': 'வணக்கம்', 'lang': 'Tamil'},
    {'text': 'నమస్తే', 'lang': 'Telugu'},
    {'text': 'ನಮಸ್ಕಾರ', 'lang': 'Kannada'},
  ];

  int _currentGreetingIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  Timer? _greetingTimer;

  @override
  void initState() {
    super.initState();

    // Setup fade animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start with fade in
    _fadeController.forward();

    // Setup greeting rotation timer
    _greetingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _rotateGreeting();
    });
  }

  void _rotateGreeting() {
    // Fade out, change text, fade in
    _fadeController.reverse().then((_) {
      setState(() {
        _currentGreetingIndex = (_currentGreetingIndex + 1) % _greetings.length;
      });
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _greetingTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
<<<<<<< HEAD
      backgroundColor: isDarkMode
          ? AppColors.loginBackgroundDark
          : AppColors.loginBackground,
      body: Stack(
        children: [
          // Subtle mandala background pattern
          Positioned.fill(
            child: Opacity(
              opacity: isDarkMode ? 0.04 : 0.08,
              child: Image.asset(
                'assets/images/mandala_pattern.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image fails to load
                  return const SizedBox.shrink();
                },
              ),
            ),
=======
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // 🙏 Indian Welcome Hero Section
              const Center(
                child: IndianWelcomeSection(),
              ),

              const SizedBox(height: 32),

              // Subtle Indian accent divider
              Center(
                child: Container(
                  width: 80,
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.orange.shade400.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Login Form (centered and constrained)
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 👋 Welcome Text (de-emphasized)
                        Text(
                          'Welcome back',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Let's get you started.",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // 📧 Email
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'example@gmail.com',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 🔒 Password + Forgot
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Password',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              'Forgot Password ?',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // 🔵 Login Button (Mediscribe Primary Color)
                        PrimaryButton(
                          text: 'Login',
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MainNavigation(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 30),

                        // ➖ OR Divider
                        Row(
                          children: const [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'Or',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),

                        const SizedBox(height: 24),

                        OutlinedButton.icon(
                          onPressed: () {
                            // UI-only for demo
                          },
                          icon: Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/0/09/IOS_Google_icon.png',
                            height: 18,
                          ),
                          label: const Text(
                            'Login with Google',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 🆕 Sign Up Text
                        Center(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(fontSize: 14),
                              children: [
                                TextSpan(
                                  text: "Don't have an account ? ",
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                                TextSpan(
                                  text: 'Sign Up',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
>>>>>>> origin/main
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  const SizedBox(
                      height: 60), // Fixed top padding instead of spacer

                  // Main branding: Mediscribe (THE MOST IMPORTANT)
                  _buildMainBranding(isDarkMode),

                  const SizedBox(height: 24),

                  // Animated greetings (smaller, subtle)
                  _buildAnimatedGreeting(isDarkMode),

                  const Spacer(flex: 1), // Push buttons down

                  // Login buttons (middle-ish area)
                  _buildLoginButtonsOnly(isDarkMode),

                  const Spacer(flex: 1), // Balance with bottom

                  // Terms text stays at the bottom as-is
                  Text(
                    'By continuing, you agree to our Terms of Service',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode
                          ? AppColors.subtitleTextDark.withOpacity(0.6)
                          : AppColors.subtitleText.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Main branding section - Logo is the HERO
  Widget _buildMainBranding(bool isDarkMode) {
    return Column(
      children: [
        // Mediscribe Logo - THE MOST IMPORTANT ELEMENT
        Image.asset(
          'assets/images/mediscribe_logo.png',
          height: 120,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to text if logo fails
            return Text(
              'MEDISCRIBE',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.saffron,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        // Tagline
        Text(
          'Digitising prescriptions, the Indian way',
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode
                ? AppColors.subtitleTextDark
                : AppColors.subtitleText,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Animated greeting - smaller, less distracting, NO language label
  Widget _buildAnimatedGreeting(bool isDarkMode) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Text(
        _greetings[_currentGreetingIndex]['text']!,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: isDarkMode
              ? AppColors.subtitleTextDark.withOpacity(0.7)
              : AppColors.subtitleText.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildLoginButtonsOnly(bool isDarkMode) {
    return Column(
      children: [
        // Continue with Google - Primary button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _navigateToHome,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.saffron,
              foregroundColor: Colors.white,
              elevation: 2,
              shadowColor: AppColors.saffron.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google icon placeholder (using a simple G for now)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Text(
                      'G',
                      style: TextStyle(
                        color: AppColors.saffron,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Continue with Google',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Continue with Email - Secondary button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              // TODO: Implement email login
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Email login coming soon!'),
                  backgroundColor: AppColors.saffron,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.saffron,
              side: BorderSide(
                color: AppColors.saffron.withOpacity(0.5),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.email_outlined,
                  color: AppColors.saffron,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  'Continue with Email',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        isDarkMode ? AppColors.saffronLight : AppColors.saffron,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
