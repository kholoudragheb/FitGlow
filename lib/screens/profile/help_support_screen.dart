import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fit_app/utils/store_styles.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
          'Help & Support',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: StoreColors.textWhite,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
             _buildContactItem(Icons.email_outlined, 'Email', 'support@fitglow.com'),
             const Divider(color: Color(0xFF2C2C2C), height: 1),
             _buildContactItem(Icons.phone_outlined, 'Phone', '+1 234 567 890'),
             const Divider(color: Color(0xFF2C2C2C), height: 1),
             _buildContactItem(Icons.chat_bubble_outline, 'Live Chat', 'Start Conversation'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: StoreColors.primary),
      title: Text(title, style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 14)),
      trailing: Text(value, style: const TextStyle(color: StoreColors.textGrey, fontSize: 12)),
      contentPadding: EdgeInsets.zero,
    );
  }
}
