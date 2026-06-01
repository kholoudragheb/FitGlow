import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message_model.dart';
import '../models/chat_model.dart';
import 'package:flutter/foundation.dart';

class ChatCacheService {
  static const String _coachChatPrefix = 'coach_chat_';
  static const String _aiChatKey = 'ai_chat_history';

  // --- Coach Chat Cache ---

  static Future<void> saveCoachMessages(String conversationId, List<MessageModel> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> encodedMessages = messages.map((m) => jsonEncode(m.toJson())).toList();
      await prefs.setStringList('$_coachChatPrefix$conversationId', encodedMessages);
      debugPrint('[ChatCacheService] Saved ${messages.length} coach messages for $conversationId');
    } catch (e) {
      debugPrint('[ChatCacheService] Error saving coach messages: $e');
    }
  }

  static Future<List<MessageModel>> getCoachMessages(String conversationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? encodedMessages = prefs.getStringList('$_coachChatPrefix$conversationId');
      if (encodedMessages == null) return [];
      
      return encodedMessages.map((m) => MessageModel.fromJson(jsonDecode(m))).toList();
    } catch (e) {
      debugPrint('[ChatCacheService] Error getting coach messages: $e');
      return [];
    }
  }

  // --- AI Chat Cache ---

  static Future<void> saveAIChatHistory(List<ChatMessage> history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // We need to add toJson to ChatMessage or manually encode
      final List<Map<String, dynamic>> maps = history.map((m) => {
        'message': m.message,
        'sender': m.sender,
        'timestamp': m.timestamp?.toIso8601String(),
        'sources': m.sources,
      }).toList();
      
      await prefs.setString(_aiChatKey, jsonEncode(maps));
      debugPrint('[ChatCacheService] Saved ${history.length} AI messages');
    } catch (e) {
      debugPrint('[ChatCacheService] Error saving AI history: $e');
    }
  }

  static Future<List<ChatMessage>> getAIChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? encodedHistory = prefs.getString(_aiChatKey);
      if (encodedHistory == null) return [];
      
      final List<dynamic> decoded = jsonDecode(encodedHistory);
      return decoded.map((m) => ChatMessage.fromDynamic(m)).toList();
    } catch (e) {
      debugPrint('[ChatCacheService] Error getting AI history: $e');
      return [];
    }
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_coachChatPrefix) || k == _aiChatKey);
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
