import 'package:flutter/material.dart';
import 'package:yalla_safqa/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordObscured = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final Color _bgColor = const Color.fromARGB(255, 38, 2, 58);
  final Color _cardColor = const Color(0xFF1A1A2E);
  final Color _primaryPurple = const Color(0xFF6E56FF);
  final Color _textSecondary = const Color(0xFF8E8E9F);
  final Color _successGreen = const Color(0xFF00D289);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(28.0),
                  decoration: BoxDecoration(
                    color: _cardColor,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryPurple.withOpacity(0.05),
                        blurRadius: 40,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo Icon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _primaryPurple,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _primaryPurple.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title & Subtitle
                      const Text(
                        'Yallasafqa',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: "syne",
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'For students, by students',
                        style: TextStyle(fontSize: 14, color: _textSecondary),
                      ),
                      const SizedBox(height: 32),

                      // Toggle Switch
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: _bgColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            // These now pass true/false explicitly to control their look
                            Expanded(child: _buildTabButton('Login', true)),
                            Expanded(child: _buildTabButton('Sign Up', false)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Email Field
                      _buildInputLabel('University Email'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          hint: 'YourId@students.eui.edu.eg',
                          errorText: _emailError,
                          suffixIcon: Icon(
                            Icons.verified_outlined,
                            color: _successGreen,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      _buildInputLabel('Password'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _isPasswordObscured,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          errorText: _passwordError,
                          hint: '••••••••',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordObscured
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: _textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordObscured = !_isPasswordObscured;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Continue Button
                      Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(27),
                          gradient: LinearGradient(
                            colors: [
                              _primaryPurple,
                              const Color.fromARGB(255, 161, 2, 179),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryPurple.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(27),
                            ),
                          ),
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  setState(() {
                                    _emailError = null;
                                    _passwordError = null;
                                  });

                                  bool isValid = true;

                                  // 1. Basic Validation
                                  if (_emailController.text.trim().isEmpty) {
                                    _emailError = 'Please enter your email';
                                    isValid = false;
                                  }
                                  if (_passwordController.text.isEmpty) {
                                    _passwordError =
                                        'Please enter your password';
                                    isValid = false;
                                  }

                                  if (!isValid) {
                                    setState(() {}); // Trigger red borders
                                    return;
                                  }

                                  //  Start Loading
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  try {
                                    // Attempt Firebase Login
                                    UserCredential
                                    userCredential = await FirebaseAuth.instance
                                        .signInWithEmailAndPassword(
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text,
                                        );

                                    if (userCredential.user != null &&
                                        !userCredential.user!.emailVerified) {
                                      // If not verified, log them right back out and show an error
                                      await FirebaseAuth.instance.signOut();
                                      setState(() {
                                        _emailError =
                                            'Please verify your email before logging in.';
                                      });
                                      return;
                                    }

                                    // SUCCESS! Navigate to the Home Screen
                                    if (mounted) {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/store',
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Logged in successfully!',
                                          ),
                                        ),
                                      );
                                    }
                                  } on FirebaseAuthException catch (e) {
                                    // 5. Handle Login Errors safely
                                    setState(() {
                                      if (e.code == 'user-not-found' ||
                                          e.code == 'wrong-password' ||
                                          e.code == 'invalid-credential') {
                                        _passwordError =
                                            'Invalid email or password.';
                                      } else {
                                        _emailError = e.message;
                                      }
                                    });
                                  } catch (e) {
                                    print(
                                      "CRASH REASON: $e",
                                    ); // exactly what broke!
                                    setState(() {
                                      _emailError =
                                          'An error occurred. Please try again.';
                                    });
                                  } finally {
                                    // Stop the loading spinner
                                    if (mounted) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  }
                                },

                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Verified Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _successGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _successGreen.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              color: _successGreen,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'VERIFIED STUDENTS ONLY',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _successGreen,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'To ensure community safety, a valid .edu email\naddress is required for all accounts.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: _textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Footer Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: _textSecondary),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                          color: _primaryPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return InputDecoration(
      hintText: hint,
      errorText: errorText, // ADDED THIS
      hintStyle: TextStyle(color: _textSecondary.withOpacity(0.5)),
      filled: true,
      fillColor: _bgColor.withOpacity(0.5),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _primaryPurple.withOpacity(0.5)),
      ),
      // ADDED ERROR STYLES
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  Widget _buildTabButton(String title, bool isLoginTab) {
    // isLoginTab is passed in. "Login" is always true here, "Sign Up" is false.
    return GestureDetector(
      onTap: () {
        if (!isLoginTab) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignupScreen()),
          );
        }
      },
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: isLoginTab ? _primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isLoginTab ? Colors.white : _textSecondary,
              fontWeight: isLoginTab ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
