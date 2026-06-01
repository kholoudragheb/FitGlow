import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fit_app/utils/store_styles.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _workoutReminders = true;
  bool _programUpdates = false;
  bool _newOfferings = true;

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
          'Notifications',
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
            _buildSwitchItem('Workout Reminders', _workoutReminders, (val) => setState(() => _workoutReminders = val)),
            _buildDivider(),
            _buildSwitchItem('Program Updates', _programUpdates, (val) => setState(() => _programUpdates = val)),
            _buildDivider(),
            _buildSwitchItem('New Offerings', _newOfferings, (val) => setState(() => _newOfferings = val)),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem(String title, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: StoreColors.textWhite,
        ),
      ),
      trailing: CupertinoSwitch(
        value: value,
        activeTrackColor: StoreColors.primary,
        onChanged: onChanged,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
    );
  }

  Widget _buildDivider() {
    return const Divider(color: Color(0xFF2C2C2C), height: 1);
  }
}
