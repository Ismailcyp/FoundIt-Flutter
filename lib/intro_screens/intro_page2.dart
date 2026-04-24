import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; 

class IntroPage2 extends StatelessWidget {
  const IntroPage2({super.key});

  @override
  Widget build(BuildContext context) {
 return Container(
        width: double.infinity,
        height: double.infinity,
      color: const Color.fromARGB(255, 1, 37, 48),
        // decoration: const BoxDecoration(
        //   gradient: LinearGradient(
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter,
        //     colors: [
        //       Color.fromRGBO(22, 15, 35, 100),
        //       Color.fromRGBO(86, 59, 137, 100)
        //     ],
        //   ),
        // ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.only(left: 35),
            child: const Text(
              "Message sellers directly. No middlemen, no delays—just simple and secure conversations. ",
              style: TextStyle(
                color: Colors.white, 
                fontSize: 19, 
                fontFamily: "syne"
              ),
            ),
          ),
          const SizedBox(height: 13),
          
          Lottie.asset(
            "assets/vid/chat.json",
            width: 350,   
            height: 350,  
            fit: BoxFit.contain,
            repeat: true, 
          )
        ],
      ),
    );
  }
}
