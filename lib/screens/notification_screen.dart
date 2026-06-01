import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _service = NotificationService();
  late Future<List<NotificationModel>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _refreshNotifications();
  }

  void _refreshNotifications() {
    setState(() {
      _notificationsFuture = _service.getNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(AppConstants.iconBack,
                width: 16,
                height: 16,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Notification',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _refreshNotifications,
            icon: const Icon(Icons.refresh, color: Colors.white70),
          ),
        ],
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFFD4FF00)));
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final notifications = snapshot.data!;
          return _buildNotificationsList(notifications);
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshNotifications,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4FF00)),
              child: const Text('Retry', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              SvgPicture.asset(
                AppConstants.iconNotificationEmpty,
                width: 80,
                height: 80,
                colorFilter:
                    ColorFilter.mode(Colors.grey[700]!, BlendMode.srcIn),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Text(
                  'z',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationModel> notifications) {
    // Group notifications by relative date
    final Map<String, List<NotificationModel>> grouped = {};
    final now = DateTime.now();

    for (var n in notifications) {
      String key;
      if (n.timestamp.year == now.year &&
          n.timestamp.month == now.month &&
          n.timestamp.day == now.day) {
        key = 'Today';
      } else if (n.timestamp.year == now.year &&
          n.timestamp.month == now.month &&
          n.timestamp.day == now.day - 1) {
        key = 'Yesterday';
      } else {
        key = DateFormat.MMMMd().format(n.timestamp);
      }
      grouped.putIfAbsent(key, () => []).add(n);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        ...grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...entry.value.map((n) => _buildNotificationTile(n)),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildNotificationTile(NotificationModel n) {
    IconData icon;
    Color iconColor;

    switch (n.type) {
      case 'chat':
        icon = Icons.chat_bubble_outline;
        iconColor = const Color(0xFFD4FF00);
        break;
      case 'plan':
        icon = Icons.fitness_center;
        iconColor = Colors.orangeAccent;
        break;
      default:
        icon = Icons.notifications_none;
        iconColor = Colors.blueAccent;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      n.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      DateFormat.jm().format(n.timestamp),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  n.message,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
