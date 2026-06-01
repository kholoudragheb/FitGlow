import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/chat_model.dart';
import '../../../services/chat_service.dart';
import '../../../services/chat_cache_service.dart';

abstract class AIChatState extends Equatable {
  const AIChatState();
  @override
  List<Object?> get props => [];
}

class AIChatInitial extends AIChatState {
  const AIChatInitial();
}

class AIChatLoading extends AIChatState {
  const AIChatLoading();
}

class AIChatSuccess extends AIChatState {
  final List<ChatMessage> messages;
  final bool isSending;
  final String? error;

  const AIChatSuccess({
    required this.messages,
    this.isSending = false,
    this.error,
  });

  @override
  List<Object?> get props => [messages, isSending, error];

  AIChatSuccess copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    String? error,
  }) {
    return AIChatSuccess(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}

class AIChatCubit extends Cubit<AIChatState> {
  final ChatService _service;

  AIChatCubit(this._service) : super(AIChatInitial());

  Future<void> loadHistory() async {
    debugPrint('[AIChatCubit] Loading AI chat history...');
    
    // 1. Load from cache
    try {
      final cachedHistory = await ChatCacheService.getAIChatHistory();
      if (cachedHistory.isNotEmpty) {
        debugPrint('[AIChatCubit] Loaded ${cachedHistory.length} cached messages');
        emit(AIChatSuccess(messages: cachedHistory));
      } else {
        emit(AIChatLoading());
      }
    } catch (e) {
      debugPrint('[AIChatCubit] Cache error: $e');
      emit(AIChatLoading());
    }

    // 2. Sync with backend
    try {
      debugPrint('[AIChatCubit] Fetching AI history from backend...');
      final remoteHistory = await _service.getChatHistory();
      
      // Merge and prevent duplicates
      List<ChatMessage> mergedHistory = [];
      final currentState = state;
      if (currentState is AIChatSuccess) {
        // AI messages don't always have IDs, so we might need to be careful.
        // For now, if backend returns history, we'll trust it more.
        mergedHistory = remoteHistory;
      } else {
        mergedHistory = remoteHistory;
      }

      emit(AIChatSuccess(messages: mergedHistory));
      debugPrint('[AIChatCubit] AI history restored successfully');
      
      // 3. Save to cache
      await ChatCacheService.saveAIChatHistory(mergedHistory);
    } catch (e) {
      if (state is! AIChatSuccess) {
        emit(AIChatSuccess(messages: const [])); // Fallback to empty instead of error for UX
      }
      debugPrint('[AIChatCubit] Error fetching AI history: $e');
    }
  }

  Future<void> sendMessage(String query) async {
    if (query.trim().isEmpty) return;

    final currentState = state;
    List<ChatMessage> currentMessages = [];
    if (currentState is AIChatSuccess) {
      currentMessages = List.from(currentState.messages);
    }

    // Optimistic Update
    final userMsg = ChatMessage(message: query.trim(), sender: 'user', timestamp: DateTime.now());
    currentMessages.add(userMsg);
    
    emit(AIChatSuccess(messages: currentMessages, isSending: true));
    debugPrint('[AIChatCubit] Sending new AI query...');

    try {
      final response = await _service.sendQuery(query.trim());

      final latestState = state;
      if (latestState is AIChatSuccess) {
        final updatedMessages = List<ChatMessage>.from(latestState.messages);
        
        final aiMsg = ChatMessage(
          message: response.response, 
          sender: 'ai', 
          timestamp: DateTime.now(),
          sources: response.sources,
        );
        
        updatedMessages.add(aiMsg);
        
        emit(latestState.copyWith(messages: updatedMessages, isSending: false));
        
        // Save to cache
        await ChatCacheService.saveAIChatHistory(updatedMessages);
        debugPrint('[AIChatCubit] AI sync completed');
      }
    } catch (e) {
      final latestState = state;
      if (latestState is AIChatSuccess) {
        emit(latestState.copyWith(
          isSending: false, 
          error: e.toString().replaceAll('Exception: ', '')
        ));
      }
      debugPrint('[AIChatCubit] Error in AI response: $e');
    }
  }
}
