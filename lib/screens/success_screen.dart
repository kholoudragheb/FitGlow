import 'package:flutter/material.dart';
import 'dart:math' as math;

class SuccessScreen extends StatelessWidget {
  final String coachName;
  final String planName;
  
  const SuccessScreen({
    super.key,
    this.coachName = 'Coach',
    this.planName = 'Pro Mentorship',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Success Badge - Wavy/Scalloped Edge (matching Figma)
              CustomPaint(
                size: const Size(120, 120),
                painter: _ScallopedBadgePainter(),
                child: const SizedBox(
                  width: 120,
                  height: 120,
                  child: Center(
                    child: Icon(
                      Icons.check,
                      size: 50,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Title
              const Text(
                'Booking Confirmed!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                'You have successfully subscribed to\n$coachName.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              // Back to Home Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4FF00),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Back to home',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for the scalloped/wavy badge border (matching Figma design)
class _ScallopedBadgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.85;
    const scallops = 16;
    
    final path = Path();
    
    for (int i = 0; i < scallops; i++) {
      final startAngle = (i * 2 * math.pi) / scallops;
      final endAngle = ((i + 1) * 2 * math.pi) / scallops;
      final midAngle = (startAngle + endAngle) / 2;
      
      // Outer point
      final outerX = center.dx + outerRadius * math.cos(startAngle);
      final outerY = center.dy + outerRadius * math.sin(startAngle);
      
      // Inner point (scallop valley)
      final innerX = center.dx + innerRadius * math.cos(midAngle);
      final innerY = center.dy + innerRadius * math.sin(midAngle);
      
      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      
      // Create curve to inner point
      path.quadraticBezierTo(
        center.dx + (outerRadius * 0.92) * math.cos(midAngle - 0.1),
        center.dy + (outerRadius * 0.92) * math.sin(midAngle - 0.1),
        innerX,
        innerY,
      );
      
      // Create curve to next outer point
      final nextOuterX = center.dx + outerRadius * math.cos(endAngle);
      final nextOuterY = center.dy + outerRadius * math.sin(endAngle);
      
      path.quadraticBezierTo(
        center.dx + (outerRadius * 0.92) * math.cos(midAngle + 0.1),
        center.dy + (outerRadius * 0.92) * math.sin(midAngle + 0.1),
        nextOuterX,
        nextOuterY,
      );
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
