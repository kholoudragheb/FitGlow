import 'package:flutter/material.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  bool allowAll = true;
  bool newDirectMessages = true;
  bool groupMentions = false;
  bool workoutCompletions = true;
  bool missedWorkouts = true;
  bool personalBests = true;
  bool upcomingSessions = true;
  bool appUpdates = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notification Preferences',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildToggleItem(
            'Allow All Notifications',
            'Enable or disable all app notifications at once',
            allowAll,
            (val) => setState(() => allowAll = val),
            icon: Icons.notifications_none,
          ),
          const Divider(color: Color(0xFF2C2C2C), height: 32),
          _buildSectionHeader('Communication'),
          _buildToggleItem(
            'New Direct Messages',
            'Get notified when a client sends you a message',
            newDirectMessages,
            (val) => setState(() => newDirectMessages = val),
          ),
          _buildToggleItem(
            'Group Message Mentions',
            'Recieve alerts when you’re mentioned in a group',
            groupMentions,
            (val) => setState(() => groupMentions = val),
          ),
          const Divider(color: Color(0xFF2C2C2C), height: 32),
          _buildSectionHeader('Client Activity & Progress'),
          _buildToggleItem(
            'workout Completions',
            'When a client completes as assigned workout',
            workoutCompletions,
            (val) => setState(() => workoutCompletions = val),
          ),
          _buildToggleItem(
            'Missed Workouts',
            'If a client misses a schedule session',
            missedWorkouts,
            (val) => setState(() => missedWorkouts = val),
          ),
          _buildToggleItem(
            'Personal Bests',
            'when a client achieves a new personal record',
            personalBests,
            (val) => setState(() => personalBests = val),
          ),
          const Divider(color: Color(0xFF2C2C2C), height: 32),
          _buildSectionHeader('Scheduling & Reminders'),
          _buildToggleItem(
            'Upcoming Session Reminders',
            'Reminders for your upcoming client session',
            upcomingSessions,
            (val) => setState(() => upcomingSessions = val),
          ),
          const Divider(color: Color(0xFF2C2C2C), height: 32),
          _buildSectionHeader('App & System'),
          _buildToggleItem(
            'App Updates & News',
            'New features,announcements, and system updates',
            appUpdates,
            (val) => setState(() => appUpdates = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildToggleItem(String title, String subtitle, bool value, Function(bool) onChanged, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: const Color(0xFFD0FD3E), size: 24),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFFA09D9D),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFFD0FD3E),
            activeTrackColor: const Color(0xFFD0FD3E).withValues(alpha: 0.5),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFF2C2C2C),
          ),
        ],
      ),
    );
  }
}
