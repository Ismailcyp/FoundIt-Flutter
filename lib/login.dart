import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:FoundIT/signin.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordObscured = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;

  final Color _primaryColor = const Color(0xFFB5E575);
  final Color _textColor = const Color(0xFF1E1E1E);
  final Color _subtitleColor = const Color(0xFF8E8E8E);
  final Color _inputFillColor = const Color(0xFFF5F5F5);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront_outlined, color: Colors.green[800], size: 32),
                  const SizedBox(width: 8),
                  Text(
                    'FoundIt',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              Text(
                'Welcome to FoundIt',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign up or login below to manage your\nproject, task, and productivity',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: _subtitleColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(child: _buildTab(title: 'Login', isActive: true)),
                  Expanded(child: _buildTab(title: 'Sign Up', isActive: false)),
                ],
              ),
              const SizedBox(height: 30),

              _buildSocialButton(icon: Icons.apple, label: 'Login with Apple', isApple: true),
              const SizedBox(height: 12),
              _buildSocialButton(icon: Icons.g_mobiledata, label: 'Login with Google', isApple: false),
              const SizedBox(height: 24),

              Text(
                'or continue with email',
                style: TextStyle(color: _subtitleColor, fontSize: 13),
              ),
              const SizedBox(height: 24),

              _buildTextField(
                controller: _emailController,
                icon: Icons.email_outlined,
                hint: 'Enter your email',
                errorText: _emailError,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _passwordController,
                icon: Icons.lock_outline,
                hint: 'Enter your password',
                errorText: _passwordError,
                obscureText: _isPasswordObscured,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: _subtitleColor,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordObscured = !_isPasswordObscured;
                    });
                  },
                ),
              ),

              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(color: _subtitleColor, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.green[900],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(color: _subtitleColor, fontSize: 12, height: 1.5),
                  children: [
                    const TextSpan(text: 'By logging in, you agree to our '),
                    TextSpan(
                      text: 'Terms of service',
                      style: TextStyle(color: Colors.green[800], decoration: TextDecoration.underline),
                    ),
                    const TextSpan(text: '\nand '),
                    TextSpan(
                      text: 'Privacy policy',
                      style: TextStyle(color: Colors.green[800], decoration: TextDecoration.underline),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    bool isValid = true;

    if (_emailController.text.trim().isEmpty) {
      _emailError = 'Please enter your email';
      isValid = false;
    }
    if (_passwordController.text.isEmpty) {
      _passwordError = 'Please enter your password';
      isValid = false;
    }

    if (!isValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await FirebaseAuth.instance.signOut();
        setState(() {
          _emailError = 'Please verify your email before logging in.';
        });
        return;
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/store');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found' ||
            e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          _passwordError = 'Invalid email or password.';
        } else {
          _emailError = e.message;
        }
      });
    } catch (e) {
      setState(() {
        _emailError = 'An error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  Widget _buildTab({required String title, required bool isActive}) {
    return GestureDetector(
      onTap: () {
        if (title == 'Sign Up') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignupScreen()),
          );
        }
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? Colors.green[800] : _subtitleColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 2,
            color: isActive ? Colors.green[800] : Colors.transparent,
          ),
          Container(height: 1, color: Colors.grey[300]),
        ],
      ),
    );
  }

  Widget _buildSocialButton({required IconData icon, required String label, required bool isApple}) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: _inputFillColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isApple ? Colors.black : Colors.red, size: 28),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: _textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    String? errorText,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: _textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _subtitleColor, fontSize: 14),
        errorText: errorText,
        prefixIcon: Icon(icon, color: _subtitleColor),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: _inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade800, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }
}