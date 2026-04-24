import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:FoundIT/login.dart'; 

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = true;
  Timer? timer;

  final Color _primaryColor = const Color(0xFFB5E575); 
  final Color _textColor = const Color(0xFF1E1E1E);
  final Color _subtitleColor = const Color(0xFF8E8E8E);
  final Color _inputFillColor = const Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (!isEmailVerified) {
      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel(); 
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    });

    if (isEmailVerified) {
      timer?.cancel();
      
      await Future.delayed(const Duration(seconds: 2));
      
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 10));
      if (mounted) setState(() => canResendEmail = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.storefront_outlined, color: Colors.green[800], size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'FoundIt',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isEmailVerified ? Colors.green[600] : _inputFillColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isEmailVerified ? Icons.check_rounded : Icons.mark_email_unread_outlined,
                    color: isEmailVerified ? Colors.white : Colors.green[800],
                    size: 48,
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  isEmailVerified ? 'Verified!' : 'Check your mail',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  isEmailVerified
                      ? 'Routing you to login...'
                      : 'We just sent a verification link to your email. Click the link to activate your FoundIt account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: _subtitleColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                if (!isEmailVerified) ...[
                  const CircularProgressIndicator(
                    color: Color(0xFFB5E575), 
                  ),
                  const SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: canResendEmail ? sendVerificationEmail : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        canResendEmail ? 'Resend Email' : 'Wait 10s to resend...',
                        style: TextStyle(
                          color: canResendEmail ? Colors.green[900] : Colors.green[900]?.withOpacity(0.5),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () async {
                      timer?.cancel();
                      await FirebaseAuth.instance.signOut();
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      }
                    },
                    child: Text(
                      'Cancel and return to login',
                      style: TextStyle(
                        color: _subtitleColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}