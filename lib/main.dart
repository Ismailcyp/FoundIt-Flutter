import 'package:flutter/material.dart';
import 'package:FoundIT/firebase_options.dart';
import 'package:FoundIT/splashscreen.dart'; 
import 'package:FoundIT/login.dart';
import 'package:FoundIT/signin.dart'; 
import 'package:FoundIT/store.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Myapp());
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (snapshot.hasData) {
            if (snapshot.data!.emailVerified) {
              return const Mymain(); 
            } else {
              FirebaseAuth.instance.signOut();
              return const LoginScreen();
            }
          }

          return const SplashScreen(); 
        },
      ),
      
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(), 
        '/store': (context) => const Mymain(),
      },
    );
  }
}