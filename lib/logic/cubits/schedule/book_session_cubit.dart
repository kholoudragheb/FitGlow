import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/session_model.dart';
import '../../../services/schedule_service.dart';

abstract class BookSessionState extends Equatable {
  const BookSessionState();
  @override
  List<Object?> get props => [];
}

class BookSessionIdle extends BookSessionState {}
class BookSessionLoading extends BookSessionState {}
class BookSessionSuccess extends BookSessionState {
  final SessionModel session;
  const BookSessionSuccess(this.session);
  @override
  List<Object?> get props => [session];
}
class BookSessionError extends BookSessionState {
  final String message;
  const BookSessionError(this.message);
  @override
  List<Object?> get props => [message];
}

class BookSessionCubit extends Cubit<BookSessionState> {
  final ScheduleService _service;
  BookSessionCubit(this._service) : super(BookSessionIdle());

  Future<void> book({
    required String coachId,
    required String scheduledDate,
    required String startTime,
    required String endTime,
    required String sessionType,
    String? title,
  }) async {
    // Local validation
    if (coachId.isEmpty || scheduledDate.isEmpty || startTime.isEmpty || endTime.isEmpty) {
      emit(const BookSessionError('Missing required booking details.'));
      return;
    }

    emit(BookSessionLoading());

    final body = {
      "coachId": coachId,
      "scheduledDate": scheduledDate,
      "startTime": startTime,
      "endTime": endTime,
      "sessionType": sessionType,
    };
    if (title != null && title.isNotEmpty) {
      body["title"] = title;
    }

    try {
      final session = await _service.bookSession(body: body);
      emit(BookSessionSuccess(session));
    } catch (e) {
      emit(BookSessionError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void reset() {
    emit(BookSessionIdle());
  }
}
