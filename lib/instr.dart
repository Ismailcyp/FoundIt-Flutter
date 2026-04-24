import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:FoundIT/intro_screens/intro_page1.dart';
import 'package:FoundIT/intro_screens/intro_page2.dart';
import 'package:FoundIT/intro_screens/intro_page3.dart';
import 'package:FoundIT/login.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _controller = PageController();

  bool onLastPage = false;

  @override
  void dispose() {
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
                onLastPage = (index == 2);
              });
            },
            children: const [IntroPage1(), IntroPage2(), IntroPage3()],
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: Image.asset(
                "assets/img/whitec.png",
                fit: BoxFit
                    .fill,
              ),
            ),
          ),

          Container(
            alignment: const Alignment(0, 0.75),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
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

                SmoothPageIndicator(controller: _controller, count: 3),

                onLastPage
                    ? GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
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