import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/session_model.dart';
import '../../../services/schedule_service.dart';

abstract class SessionDetailsState extends Equatable {
  const SessionDetailsState();
  @override
  List<Object?> get props => [];
}

class SessionDetailsInitial extends SessionDetailsState {}

class SessionDetailsLoading extends SessionDetailsState {}

class SessionDetailsSuccess extends SessionDetailsState {
  final SessionModel session;
  final String? message;
  const SessionDetailsSuccess(this.session, {this.message});
  @override
  List<Object?> get props => [session, message];
}

class SessionDetailsError extends SessionDetailsState {
  final String message;
  const SessionDetailsError(this.message);
  @override
  List<Object?> get props => [message];
}

class SessionActionLoading extends SessionDetailsState {
  final SessionModel currentSession;
  const SessionActionLoading(this.currentSession);
  @override
  List<Object?> get props => [currentSession];
}

class SessionDetailsCubit extends Cubit<SessionDetailsState> {
  final ScheduleService _service;
  SessionDetailsCubit(this._service) : super(SessionDetailsInitial());

  Future<void> fetchSessionDetails(String sessionId) async {
    emit(SessionDetailsLoading());
    try {
      final session = await _service.getSessionById(sessionId: sessionId);
      emit(SessionDetailsSuccess(session));
    } catch (e) {
      emit(SessionDetailsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateStatus(String sessionId, String newStatus) async {
    await updateSession(sessionId, {'status': newStatus});
  }

  Future<void> addNotes(String sessionId, String notes) async {
    await updateSession(sessionId, {'notes': notes});
  }

  Future<void> updateMeetingLink(String sessionId, String meetingLink) async {
    await updateSession(sessionId, {'meetingLink': meetingLink});
  }

  Future<void> updateSession(String sessionId, Map<String, dynamic> body) async {
    if (state is! SessionDetailsSuccess && state is! SessionActionLoading) return;
    
    final currentSession = (state is SessionDetailsSuccess) 
        ? (state as SessionDetailsSuccess).session 
        : (state as SessionActionLoading).currentSession;

    emit(SessionActionLoading(currentSession));
    try {
      final updatedSession = await _service.updateSession(sessionId: sessionId, body: body);
      emit(SessionDetailsSuccess(updatedSession, message: 'Session updated successfully'));
    } catch (e) {
      emit(SessionDetailsError(e.toString().replaceAll('Exception: ', '')));
      // Restore previous success state after showing error if needed, or just stay in error state
    }
  }

  Future<void> cancelSession(String sessionId, String reason) async {
    if (state is! SessionDetailsSuccess && state is! SessionActionLoading) return;
    
    final currentSession = (state is SessionDetailsSuccess) 
        ? (state as SessionDetailsSuccess).session 
        : (state as SessionActionLoading).currentSession;

    emit(SessionActionLoading(currentSession));
    try {
      final canceledSession = await _service.cancelSession(sessionId: sessionId, reason: reason);
      emit(SessionDetailsSuccess(canceledSession, message: 'Session canceled successfully'));
    } catch (e) {
      emit(SessionDetailsError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
