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
  final TextEditingController _specialtyController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String? _errorText;
  bool _isSignup = false;
  bool _isDoctor = false; // Patient / Doctor toggle

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _specialtyController.dispose();
    _experienceController.dispose();
    _feeController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
    final appState = AppScope.of(context);
    setState(() => _errorText = null);

    bool success;
    if (_isDoctor) {
      if (_isSignup) {
        success = await appState.doctorSignup(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          specialty: _specialtyController.text.trim(),
          experience: int.tryParse(_experienceController.text.trim()) ?? 0,
          fee: int.tryParse(_feeController.text.trim()) ?? 500,
          bio: _bioController.text.trim(),
        );
      } else {
        success = await appState.doctorLogin(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } else {
      success = _isSignup
          ? await appState.signup(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            )
          : await appState.login(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );
    }

    if (!success) {
      setState(() {
        _errorText = appState.authError ??
            (_isSignup ? 'Signup failed.' : 'Login failed.');
      });
      return;
    }
    if (!mounted) return;
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
                const SizedBox(height: 24),

                // Role toggle
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isDoctor = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isDoctor ? const Color(0xFF2E7DFF) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text('Patient',
                                  style: TextStyle(
                                    color: !_isDoctor ? Colors.white : Colors.white54,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isDoctor = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isDoctor ? const Color(0xFF2E7DFF) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text('Doctor',
                                  style: TextStyle(
                                    color: _isDoctor ? Colors.white : Colors.white54,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Indian Welcome Animation
                const IndianWelcomeSection(),

                const SizedBox(height: 24),

                // LOGIN CARD
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
                        Text(
                          _isDoctor
                              ? (_isSignup ? "Doctor Registration" : "Doctor Login")
                              : "Welcome back 👋",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isSignup ? "Create your account" : "Login to continue",
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),

                        const SizedBox(height: 24),

                        if (_isSignup && _isDoctor) ...[
                          const Text("Specialty", style: TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _specialtyController,
                            decoration: InputDecoration(
                              hintText: "e.g. Cardiology, Dentist",
                              filled: true,
                              fillColor: const Color(0xFF0F172A),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          const Text("Experience (years)", style: TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _experienceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "e.g. 5",
                              filled: true,
                              fillColor: const Color(0xFF0F172A),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          const Text("Consultation Fee (₹)", style: TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _feeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "e.g. 500",
                              filled: true,
                              fillColor: const Color(0xFF0F172A),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          const Text("Bio (optional)", style: TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _bioController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: "Tell patients about yourself...",
                              filled: true,
                              fillColor: const Color(0xFF0F172A),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        if (_isSignup) ...[
                          const Text("Full Name", style: TextStyle(color: AppColors.textSecondary)),
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
                          const SizedBox(height: 16),
                        ],

                        const Text("Email", style: TextStyle(color: AppColors.textSecondary)),
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

                        const SizedBox(height: 16),

                        const Text("Password", style: TextStyle(color: AppColors.textSecondary)),
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

                        const SizedBox(height: 24),

                        PrimaryButton(
                          text: appState.authLoading
                              ? "Please wait..."
                              : (_isSignup ? "Create Account" : "Login"),
                          onPressed: () => _login(context),
                          isDisabled: appState.authLoading,
                        ),
                        if (_errorText != null) ...[
                          const SizedBox(height: 10),
                          Text(_errorText!, style: const TextStyle(color: Colors.redAccent)),
                        ],

                        const SizedBox(height: 20),

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

                        const SizedBox(height: 20),

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

                        const SizedBox(height: 16),

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
                              style: const TextStyle(color: AppColors.textSecondary),
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
