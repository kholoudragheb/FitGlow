import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fit_app/utils/store_styles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: StoreColors.textWhite,
          ),
        ),
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Text(
          'This Privacy Policy describes how your personal information is collected, used, and shared when you visit or make a purchase from the App.\n\n'
          '1. Information collection\n'
          '2. Use of information\n'
          '3. Sharing information\n'
          '4. Your choices\n'
          '...',
          style: TextStyle(color: StoreColors.textGrey, fontFamily: 'Poppins', fontSize: 14, height: 1.6),
        ),
      ),
    );
  }
}
