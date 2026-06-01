class UnreadCountModel {
  final int unreadCount;

  UnreadCountModel({required this.unreadCount});

  factory UnreadCountModel.fromJson(Map<String, dynamic> json) {
    return UnreadCountModel(
      // Handling different possible backend keys as per user spec
      unreadCount: json['unreadCount'] ?? 
                   json['totalUnreadMessages'] ?? 
                   json['count'] ?? 
                   0,
    );
  }
}
