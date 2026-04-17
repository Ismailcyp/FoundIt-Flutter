import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:yalla_safqa/intro_screens/intro_page1.dart';
import 'package:yalla_safqa/intro_screens/intro_page2.dart';
import 'package:yalla_safqa/intro_screens/intro_page3.dart';
// Important: Make sure to import your main store or login page here!
import 'package:yalla_safqa/login.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  // Keep track of page we are in
  final PageController _controller = PageController();

  // Keep track of if we are on last page or not
  bool onLastPage = false;

  @override
  void dispose() {
    // It is best practice to dispose of controllers to prevent memory leaks
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                // FIX 1: Removed the curly braces
                onLastPage = (index == 2);
              });
            },
            children: const [IntroPage1(), IntroPage2(), IntroPage3()],
          ),

          Positioned.fill(
            // IgnorePointer ensures the image doesn't block the user
            // from swiping the screen underneath it.
            child: IgnorePointer(
              child: Image.asset(
                "assets/img/whitec.png",
                fit: BoxFit
                    .fill, // Stretches the image to perfectly hit all 4 corners
              ),
            ),
          ),

          Container(
            alignment: const Alignment(0, 0.75),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // SKIP BUTTON
                GestureDetector(
                  onTap: () {
                    _controller.jumpToPage(2);
                  },
                  child: const Text(
                    "skip",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: "syne",
                    ),
                  ),
                ),

                // DOT INDICATOR
                SmoothPageIndicator(controller: _controller, count: 3),

                // NEXT / GET STARTED BUTTON
                onLastPage
                    ? GestureDetector(
                        onTap: () {
                          // FIX 2: Navigate away from the onboarding screen to the main app
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              // Replace FoodStoreApp() with whatever your home screen class is named
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "start!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontFamily: "syne",
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeIn,
                          );
                        },
                        child: const Text(
                          "next",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontFamily: "syne",
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
