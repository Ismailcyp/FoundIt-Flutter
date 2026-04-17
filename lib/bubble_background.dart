import 'dart:math';
import 'package:flutter/material.dart';

class BubbleBackground extends StatefulWidget {
  const BubbleBackground({super.key});

  @override
  State<BubbleBackground> createState() => _BubbleBackgroundState();
}

class _BubbleBackgroundState extends State<BubbleBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Bubble> _bubbles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // A 15-second loop keeps the movement very slow and relaxing
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // Generate 15 soft bubbles
    for (int i = 0; i < 15; i++) {
      _bubbles.add(Bubble(
        startX: _random.nextDouble(), // Relative position (0.0 to 1.0)
        startY: _random.nextDouble(),
        radius: _random.nextDouble() * 60 + 30, // Sizes between 30 and 90
        speed: _random.nextDouble() * 0.5 + 0.5, // Speeds between 0.5 and 1.0
        // Mix of your primary purple and a deeper magenta
        color: _random.nextBool() 
            ? const Color.fromARGB(255, 134, 4, 210).withOpacity(0.15) 
            : const Color.fromARGB(255, 161, 2, 179).withOpacity(0.15),
      ));
    }
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
        return SizedBox.expand(
          child: CustomPaint(
            painter: BubblePainter(_bubbles, _controller.value),
          ),
        );
      },
    );
  }
}

class Bubble {
  final double startX;
  final double startY;
  final double radius;
  final double speed;
  final Color color;

  Bubble({
    required this.startX,
    required this.startY,
    required this.radius,
    required this.speed,
    required this.color,
  });
}

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final double animationValue;

  BubblePainter(this.bubbles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // 1. Solid Original Background Color
    final paint = Paint()..color = const Color(0xFF2A0845);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // 2. Setup the "Glow" effect for the bubbles
    final bubblePaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20); // Softens the edges

    // 3. Draw each bubble
    for (var b in bubbles) {
      // Calculate continuous upward movement with wrapping
      double rawY = b.startY + (animationValue * b.speed);
      double currentY = size.height - ((rawY % 1.0) * (size.height + b.radius * 2)) + b.radius;
      
      // Add a very slight horizontal sway
      double currentX = (b.startX * size.width) + sin(animationValue * pi * 2 * b.speed) * 30;

      bubblePaint.color = b.color;
      canvas.drawCircle(Offset(currentX, currentY), b.radius, bubblePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}