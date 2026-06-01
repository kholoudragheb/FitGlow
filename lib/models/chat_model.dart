import 'package:equatable/equatable.dart';

class ChatResponse extends Equatable {
  final String response;
  final List<String> sources;

  const ChatResponse({required this.response, required this.sources});

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    // 'response' may come as 'answer' or 'message' on some versions
    final text = (json['response'] ?? json['answer'] ?? json['message'] ?? '').toString();

    // sources may be List<String>, List<dynamic>, or missing entirely
    final rawSources = json['sources'];
    final List<String> sources = rawSources is List
        ? rawSources.map((e) => e.toString()).toList()
        : [];

    return ChatResponse(response: text, sources: sources);
  }

  @override
  List<Object?> get props => [response, sources];
}

class ChatMessage extends Equatable {
  final String message;
  final String sender; // "user" or "ai"
  final DateTime? timestamp;
  final List<String>? sources;

  const ChatMessage({required this.message, required this.sender, this.timestamp, this.sources});

  factory ChatMessage.fromDynamic(dynamic json) {
    if (json is! Map) {
      return ChatMessage(message: json.toString(), sender: 'ai');
    }

    String msg = json['message'] ?? json['text'] ?? json['content'] ?? json['response'] ?? '';
    String snd = json['role'] ?? json['sender'] ?? json['type'] ?? 'ai';
    
    // Normalize role naming conventions
    if (snd.toLowerCase().contains('user')) {
      snd = 'user';
    } else {
      snd = 'ai';
    }
    
    DateTime? ts;
    if (json['timestamp'] != null) {
      ts = DateTime.tryParse(json['timestamp'].toString());
    } else if (json['created_at'] != null) {
      ts = DateTime.tryParse(json['created_at'].toString());
    } else if (json['time'] != null) {
      ts = DateTime.tryParse(json['time'].toString());
    }

    final rawSources = json['sources'];
    final List<String> src = rawSources is List
        ? rawSources.map((e) => e.toString()).toList()
        : [];

    return ChatMessage(message: msg, sender: snd, timestamp: ts, sources: src.isEmpty ? null : src);
  }

  @override
  List<Object?> get props => [message, sender, timestamp, sources];

  Map<String, dynamic> toUIFormat() {
    String formattedTime = '';
    if (timestamp != null) {
      int hour = timestamp!.hour;
      String period = hour >= 12 ? 'PM' : 'AM';
      if (hour == 0) hour = 12;
      if (hour > 12) hour -= 12;
      formattedTime = '$hour:${timestamp!.minute.toString().padLeft(2, '0')} $period';
    } else {
      final now = DateTime.now();
      int hour = now.hour;
      String period = hour >= 12 ? 'PM' : 'AM';
      if (hour == 0) hour = 12;
      if (hour > 12) hour -= 12;
      formattedTime = '$hour:${now.minute.toString().padLeft(2, '0')} $period';
    }

    return {
      'sender': sender == 'user' ? 'User' : 'AI',
      'text': message,
      'time': formattedTime,
    };
  }
}
