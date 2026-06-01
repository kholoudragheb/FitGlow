import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/chat_service.dart';

abstract class UnreadCountState extends Equatable {
  const UnreadCountState();
  @override
  List<Object?> get props => [];
}

class UnreadCountInitial extends UnreadCountState {}

class UnreadCountLoading extends UnreadCountState {}

class UnreadCountSuccess extends UnreadCountState {
  final int count;
  const UnreadCountSuccess(this.count);
  @override
  List<Object?> get props => [count];
}

class UnreadCountError extends UnreadCountState {
  final String message;
  const UnreadCountError(this.message);
  @override
  List<Object?> get props => [message];
}

class UnreadCountCubit extends Cubit<UnreadCountState> {
  final ChatService _service;
  int _lastKnownCount = 0;

  UnreadCountCubit(this._service) : super(UnreadCountInitial());

  Future<void> fetchUnreadCount({bool silent = false}) async {
    if (!silent) emit(UnreadCountLoading());
    try {
      final result = await _service.getUnreadChatCount();
      _lastKnownCount = result.unreadCount;
      emit(UnreadCountSuccess(_lastKnownCount));
    } catch (e) {
      if (!silent) {
        emit(UnreadCountError(e.toString()));
      } else {
        // Keep previous state if silent
        emit(UnreadCountSuccess(_lastKnownCount));
      }
    }
  }

  void updateCount(int newCount) {
    _lastKnownCount = newCount;
    emit(UnreadCountSuccess(_lastKnownCount));
  }

  void decrementCount(int amount) {
    _lastKnownCount = (_lastKnownCount - amount).clamp(0, double.infinity).toInt();
    emit(UnreadCountSuccess(_lastKnownCount));
  }
}
