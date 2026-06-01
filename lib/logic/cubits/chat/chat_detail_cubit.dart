import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/conversation_details_model.dart';
import '../../../models/message_model.dart';
import '../../../services/chat_service.dart';
import '../../../services/chat_cache_service.dart';
import '../../../utils/token_storage.dart';

abstract class ChatDetailState extends Equatable {
  const ChatDetailState();
  @override
  List<Object?> get props => [];
}

class ChatDetailInitial extends ChatDetailState {
  const ChatDetailInitial();
}

class ChatDetailLoading extends ChatDetailState {
  const ChatDetailLoading();
}

class ChatDetailSuccess extends ChatDetailState {
  final ConversationDetailsModel conversation;
  final bool isSending;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final String? deletingMessageId;

  const ChatDetailSuccess(
    this.conversation, {
    this.isSending = false,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.deletingMessageId,
  });

  @override
  List<Object?> get props => [conversation, isSending, isLoadingMore, hasReachedEnd, deletingMessageId];

  ChatDetailSuccess copyWith({
    ConversationDetailsModel? conversation,
    bool? isSending,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    String? deletingMessageId,
    bool clearDeletingId = false,
  }) {
    return ChatDetailSuccess(
      conversation ?? this.conversation,
      isSending: isSending ?? this.isSending,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      deletingMessageId: clearDeletingId ? null : (deletingMessageId ?? this.deletingMessageId),
    );
  }
}

class ChatDetailError extends ChatDetailState {
  final String message;
  const ChatDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

class ChatDetailCubit extends Cubit<ChatDetailState> {
  final ChatService _service;
  final String conversationId;
  int _currentLimit = 50;

  ChatDetailCubit(this._service, this.conversationId) : super(ChatDetailInitial());

  Future<void> fetchConversation() async {
    debugPrint('[ChatDetailCubit] Loading chat history for $conversationId...');
    
    // 1. Try to load from cache first
    try {
      final cachedMessages = await ChatCacheService.getCoachMessages(conversationId);
      if (cachedMessages.isNotEmpty) {
        debugPrint('[ChatDetailCubit] Loading ${cachedMessages.length} cached messages...');
        
        // We need a basic conversation model to show while loading
        final placeholderConversation = ConversationDetailsModel(
          id: conversationId,
          participants: [], // Will be updated by backend
          messages: cachedMessages.where((m) => !m.isDeleted).toList(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        emit(ChatDetailSuccess(
          placeholderConversation,
          hasReachedEnd: false,
        ));
      } else {
        emit(ChatDetailLoading());
      }
    } catch (e) {
      debugPrint('[ChatDetailCubit] Cache error: $e');
      emit(ChatDetailLoading());
    }

    // 2. Fetch from backend
    try {
      debugPrint('[ChatDetailCubit] Fetching messages from backend...');
      ConversationDetailsModel? conversation;
      try {
        conversation = await _service.getConversationById(conversationId: conversationId);
      } catch (e) {
        debugPrint('[ChatDetailCubit] getConversationById fallback: $e');
        conversation = ConversationDetailsModel(
          id: conversationId,
          participants: [],
          messages: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      final remoteMessages = await _service.getMessages(conversationId: conversationId, limit: _currentLimit);
      
      remoteMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      // 3. Merge cached + backend data to prevent duplicates
      List<MessageModel> mergedMessages = [];
      final latestState = state;
      if (latestState is ChatDetailSuccess) {
        // Keep any optimistic sending messages, but replace all cached messages with authoritative remoteMessages
        final sendingMessages = latestState.conversation.messages.where((m) => m.status == 'sending').toList();
        mergedMessages = [...remoteMessages, ...sendingMessages];
        mergedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      } else {
        mergedMessages = remoteMessages;
      }

      final fullConversation = ConversationDetailsModel(
        id: conversation.id,
        participants: conversation.participants,
        messages: mergedMessages,
        createdAt: conversation.createdAt,
        updatedAt: conversation.updatedAt,
      );

      if (state is ChatDetailSuccess) {
        emit((state as ChatDetailSuccess).copyWith(
          conversation: fullConversation,
          hasReachedEnd: remoteMessages.length < _currentLimit,
        ));
      } else {
        emit(ChatDetailSuccess(
          fullConversation,
          hasReachedEnd: remoteMessages.length < _currentLimit,
        ));
      }

      debugPrint('[ChatDetailCubit] Messages restored successfully');
      
      // 4. Save to cache
      await ChatCacheService.saveCoachMessages(conversationId, mergedMessages);
      
      markAsRead();
    } catch (e) {
      if (state is! ChatDetailSuccess) {
        emit(ChatDetailError(e.toString().replaceAll('Exception: ', '')));
      } else {
        debugPrint('[ChatDetailCubit] Background fetch failed: $e');
      }
    }
  }

  Future<void> markAsRead() async {
    try {
      await _service.markConversationAsRead(conversationId: conversationId);
    } catch (e) {
      debugPrint('[ChatDetailCubit] Failed to mark as read: $e');
    }
  }

  Future<void> loadMoreMessages() async {
    final currentState = state;
    if (currentState is ChatDetailSuccess && !currentState.isLoadingMore && !currentState.hasReachedEnd) {
      emit(currentState.copyWith(isLoadingMore: true));
      try {
        _currentLimit += 50;
        final newMessages = await _service.getMessages(
          conversationId: conversationId,
          limit: _currentLimit,
        );

        newMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        final latestState = state;
        if (latestState is ChatDetailSuccess) {
          final updatedConversation = ConversationDetailsModel(
            id: latestState.conversation.id,
            participants: latestState.conversation.participants,
            messages: newMessages,
            createdAt: latestState.conversation.createdAt,
            updatedAt: latestState.conversation.updatedAt,
          );

          emit(latestState.copyWith(
            conversation: updatedConversation,
            isLoadingMore: false,
            hasReachedEnd: newMessages.length < _currentLimit,
          ));
          
          // Save expanded history to cache
          await ChatCacheService.saveCoachMessages(conversationId, newMessages);
        }
      } catch (e) {
        emit(currentState.copyWith(isLoadingMore: false));
      }
    }
  }

  Future<void> sendMessage(String content, {String messageType = 'text'}) async {
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) return;
    
    final currentState = state;
    if (currentState is ChatDetailSuccess) {
      debugPrint('[ChatDetailCubit] Sending new message...');
      
      // OPTIMISTIC UPDATE: Add a "sending" placeholder message
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final currentUserInfo = await TokenStorage.getUserId();
      
      final placeholderMsg = MessageModel(
        id: tempId,
        conversationId: conversationId,
        senderId: currentUserInfo ?? '',
        content: trimmedContent,
        messageType: messageType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: 'sending',
      );
      
      final optimisticMessages = List<MessageModel>.from(currentState.conversation.messages)..add(placeholderMsg);
      emit(currentState.copyWith(
        conversation: ConversationDetailsModel(
          id: currentState.conversation.id,
          participants: currentState.conversation.participants,
          messages: optimisticMessages,
          createdAt: currentState.conversation.createdAt,
          updatedAt: DateTime.now(),
        ),
        isSending: true,
      ));

      try {
        final newMessage = await _service.sendMessageToConversation(
          conversationId: conversationId,
          content: trimmedContent,
          messageType: messageType,
        );
        
        final latestState = state;
        if (latestState is ChatDetailSuccess) {
          // Replace placeholder with real message
          final updatedMessages = List<MessageModel>.from(latestState.conversation.messages)
            .where((m) => m.id != tempId)
            .toList()..add(newMessage);
          
          final updatedConversation = ConversationDetailsModel(
            id: latestState.conversation.id,
            participants: latestState.conversation.participants,
            messages: updatedMessages,
            createdAt: latestState.conversation.createdAt,
            updatedAt: DateTime.now(),
          );
          
          emit(latestState.copyWith(
            conversation: updatedConversation,
            isSending: false,
          ));
          
          // Save to cache
          await ChatCacheService.saveCoachMessages(conversationId, updatedMessages);
        }
        debugPrint('[ChatDetailCubit] Sync completed');
      } catch (e) {
        // Remove placeholder on error
        final errorMessages = currentState.conversation.messages.where((m) => m.id != tempId).toList();
        emit(currentState.copyWith(
          conversation: ConversationDetailsModel(
            id: currentState.conversation.id,
            participants: currentState.conversation.participants,
            messages: errorMessages,
            createdAt: currentState.conversation.createdAt,
            updatedAt: DateTime.now(),
          ),
          isSending: false,
        ));
        debugPrint('[ChatDetailCubit] Error sending message: $e');
      }
    }
  }


  Future<bool> deleteMessage(String messageId) async {
    final currentState = state;
    if (currentState is ChatDetailSuccess) {
      emit(currentState.copyWith(deletingMessageId: messageId));
      try {
        await _service.deleteMessage(messageId: messageId);
        
        // Remove message from local list
        final updatedMessages = currentState.conversation.messages.where((m) => m.id != messageId).toList();
        
        final updatedConversation = ConversationDetailsModel(
          id: currentState.conversation.id,
          participants: currentState.conversation.participants,
          messages: updatedMessages,
          createdAt: currentState.conversation.createdAt,
          updatedAt: DateTime.now(),
        );
        
        emit(currentState.copyWith(
          conversation: updatedConversation,
          clearDeletingId: true,
        ));
        await ChatCacheService.saveCoachMessages(conversationId, updatedMessages);
        return true;
      } catch (e) {
        emit(currentState.copyWith(clearDeletingId: true));
        return false;
      }
    }
    return false;
  }
}
