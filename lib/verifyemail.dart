import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yalla_safqa/login.dart'; // Make sure this path is correct for your app

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = true;
  Timer? timer;

  // Your App Colors
  final Color _bgColor = const Color.fromARGB(255, 38, 2, 58);
  final Color _cardColor = const Color(0xFF1B1B28);
  final Color _primaryPurple = const Color(0xFF6E56FF);
  final Color _successGreen = const Color(0xFF00D289);
  final Color _textSecondary = const Color(0xFF8E8E9F);

  @override
  void initState() {
    super.initState();


    isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (!isEmailVerified) {
      // If not verified, start a timer to check every 3 seconds
      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel(); // ALWAYS cancel timers to prevent memory leaks!
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    // Call reload() to force Firebase to fetch the latest user data
    await FirebaseAuth.instance.currentUser?.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    });

    if (isEmailVerified) {
      timer?.cancel();
      
      // Wait 2 seconds so the user can see the "Success" animation
      await Future.delayed(const Duration(seconds: 2));
      
      // Sign them out so they start completely fresh on the Login screen
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

      // Prevent spamming the resend button
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
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(
                    color: (isEmailVerified ? _successGreen : _primaryPurple).withOpacity(0.05),
                    blurRadius: 40,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dynamic Icon (Mail -> Checkmark)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isEmailVerified ? _successGreen : _primaryPurple,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isEmailVerified ? _successGreen : _primaryPurple).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      isEmailVerified ? Icons.check_rounded : Icons.mark_email_unread_outlined,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Dynamic Title
                  Text(
                    isEmailVerified ? 'Verified!' : 'Check your mail',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: "syne",
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dynamic Subtitle
                  Text(
                    isEmailVerified
                        ? 'Routing you to login...'
                        : 'We just sent a verification link to your university email. Click the link to activate your Yallasafqa account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: _textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Only show these buttons if NOT verified yet
                  if (!isEmailVerified) ...[
                    const CircularProgressIndicator(
                      color: Color(0xFF6E56FF),
                    ),
                    const SizedBox(height: 32),
                    
                    // Resend Button
                    ElevatedButton(
                      onPressed: canResendEmail ? sendVerificationEmail : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                          side: BorderSide(color: _primaryPurple.withOpacity(0.5)),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(
                        canResendEmail ? 'Resend Email' : 'Wait 10s to resend...',
                        style: TextStyle(color: canResendEmail ? Colors.white : _textSecondary),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cancel Button
                    TextButton(
                      onPressed: () async {
                        // If they cancel, sign them out and send to login
                        timer?.cancel();
                        await FirebaseAuth.instance.signOut();
                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        }
                      },
                      child: Text('Cancel', style: TextStyle(color: _textSecondary)),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}