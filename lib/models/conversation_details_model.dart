import 'conversation_model.dart';
import 'message_model.dart';

class ConversationDetailsModel {
  final String id;
  final List<ParticipantModel> participants;
  final List<MessageModel> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  ConversationDetailsModel({
    required this.id,
    required this.participants,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

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

  factory ConversationDetailsModel.fromJson(Map<String, dynamic> json) {
    // Some APIs wrap the object in a 'conversation' or 'data' key
    final Map<String, dynamic> convData = json['conversation'] ?? json['data'] ?? json;
    
    List<ParticipantModel> parsedParticipants = [];
    if (convData['participants'] is List) {
      parsedParticipants = (convData['participants'] as List).map((p) => ParticipantModel.fromJson(p)).toList();
    } else if (convData['otherUser'] != null) {
      parsedParticipants = [ParticipantModel.fromJson(convData['otherUser'])];
    } else {
      if (convData['coachId'] != null) parsedParticipants.add(ParticipantModel.fromJson(convData['coachId']));
      if (convData['customerId'] != null) parsedParticipants.add(ParticipantModel.fromJson(convData['customerId']));
    }

    List<MessageModel> parsedMessages = [];
    if (convData['messages'] is List) {
      parsedMessages = (convData['messages'] as List).map((m) => MessageModel.fromJson(m)).where((m) => !m.isDeleted).toList();
    }

    return ConversationDetailsModel(
      id: convData['_id'] ?? convData['id'] ?? '',
      participants: parsedParticipants,
      messages: parsedMessages,
      createdAt: _parseDate(convData['createdAt']),
      updatedAt: _parseDate(convData['updatedAt'] ?? convData['createdAt']),
    );
  }
}
