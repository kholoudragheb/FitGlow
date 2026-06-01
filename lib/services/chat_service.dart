import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/chat_model.dart';
import '../models/conversation_model.dart';
import '../utils/token_storage.dart';
import '../services/auth_service.dart';
import '../models/refresh_token_model.dart';
import '../models/message_model.dart';
import '../models/conversation_details_model.dart';
import '../models/unread_count_model.dart';
import '../services/coach_service.dart';


class ChatService {
  static const String baseUrl =
      'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';

  static const Duration _connectTimeout = Duration(seconds: 30);
  static const Duration _receiveTimeout = Duration(seconds: 30);

  /// Helper: POST with a timeout that throws a [TimeoutException] if exceeded.
  Future<http.Response> _timedPost(
    Uri url, {
    required Map<String, String> headers,
    required String body,
  }) async {
    return http
        .post(url, headers: headers, body: body)
        .timeout(_connectTimeout + _receiveTimeout);
  }

  /// Helper: GET with a timeout.
  Future<http.Response> _timedGet(
    Uri url, {
    required Map<String, String> headers,
  }) async {
    return http
        .get(url, headers: headers)
        .timeout(_connectTimeout + _receiveTimeout);
  }

  Future<ChatResponse> sendMessage(String query) => sendQuery(query);

  Future<ChatResponse> sendQuery(String query) async {
    final url = Uri.parse('$baseUrl/ai/chat'); // ✅ correct endpoint
    final token = await TokenStorage.getAccessToken();

    debugPrint('[ChatService] POST $url');
    debugPrint('[ChatService] Body: {"query": "$query"}');

    try {
      final response = await _timedPost(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'query': query}),
      );

      debugPrint('[ChatService] Response ${response.statusCode}: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        return ChatResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized — please log in again.');
      } else {
        throw Exception(
            'Server error (${response.statusCode}): ${response.body}');
      }
    } on SocketException catch (e) {
      debugPrint('[ChatService] SocketException: $e');
      throw Exception(
          'Network error: Could not reach the server. Check your internet connection.');
    } on TimeoutException catch (e) {
      debugPrint('[ChatService] TimeoutException: $e');
      throw Exception(
          'Request timed out. The server took too long to respond.');
    } on HandshakeException catch (e) {
      debugPrint('[ChatService] SSL HandshakeException: $e');
      throw Exception('SSL error: ${e.message}');
    } catch (e) {
      debugPrint('[ChatService] Unexpected error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<ChatMessage>> getChatHistory() async {
    final url = Uri.parse('$baseUrl/ai/history');

    String? token = await TokenStorage.getAccessToken();
    debugPrint('[ChatService] GET $url');

    try {
      var response = await _timedGet(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // Handle 401 — attempt token refresh then retry once
      if (response.statusCode == 401) {
        final refreshToken = await TokenStorage.getRefreshToken();
        if (refreshToken != null) {
          final authService = AuthService();
          final refreshRes = await authService
              .refreshAuthToken(RefreshTokenRequest(refreshToken: refreshToken));

          if (refreshRes.isSuccess && refreshRes.accessToken != null) {
            await TokenStorage.saveTokens(
              accessToken: refreshRes.accessToken!,
              refreshToken: refreshRes.refreshToken,
            );
            token = refreshRes.accessToken!;

            response = await _timedGet(
              url,
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
            );
          }
        }
      }

      debugPrint(
          '[ChatService] History ${response.statusCode}: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic data = jsonDecode(response.body);

        List<dynamic> listToParse = [];
        if (data is List) {
          listToParse = data;
        } else if (data is Map) {
          for (var value in data.values) {
            if (value is List) {
              listToParse = value;
              break;
            }
          }
          if (listToParse.isEmpty &&
              data.containsKey('data') &&
              data['data'] is List) {
            listToParse = data['data'];
          }
        }

        return listToParse.map((e) => ChatMessage.fromDynamic(e)).toList();
      } else {
        throw Exception(
            'Failed to load history (${response.statusCode}): ${response.body}');
      }
    } on SocketException catch (e) {
      debugPrint('[ChatService] SocketException (history): $e');
      rethrow;
    } on TimeoutException catch (e) {
      debugPrint('[ChatService] TimeoutException (history): $e');
      rethrow;
    } catch (e) {
      debugPrint('[ChatService] Error fetching chat history: $e');
      rethrow;
    }
  }

  Future<List<ConversationModel>> getConversations() async {
    final url = Uri.parse('$baseUrl/chat/conversations');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Fetching conversations...");
    }

    try {
      final response = await _timedGet(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Get Conversations Status: ${response.statusCode}");
        print("Get Conversations Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        List<dynamic> conversationsList = [];
        if (decodedData is List) {
          conversationsList = decodedData;
        } else if (decodedData is Map && decodedData.containsKey('conversations')) {
          conversationsList = decodedData['conversations'];
        } else if (decodedData is Map && decodedData.containsKey('data')) {
          conversationsList = decodedData['data'];
        }

        return conversationsList.map((c) => ConversationModel.fromJson(c)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized — please log in again.');
      } else if (response.statusCode == 500) {
        debugPrint('[ChatService] 500 error detected on getConversations. Attempting fallback recovery...');
        try {
          final myCoach = await CoachService().getMyCoach();
          if (myCoach != null && myCoach.userId.isNotEmpty) {
            final recoveredConv = await startConversation(
              recipientId: myCoach.userId,
              initialMessage: "",
            );
            return [recoveredConv];
          }
        } catch (recoveryErr) {
          debugPrint('[ChatService] Fallback recovery failed: $recoveryErr');
        }
        throw Exception('Failed to load conversations (${response.statusCode}): ${response.body}');
      } else {
        throw Exception('Failed to load conversations (${response.statusCode}): ${response.body}');
      }
    } on SocketException catch (e) {
      debugPrint('[ChatService] SocketException (conversations): $e');
      rethrow;
    } on TimeoutException catch (e) {
      debugPrint('[ChatService] TimeoutException (conversations): $e');
      rethrow;
    } catch (e) {
      debugPrint('[ChatService] Error fetching conversations: $e');
      rethrow;
    }
  }

  Future<ConversationModel> startConversation({
    required String recipientId,
    required String initialMessage,
  }) async {
    final url = Uri.parse('$baseUrl/chat/conversations');
    final token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Starting conversation...");
      print("Recipient ID: $recipientId");
      print("Initial Message: $initialMessage");
    }

    try {
      final response = await _timedPost(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'recipientId': recipientId,
          'initialMessage': initialMessage,
        }),
      );

      if (kDebugMode) {
        print("Start Conversation Status: ${response.statusCode}");
        print("Start Conversation Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // Handle different possible response structures
        if (data.containsKey('conversation')) {
          return ConversationModel.fromJson(data['conversation']);
        } else if (data.containsKey('data')) {
          return ConversationModel.fromJson(data['data']);
        }
        return ConversationModel.fromJson(data);
      } else if (response.statusCode == 400) {
        throw Exception('Invalid request: Please check your message.');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized — please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception('Recipient not found.');
      } else if (response.statusCode == 409) {
        throw Exception('Conversation already exists.');
      } else {
        throw Exception('Server error (${response.statusCode}): ${response.body}');
      }
    } on SocketException {
      throw Exception('Network error: Check your internet connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      debugPrint('[ChatService] Error starting conversation: $e');
      rethrow;
    }
  }

  Future<ConversationDetailsModel> getConversationById({
    required String conversationId,
  }) async {
    final url = Uri.parse('$baseUrl/chat/conversations/$conversationId');
    final token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Fetching conversation...");
      print(conversationId);
    }

    try {
      final response = await _timedGet(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print("Get Conversation Details Status: ${response.statusCode}");
        print("Get Conversation Details Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ConversationDetailsModel.fromJson(data);
      } else if (response.statusCode == 400) {
        throw Exception('Invalid conversation ID.');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized — please log in again.');
      } else if (response.statusCode == 403) {
        throw Exception('Access forbidden.');
      } else if (response.statusCode == 404) {
        throw Exception('Conversation not found.');
      } else {
        throw Exception('Server error (${response.statusCode}): ${response.body}');
      }
    } on SocketException {
      throw Exception('Network error: Check your internet connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      debugPrint('[ChatService] Error getting conversation: $e');
      rethrow;
    }
  }

  Future<UnreadCountModel> getUnreadChatCount() async {
    final url = Uri.parse('$baseUrl/chat/unread-count');
    final token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Fetching unread count...");
    }

    try {
      final response = await _timedGet(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print("Unread Count Status: ${response.statusCode}");
        print("Unread Count Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return UnreadCountModel.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized — please log in again.');
      } else {
        throw Exception('Server error (${response.statusCode}): ${response.body}');
      }
    } on SocketException {
      throw Exception('Network error: Check your internet connection.');
    } on TimeoutException {
      throw Exception('Request timed out.');
    } catch (e) {
      debugPrint('[ChatService] Error getting unread count: $e');
      rethrow;
    }
  }

  Future<void> deleteMessage({
    required String messageId,
  }) async {
    final url = Uri.parse('$baseUrl/chat/messages/$messageId');
    final token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Deleting message...");
      print(messageId);
    }

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(_connectTimeout + _receiveTimeout);

      if (kDebugMode) {
        print("Delete Message Status: ${response.statusCode}");
        print("Delete Message Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 400) {
        throw Exception('Invalid message ID.');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized — please log in again.');
      } else if (response.statusCode == 403) {
        throw Exception('You can only delete your own messages.');
      } else if (response.statusCode == 404) {
        throw Exception('Message not found.');
      } else {
        throw Exception('Server error (${response.statusCode}): ${response.body}');
      }
    } on SocketException {
      throw Exception('Network error: Check your internet connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      debugPrint('[ChatService] Error deleting message: $e');
      rethrow;
    }
  }

  Future<void> markConversationAsRead({
    required String conversationId,
  }) async {
    final url = Uri.parse('$baseUrl/chat/conversations/$conversationId/read');
    final token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Marking conversation as read...");
      print(conversationId);
    }

    try {
      final response = await _timedPost(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({}),
      );

      if (kDebugMode) {
        print("Mark as Read Status: ${response.statusCode}");
        print("Mark as Read Body: ${response.body}");
      }

      if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204) {
        debugPrint('[ChatService] Mark as Read failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[ChatService] Error marking as read: $e');
    }
  }

  Future<List<MessageModel>> getMessages({
    required String conversationId,
    int limit = 50,
  }) async {
    final url = Uri.parse('$baseUrl/chat/conversations/$conversationId/messages?limit=$limit');
    final token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Fetching messages...");
      print(conversationId);
      print(limit);
    }

    try {
      final response = await _timedGet(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print("Get Messages Status: ${response.statusCode}");
        print("Get Messages Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);
        List<dynamic> messagesList = [];
        
        if (decodedData is List) {
          messagesList = decodedData;
        } else if (decodedData is Map && decodedData.containsKey('messages')) {
          messagesList = decodedData['messages'];
        } else if (decodedData is Map && decodedData.containsKey('data')) {
          messagesList = decodedData['data'];
        }

        return messagesList.map((m) => MessageModel.fromJson(m)).where((m) => !m.isDeleted).toList();
      } else if (response.statusCode == 400) {
        throw Exception('Invalid conversation ID.');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized — please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception('Conversation not found.');
      } else {
        throw Exception('Server error (${response.statusCode}): ${response.body}');
      }
    } on SocketException {
      throw Exception('Network error: Check your internet connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      debugPrint('[ChatService] Error getting messages: $e');
      rethrow;
    }
  }

  Future<MessageModel> sendMessageToConversation({
    required String conversationId,
    required String content,
    String messageType = 'text',
  }) async {
    final url = Uri.parse('$baseUrl/chat/conversations/$conversationId/messages');
    final token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Sending message...");
      print(conversationId);
      print(content);
      print(messageType);
    }

    try {
      final response = await _timedPost(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'content': content,
          'messageType': messageType,
        }),
      );

      if (kDebugMode) {
        print("Send Message Status: ${response.statusCode}");
        print("Send Message Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic decodedData = jsonDecode(response.body);
        dynamic msgData = decodedData;
        if (decodedData is Map) {
          msgData = decodedData['data'] ?? decodedData['message'] ?? decodedData;
        }
        return MessageModel.fromJson(msgData);
      } else if (response.statusCode == 400) {
        throw Exception('Invalid message data.');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized — please log in again.');
      } else if (response.statusCode == 403) {
        throw Exception('Access forbidden.');
      } else if (response.statusCode == 404) {
        throw Exception('Conversation not found.');
      } else if (response.statusCode == 413) {
        throw Exception('Content too large.');
      } else {
        throw Exception('Server error (${response.statusCode}): ${response.body}');
      }
    } on SocketException {
      throw Exception('Network error: Check your internet connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      debugPrint('[ChatService] Error sending message: $e');
      rethrow;
    }
  }
}

