import 'dart:convert';
import 'dart:io';
import '../lib/models/conversation_model.dart';
import '../lib/models/message_model.dart';
import '../lib/models/conversation_details_model.dart';

void main() {
  final convsJson = jsonDecode('[{"_id":"6a069cb0668cf282b93545c3","otherUser":{"_id":"6a069c8e668cf282b93545bb","firstName":"Trial","lastName":"Coach"},"lastMessage":"Check your nutrition plan for today.","lastMessageAt":"2026-05-15T04:10:44.057Z","unreadCount":2,"isCoach":false}]');
  
  print("Testing ConversationModel.fromJson...");
  try {
    final convs = (convsJson as List).map((c) => ConversationModel.fromJson(c)).toList();
    print("Success! Convs count: ${convs.length}, lastMessage text: ${convs[0].lastMessage?.text}");
  } catch (e, st) {
    print("Error in ConversationModel: $e\n$st");
  }

  final detailsJson = jsonDecode('{"_id":"6a069cb0668cf282b93545c3","coachId":{"_id":"6a069c8e668cf282b93545bb","email":"trial_coach_100@test.com","firstName":"Trial","lastName":"Coach"},"customerId":{"_id":"6a069c70668cf282b93545b8","email":"trial_client_100@test.com","firstName":"Trial","lastName":"Client"},"coachUnreadCount":0,"customerUnreadCount":2,"isActive":true,"createdAt":"2026-05-15T04:10:24.623Z","updatedAt":"2026-05-16T00:13:32.886Z","__v":0,"lastMessage":"Check your nutrition plan for today.","lastMessageAt":"2026-05-15T04:10:44.057Z","lastMessageSenderId":"6a069c8e668cf282b93545bb","coachLastSeenAt":"2026-05-16T00:13:32.885Z"}');

  print("\nTesting ConversationDetailsModel.fromJson...");
  try {
    final details = ConversationDetailsModel.fromJson(detailsJson);
    print("Success! Details id: ${details.id}, participants count: ${details.participants.length}");
  } catch (e, st) {
    print("Error in ConversationDetailsModel: $e\n$st");
  }

  final messagesJson = jsonDecode('[{"_id":"6a069cb0668cf282b93545c6","conversationId":"6a069cb0668cf282b93545c3","senderId":{"_id":"6a069c8e668cf282b93545bb","firstName":"Trial","lastName":"Coach"},"content":"Hello Client! I am your new coach. Welcome aboard!","messageType":"text","isRead":false,"isDelivered":false,"isDeleted":false,"createdAt":"2026-05-15T04:10:24.681Z","updatedAt":"2026-05-15T04:10:24.681Z","__v":0},{"_id":"6a069cc4668cf282b93545ce","conversationId":"6a069cb0668cf282b93545c3","senderId":{"_id":"6a069c8e668cf282b93545bb","firstName":"Trial","lastName":"Coach"},"content":"Check your nutrition plan for today.","messageType":"text","isRead":false,"isDelivered":false,"isDeleted":false,"createdAt":"2026-05-15T04:10:44.028Z","updatedAt":"2026-05-15T04:10:44.028Z","__v":0}]');

  print("\nTesting MessageModel.fromJson...");
  try {
    final messages = (messagesJson as List).map((m) => MessageModel.fromJson(m)).toList();
    print("Success! Messages count: ${messages.length}, first senderId: ${messages[0].senderId}");
  } catch (e, st) {
    print("Error in MessageModel: $e\n$st");
  }
}
