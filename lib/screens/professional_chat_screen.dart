import 'package:fit_app/core/constants.dart';
import 'package:fit_app/screens/home_screen.dart'; // To navigate back home
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfessionalChatScreen extends StatefulWidget {
  const ProfessionalChatScreen({super.key});

  @override
  State<ProfessionalChatScreen> createState() => _ProfessionalChatScreenState();
}

class _ProfessionalChatScreenState extends State<ProfessionalChatScreen> {
  // ... (existing variable declaration)
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'isMe': false,
      'text': 'Hello Amira! Welcome to the Pro Mentorship program. I\'m excited to work with you!',
      'time': '10:00 AM',
    },
    {
      'isMe': true,
      'text': 'Hi Alex! Thank you so much. I\'m ready to get started.',
      'time': '10:05 AM',
    },
     {
      'isMe': false,
      'text': 'Great! I\'ve reviewed your profile. Let\'s schedule our first video call for tomorrow. Does 5 PM work?',
      'time': '10:06 AM',
    },
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'isMe': true,
        'text': _messageController.text.trim(),
        'time': 'Now',
      });
    });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(AppConstants.iconBack, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
          onPressed: () {
            // Return to Home, removing all previous routes to reset the stack
             Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
        title: Row(
          children: [
            Stack(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('lib/assets/images/coaches/coach_1.jpg'),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Alex Johnson", style: AppConstants.headlineMedium.copyWith(fontSize: 16)),
                Text("Active Now", style: AppConstants.bodyMedium.copyWith(color: AppConstants.primaryColor, fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: SvgPicture.asset(AppConstants.iconVideo, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)), onPressed: () {}),
          IconButton(icon: SvgPicture.asset(AppConstants.iconPhone, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: AppConstants.defaultPadding,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(
                  isMe: message['isMe'],
                  text: message['text'],
                  time: message['time'],
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({required bool isMe, required String text, required String time}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppConstants.surfaceColor : AppConstants.primaryColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: isMe
                  ? AppConstants.bodyLarge.copyWith(color: Colors.white)
                  : AppConstants.bodyLarge.copyWith(color: Colors.black),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: isMe ? Colors.white54 : Colors.black54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppConstants.surfaceColor,
      child: Row(
        children: [
          IconButton(icon: SvgPicture.asset(AppConstants.iconAdd, colorFilter: const ColorFilter.mode(AppConstants.primaryColor, BlendMode.srcIn)), onPressed: () {}),
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: TextStyle(color: Colors.grey.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.black,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppConstants.primaryColor,
            child: IconButton(
              icon: SvgPicture.asset(AppConstants.iconSend, colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn), width: 20, height: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
