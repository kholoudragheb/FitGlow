import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fit_app/utils/store_styles.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

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
          'Security',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: StoreColors.textWhite,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildSecurityItem('Change Password', onTap: () {}),
            const Divider(color: Color(0xFF2C2C2C), height: 1),
            _buildSecurityItem('Two-Step Verification', onTap: () {}),
            const Divider(color: Color(0xFF2C2C2C), height: 1),
            _buildSecurityItem('Biometric Login', onTap: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityItem(String title, {required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 14),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: StoreColors.textWhite, size: 14),
      contentPadding: EdgeInsets.zero,
    );
  }
}
