import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CoachNotificationScreen extends StatelessWidget {
  const CoachNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF2F2E2E)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    ),
                  ),
                  const Text(
                    'Notification',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF0F0F0),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/empty-notifications');
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF2F2E2E)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset(
                          'lib/assets/images/coaches/8aab6e28074ef714257effb96ffc43ab795109eb.svg',
                          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Notification List
              Expanded(
                child: ListView(
                  children: [
                    _buildNotificationItem(
                      'Lily Morgan',
                      ' has subscribed to you',
                      '20:50',
                      'lib/assets/images/coaches/d973b17b466355ffd7ff2084d3977dcc86ddbc11.png',
                      isUnread: true,
                    ),
                    _buildNotificationItem(
                      'Denis Satz',
                      ' sent a request to change the time',
                      '19:10',
                      'lib/assets/images/coaches/f23eb893348f59a0eef3df0739393d997b419cfd.png',
                      isUnread: true,
                    ),
                    _buildNotificationItem(
                      'Chloe Phillips',
                      ' has finished training',
                      '12:06',
                      'lib/assets/images/coaches/966bdcc20de9d1146da18068833210d399cd593e.png',
                      isUnread: false, // Explicitly marked read in design
                    ),
                    _buildNotificationItem(
                      'Daniel Cooper',
                      ' has subscribed to you',
                      '19:43',
                      'lib/assets/images/coaches/69e2df8fffaab380274c77955b489b4a99200855.png',
                      isUnread: false,
                    ),
                    _buildNotificationItem(
                      'Denis Satz',
                      ' has subscribed to you',
                      '16:15',
                      'lib/assets/images/coaches/f23eb893348f59a0eef3df0739393d997b419cfd.png',
                      isUnread: false,
                    ),
                    _buildNotificationItem(
                      'Victoria James',
                      ' has subscribed to you',
                      '13:16',
                      'lib/assets/images/coaches/d495770d0267cedae5b16251917058b823da7c94.png',
                      isUnread: false,
                    ),
                    _buildNotificationItem(
                      'Samuel Bennett',
                      ' has subscribed to you',
                      '17:01',
                      'lib/assets/images/coaches/37042173fddbe9ba42957f586917c78c17fef829.png',
                      isUnread: false,
                    ),
                    _buildNotificationItem(
                      'Christopher Hayes',
                      ' has subscribed to you',
                      '8:45',
                      'lib/assets/images/coaches/74189efea5cc76457b9582b312e73d0474d12e5d.png',
                      isUnread: false,
                    ),
                     _buildNotificationItem(
                      'Michael Morgan',
                      ' has subscribed to you',
                      '20:35',
                      'lib/assets/images/coaches/c9a6d908e4a2cbaa065a51808d9c52ce07e3a747.png',
                      isUnread: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String name, String action, String time, String imagePath, {bool isUnread = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: name,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFBEBBBB), 
                        ),
                      ),
                      TextSpan(
                        text: action,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13, 
                          fontWeight: FontWeight.w400,
                          color: Colors.white, 
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      time,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Color(0xFFBEBBBB),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD0FD3E),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Color(0xFF2F2E2E), height: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
