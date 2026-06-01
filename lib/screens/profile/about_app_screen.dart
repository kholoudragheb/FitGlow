import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fit_app/utils/store_styles.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoreColors.background,
      appBar: AppBar(
        backgroundColor: StoreColors.background,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'lib/assets/images/profile/ic_back_arrow_square.svg',
            width: 32,
            height: 32,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'About App',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: StoreColors.textWhite,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: StoreColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  'FG',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Fit Glow',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: StoreColors.textGrey, fontSize: 14, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 48),
            const Text(
              'Follow us on social media',
              style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon(Icons.facebook),
                const SizedBox(width: 16),
                _buildSocialIcon(Icons.camera_alt),
                const SizedBox(width: 16),
                _buildSocialIcon(Icons.telegram),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F272D),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
