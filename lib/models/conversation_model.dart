class ParticipantModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final String role;

  ParticipantModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    required this.role,
  });

  factory ParticipantModel.fromJson(dynamic json) {
    if (json is String) {
      return ParticipantModel(
        id: json,
        firstName: 'User',
        lastName: '',
        role: 'User',
      );
    }
    
    if (json is Map<String, dynamic>) {
      return ParticipantModel(
        id: json['_id'] ?? json['id'] ?? '',
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        profileImage: json['profileImage'],
        role: json['role'] ?? '',
      );
    }

    return ParticipantModel(id: '', firstName: 'User', lastName: '', role: 'User');
  }

  String get fullName => '$firstName $lastName';
}

class MessagePreview {
  final String text;
  final String senderId;
  final String createdAt;

  MessagePreview({
    required this.text,
    required this.senderId,
    required this.createdAt,
  });

  static String _extractId(dynamic field) {
    if (field == null) return '';
    if (field is String) return field;
    if (field is Map) return field['_id']?.toString() ?? field['id']?.toString() ?? '';
    return field.toString();
  }

  factory MessagePreview.fromJson(dynamic json) {
    if (json is String) {
      return MessagePreview(
        text: json,
        senderId: '',
        createdAt: '',
      );
    }
    
    if (json is Map<String, dynamic>) {
      return MessagePreview(
        text: json['text'] ?? json['content'] ?? '',
        senderId: _extractId(json['senderId'] ?? json['sender']),
        createdAt: json['createdAt'] ?? '',
      );
    }

    return MessagePreview(text: '', senderId: '', createdAt: '');
  }
}

class ConversationModel {
  final String id;
  final List<ParticipantModel> participants;
  final MessagePreview? lastMessage;
  final String? lastMessageTime;
  final int unreadCount;
  final String createdAt;
  final String updatedAt;

  ConversationModel({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageTime,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    List<ParticipantModel> parsedParts = [];
    if (json['participants'] is List) {
      parsedParts = (json['participants'] as List).map((p) => ParticipantModel.fromJson(p)).toList();
    } else if (json['otherUser'] != null) {
      parsedParts = [ParticipantModel.fromJson(json['otherUser'])];
    } else {
      if (json['coachId'] != null) parsedParts.add(ParticipantModel.fromJson(json['coachId']));
      if (json['customerId'] != null) parsedParts.add(ParticipantModel.fromJson(json['customerId']));
    }

    return ConversationModel(
      id: json['_id'] ?? json['id'] ?? '',
      participants: parsedParts,
      lastMessage: json['lastMessage'] != null
          ? (json['lastMessage'] is Map<String, dynamic> 
              ? MessagePreview.fromJson(json['lastMessage']) 
              : MessagePreview(
                  text: json['lastMessage'].toString(), 
                  senderId: json['lastMessageSenderId']?.toString() ?? '', 
                  createdAt: json['lastMessageAt']?.toString() ?? json['updatedAt']?.toString() ?? ''
                ))
          : null,
      lastMessageTime: json['lastMessageTime'] ?? json['lastMessageAt'] ?? json['updatedAt'],
      unreadCount: json['unreadCount'] ?? json['customerUnreadCount'] ?? json['coachUnreadCount'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  ParticipantModel? getOtherParticipant(String currentUserId) {
    try {
      return participants.firstWhere((p) => p.id != currentUserId);
    } catch (_) {
      return participants.isNotEmpty ? participants.first : null;
    }
  }
}
