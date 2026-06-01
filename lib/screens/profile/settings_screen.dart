import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fit_app/screens/profile/notification_settings_screen.dart';
import 'package:fit_app/screens/profile/language_settings_screen.dart';
import 'package:fit_app/screens/profile/security_screen.dart';
import 'package:fit_app/screens/profile/privacy_policy_screen.dart';
import 'package:fit_app/screens/profile/terms_conditions_screen.dart';
import 'package:fit_app/screens/profile/help_support_screen.dart';
import 'package:fit_app/screens/profile/about_app_screen.dart';
import 'package:fit_app/utils/store_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          'Settings',
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
            _buildSettingsItem(
              'lib/assets/images/profile/ic_notification_bell_green.svg',
              'Notifications',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()));
              },
            ),
            _buildDivider(),
            _buildSettingsItem(
              'lib/assets/images/profile/ic_help.svg',
              'Language',
              trailingText: 'English',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LanguageSettingsScreen()));
              },
            ),
            _buildDivider(),
            _buildSettingsItem(
              'lib/assets/images/profile/ic_chart.svg',
              'Security',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SecurityScreen()));
              },
            ),
             _buildDivider(),
            _buildSettingsItem(
              'lib/assets/images/profile/ic_help.svg',
              'Privacy Policy',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
              },
            ),
            _buildDivider(),
            _buildSettingsItem(
              'lib/assets/images/profile/ic_help.svg',
              'Terms & Conditions',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsConditionsScreen()));
              },
            ),
            _buildDivider(),
            _buildSettingsItem(
              'lib/assets/images/profile/ic_subscription.svg',
              'Help & Support',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportScreen()));
              },
            ),
            _buildDivider(),
             _buildSettingsItem(
              'lib/assets/images/profile/ic_help.svg',
              'About App',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutAppScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(String iconPath, String title, {String? trailingText, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: SvgPicture.asset(
        iconPath,
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(StoreColors.primary, BlendMode.srcIn),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: StoreColors.textWhite,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
              trailingText,
              style: const TextStyle(color: StoreColors.textGrey, fontSize: 12),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, color: StoreColors.textWhite, size: 14),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
    );
  }

  Widget _buildDivider() {
    return const Divider(color: Color(0xFF2C2C2C), height: 1);
  }
}
