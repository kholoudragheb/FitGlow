import 'package:fit_app/core/constants.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class BookingConfirmedScreen extends StatelessWidget {
  final String coachName;
  const BookingConfirmedScreen({super.key, required this.coachName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      // No App Bar needed or just a transparent one if necessary for safe area
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Verification icon (Assuming FontAwesome or Cupertino or Material verified badge is closest without specific SVG lookup)
                  // The Figma shows a jagged circle with a check. Icons.verified matches this best in standard library.
                  const Icon(
                    Icons.verified,
                    size: 100,
                    color: Color(0xFFF0F0F0),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Booking Confirmed!",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: Color(0xFFF0F0F0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "You have successfully subscribed to $coachName.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Color(0xFF5C5C5C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Bottom CTA
            Positioned(
              bottom: 32, // Safe area distance + padding
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  // Navigate back to home and clear stack
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Back to home",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF0C0C0C),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
