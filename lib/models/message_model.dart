class MessageModel {
  final String id;
  final String? conversationId;
  final String senderId;
  final String content;
  final String messageType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isRead;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final String status; // sending, sent, delivered, read
  final String? attachment;
  final String? imageUrl;
  final String? fileUrl;
  final String? voiceUrl;
  final bool isDeleted;

  MessageModel({
    required this.id,
    this.conversationId,
    required this.senderId,
    required this.content,
    required this.messageType,
    required this.createdAt,
    required this.updatedAt,
    this.isRead = false,
    this.deliveredAt,
    this.readAt,
    this.status = 'sent',
    this.attachment,
    this.imageUrl,
    this.fileUrl,
    this.voiceUrl,
    this.isDeleted = false,
  });

  static String _extractId(dynamic field) {
    if (field == null) return '';
    if (field is String) return field;
    if (field is Map) return field['_id']?.toString() ?? field['id']?.toString() ?? '';
    return field.toString();
  }

  static String? _extractString(dynamic val) {
    if (val == null) return null;
    if (val is String) return val;
    if (val is Map) {
      return val['url']?.toString() ?? val['fileUrl']?.toString() ?? val['text']?.toString() ?? val['content']?.toString() ?? val.toString();
    }
    return val.toString();
  }

  static DateTime _parseDate(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is DateTime) return val;
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    if (val is String) {
      try {
        return DateTime.parse(val);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  factory MessageModel.fromJson(dynamic rawJson) {
    if (rawJson is! Map) {
      return MessageModel(
        id: _extractId(rawJson),
        senderId: '',
        content: rawJson?.toString() ?? '',
        messageType: 'text',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    final json = rawJson;
    bool read = json['isRead'] ?? false;
    bool deleted = json['isDeleted'] == true || json['isDeleted'] == 'true' || json['content'] == 'This message was deleted';
    String stat = _extractString(json['status']) ?? (read ? 'read' : 'sent');
    
    return MessageModel(
      id: _extractId(json['_id'] ?? json['id']),
      conversationId: json['conversationId'] != null ? _extractId(json['conversationId']) : (json['conversation'] != null ? _extractId(json['conversation']) : null),
      senderId: _extractId(json['senderId'] ?? json['sender']),
      content: _extractString(json['content'] ?? json['text']) ?? '',
      messageType: _extractString(json['messageType'] ?? json['type']) ?? 'text',
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt'] ?? json['createdAt']),
      isRead: read,
      deliveredAt: json['deliveredAt'] != null ? _parseDate(json['deliveredAt']) : null,
      readAt: json['readAt'] != null ? _parseDate(json['readAt']) : null,
      status: stat,
      attachment: _extractString(json['attachment']),
      imageUrl: _extractString(json['imageUrl']),
      fileUrl: _extractString(json['fileUrl']),
      voiceUrl: _extractString(json['voiceUrl']),
      isDeleted: deleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
      'messageType': messageType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isRead': isRead,
      'deliveredAt': deliveredAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'status': status,
      'attachment': attachment,
      'imageUrl': imageUrl,
      'fileUrl': fileUrl,
      'voiceUrl': voiceUrl,
      'isDeleted': isDeleted,
    };
  }
}

