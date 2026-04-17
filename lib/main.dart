import 'package:flutter/material.dart';
import 'package:yalla_safqa/firebase_options.dart';
import 'package:yalla_safqa/splashscreen.dart'; 
import 'package:yalla_safqa/login.dart';
import 'package:yalla_safqa/signin.dart'; 
import 'package:yalla_safqa/store.dart';
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
              return const Mymain(); // Route directly to the Store!
            } else {
              // If they aren't verified, log them out and force them to the login page
              FirebaseAuth.instance.signOut();
              return const LoginScreen();
            }
          }

          // 3. If there is no user logged in, start the normal flow
          return const SplashScreen(); 
        },
      ),
      
      // Keep your named routes for easy navigation elsewhere in the app
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(), 
        '/store': (context) => const Mymain(),
      },
    );
  }
}