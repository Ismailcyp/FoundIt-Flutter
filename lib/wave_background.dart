import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedWaveBackground extends StatefulWidget {
  const AnimatedWaveBackground({super.key});

  @override
  State<AnimatedWaveBackground> createState() => _AnimatedWaveBackgroundState();
}

class _AnimatedWaveBackgroundState extends State<AnimatedWaveBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Sped up slightly to 8 seconds so you can easily verify it's moving
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8), 
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // FIX 1: Force the canvas to stretch across the entire screen
        return SizedBox.expand(
          child: CustomPaint(
            painter: WavePainter(_controller.value),
          ),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    // 1. Base background (Slightly lighter deep purple so it doesn't crush to black)
    final paint = Paint()..color = const Color(0xFF2A0845);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // 2. Wave 1: Primary Purple (High Opacity to guarantee visibility)
    _drawWave(canvas, size,
        color: const Color.fromARGB(255, 49, 2, 38).withOpacity(0.4), // Cranked up to 40%
        amplitude: 50,
        frequency: 1.2,
        offsetY: size.height * 0.15,
        speed: animationValue * 2 * pi);

    // 3. Wave 2: A secondary magenta/purple for depth
    _drawWave(canvas, size,
        color: const Color.fromARGB(255, 133, 43, 150).withOpacity(0.3), // Cranked up to 30%
        amplitude: 60, 
        frequency: 1.5, 
        offsetY: size.height * 0.4,
        speed: (animationValue * 2 * pi) + pi / 2); 

    // 4. Wave 3: Dark overlay at the bottom to ground the cards
    _drawWave(canvas, size,
        color: const Color(0xFF1B1B28).withOpacity(0.7),
        amplitude: 30,
        frequency: 2.0,
        offsetY: size.height * 0.7,
        speed: (animationValue * 2 * pi) - pi / 3);
  }

  void _drawWave(Canvas canvas, Size size, {
    required Color color,
    required double amplitude,
    required double frequency,
    required double offsetY,
    required double speed,
  }) {
    final path = Path();
    final paint = Paint()..color = color..style = PaintingStyle.fill;

    path.moveTo(0, size.height);
    path.lineTo(0, offsetY);

    for (double x = 0; x <= size.width; x++) {
      double y = amplitude * sin((x / size.width) * frequency * 2 * pi + speed) + offsetY;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}