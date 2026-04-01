import 'package:flutter/material.dart';
import 'package:mediscribe_app/core/app_state.dart';
import 'package:mediscribe_app/core/color.dart';
import '../widgets/primary_button.dart';
import '../widgets/indian_welcome_section.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorText;
  bool _isSignup = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
    final appState = AppScope.of(context);
    setState(() => _errorText = null);
    final success = _isSignup
        ? await appState.signup(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          )
        : await appState.login(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
    if (!success) {
      setState(() {
        _errorText = appState.authError ??
            (_isSignup ? 'Signup failed.' : 'Login failed.');
      });
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  void _quickGoogleLogin(BuildContext context) {
    _emailController.text = 'demo.user@gmail.com';
    _passwordController.text = 'google-demo-123';
    _login(context);
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final appState = AppScope.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [

                const SizedBox(height: 40),

                /// 🇮🇳 Indian Welcome Animation
                const IndianWelcomeSection(),

                const SizedBox(height: 30),

                /// LOGIN CARD
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Welcome back 👋",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isSignup ? "Create your account" : "Login to continue",
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 30),

                        if (_isSignup) ...[
                          const Text("Full Name",
                              style: TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: "Your name",
                              filled: true,
                              fillColor: const Color(0xFF0F172A),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        /// EMAIL FIELD
                        const Text("Email",
                            style: TextStyle(
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: "example@gmail.com",
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// PASSWORD FIELD
                        const Text("Password",
                            style: TextStyle(
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "••••••••",
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        /// LOGIN BUTTON
                        PrimaryButton(
                          text: appState.authLoading
                              ? "Please wait..."
                              : (_isSignup ? "Create Account" : "Login"),
                          onPressed: () => _login(context),
                          isDisabled: appState.authLoading,
                        ),
                        if (_errorText != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            _errorText!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ],

                        const SizedBox(height: 25),

                        /// OR DIVIDER
                        Row(
                          children: const [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text("OR"),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),

                        const SizedBox(height: 25),

                        /// GOOGLE LOGIN BUTTON (UI only)
                        OutlinedButton.icon(
                          onPressed: () => _quickGoogleLogin(context),
                          icon: const Icon(Icons.g_mobiledata, size: 28),
                          label: const Text("Continue with Google"),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// SIGNUP TEXT
                        Center(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _isSignup = !_isSignup;
                                _errorText = null;
                              });
                            },
                            child: Text(
                              _isSignup
                                  ? "Already have an account? Login"
                                  : "Don't have an account? Sign Up",
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
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
    );
  }
}
