import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart'; 

class IntroPage1 extends StatelessWidget {
  const IntroPage1({super.key});

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
        //       const Color.fromARGB(255, 38, 2, 58),
        //     ],
        //   ),
        // ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
             padding: EdgeInsets.only(left: 35),
            child: const Text(
              "Explore items listed",
              style: TextStyle(
                color: Colors.white, 
                fontSize:19, 
                fontFamily: "syne"
              ),
            ),
          ),
          const SizedBox(height: 13),
          
          // 2. Replace Image.asset with Lottie.asset
          Lottie.asset(
            "assets/vid/search.json",
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