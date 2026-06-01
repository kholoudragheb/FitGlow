import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/conversation_model.dart';
import '../../../services/chat_service.dart';

abstract class ConversationsState extends Equatable {
  const ConversationsState();
  @override
  List<Object?> get props => [];
}

class ConversationsInitial extends ConversationsState {}

class ConversationsLoading extends ConversationsState {}

class ConversationsSuccess extends ConversationsState {
  final List<ConversationModel> conversations;
  const ConversationsSuccess(this.conversations);
  @override
  List<Object?> get props => [conversations];
}

class ConversationsError extends ConversationsState {
  final String message;
  const ConversationsError(this.message);
  @override
  List<Object?> get props => [message];
}

class ConversationsCubit extends Cubit<ConversationsState> {
  final ChatService _service;
  ConversationsCubit(this._service) : super(ConversationsInitial());

  Future<void> fetchConversations() async {
    emit(ConversationsLoading());
    try {
      final conversations = await _service.getConversations();
      
      // Sort by last message time (newest first)
      conversations.sort((a, b) {
        final timeA = a.lastMessageTime ?? a.updatedAt;
        final timeB = b.lastMessageTime ?? b.updatedAt;
        return timeB.compareTo(timeA);
      });

      emit(ConversationsSuccess(conversations));
    } catch (e) {
      emit(ConversationsError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
