class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String? image;
  final String type; // 'chat', 'plan', 'system'
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.image,
    this.type = 'system',
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      image: json['image'],
      type: json['type'] ?? 'system',
      isRead: json['isRead'] ?? false,
    );
  }
}
