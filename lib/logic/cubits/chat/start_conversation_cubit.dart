import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/conversation_model.dart';
import '../../../services/chat_service.dart';

abstract class StartConversationState extends Equatable {
  const StartConversationState();
  @override
  List<Object?> get props => [];
}

class StartConversationInitial extends StartConversationState {}

class StartConversationLoading extends StartConversationState {}

class StartConversationSuccess extends StartConversationState {
  final ConversationModel conversation;
  const StartConversationSuccess(this.conversation);
  @override
  List<Object?> get props => [conversation];
}

class StartConversationError extends StartConversationState {
  final String message;
  const StartConversationError(this.message);
  @override
  List<Object?> get props => [message];
}

class StartConversationCubit extends Cubit<StartConversationState> {
  final ChatService _service;

  StartConversationCubit(this._service) : super(StartConversationInitial());

  Future<void> startNewConversation({
    required String recipientId,
    required String initialMessage,
  }) async {
    if (initialMessage.trim().isEmpty) {
      emit(const StartConversationError("Message cannot be empty"));
      return;
    }

    emit(StartConversationLoading());
    try {
      final conversation = await _service.startConversation(
        recipientId: recipientId,
        initialMessage: initialMessage.trim(),
      );
      emit(StartConversationSuccess(conversation));
    } catch (e) {
      emit(StartConversationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void reset() {
    emit(StartConversationInitial());
  }
}
