import 'dart:math';
import 'package:flutter/material.dart';

class BubblesPainter extends CustomPainter {
  final int numberOfBubbles;
  final double maxBubbleSize;
  final Color color;

  BubblesPainter({
    required this.numberOfBubbles,
    required this.maxBubbleSize,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random();
    final paint = Paint()..color = color.withOpacity(0.3);

    for (int i = 0; i < numberOfBubbles; i++) {
      final radius = random.nextDouble() * maxBubbleSize;
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
