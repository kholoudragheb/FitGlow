import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fit_app/utils/store_styles.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _selectedLanguage = 'English';

  final List<String> _languages = ['English', 'Arabic', 'French', 'German', 'Spanish'];

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
          'Language',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: StoreColors.textWhite,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20.0),
        itemCount: _languages.length,
        separatorBuilder: (context, index) => _buildDivider(),
        itemBuilder: (context, index) {
          final lang = _languages[index];
          return ListTile(
            onTap: () => setState(() => _selectedLanguage = lang),
            title: Text(
              lang,
              style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
            ),
            trailing: _selectedLanguage == lang
                ? const Icon(Icons.check, color: StoreColors.primary)
                : null,
            contentPadding: EdgeInsets.zero,
          );
        },
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(color: Color(0xFF2C2C2C), height: 1);
  }
}
