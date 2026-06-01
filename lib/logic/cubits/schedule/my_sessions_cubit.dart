import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/session_model.dart';
import '../../../services/schedule_service.dart';

abstract class MySessionsState extends Equatable {
  const MySessionsState();
  @override
  List<Object?> get props => [];
}

class MySessionsIdle extends MySessionsState {}
class MySessionsLoading extends MySessionsState {}
class MySessionsSuccess extends MySessionsState {
  final List<SessionModel> allSessions;
  final List<SessionModel> filteredSessions;
  final String currentFilter;

  const MySessionsSuccess({
    required this.allSessions,
    required this.filteredSessions,
    required this.currentFilter,
  });

  @override
  List<Object?> get props => [allSessions, filteredSessions, currentFilter];
}
class MySessionsError extends MySessionsState {
  final String message;
  const MySessionsError(this.message);
  @override
  List<Object?> get props => [message];
}

class MySessionsCubit extends Cubit<MySessionsState> {
  final ScheduleService _service;
  MySessionsCubit(this._service) : super(MySessionsIdle());

  Future<void> fetchMySessions() async {
    emit(MySessionsLoading());
    try {
      final sessions = await _service.getMySessions();
      
      // Sort nearest first (descending by date/time, or ascending for upcoming? Let's sort by date descending so newest are first)
      sessions.sort((a, b) {
        final dateA = DateTime.tryParse(a.scheduledDate) ?? DateTime(1970);
        final dateB = DateTime.tryParse(b.scheduledDate) ?? DateTime(1970);
        final cmp = dateB.compareTo(dateA); // Descending date
        if (cmp != 0) return cmp;
        return a.startTime.compareTo(b.startTime); // Ascending time if same date
      });

      _emitSuccess(sessions, 'All');
    } catch (e) {
      emit(MySessionsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void setFilter(String filter) {
    if (state is MySessionsSuccess) {
      final currentState = state as MySessionsSuccess;
      _emitSuccess(currentState.allSessions, filter);
    }
  }

  void _emitSuccess(List<SessionModel> allSessions, String filter) {
    List<SessionModel> filtered;
    
    switch (filter) {
      case 'Upcoming':
        filtered = allSessions.where((s) => s.status.toLowerCase() == 'scheduled' || s.status.toLowerCase() == 'pending' || s.status.toLowerCase() == 'confirmed').toList();
        break;
      case 'Completed':
        filtered = allSessions.where((s) => s.status.toLowerCase() == 'completed').toList();
        break;
      case 'Canceled':
        filtered = allSessions.where((s) => s.status.toLowerCase() == 'canceled' || s.status.toLowerCase() == 'cancelled').toList();
        break;
      case 'All':
      default:
        filtered = List.from(allSessions);
        break;
    }

    emit(MySessionsSuccess(
      allSessions: allSessions,
      filteredSessions: filtered,
      currentFilter: filter,
    ));
  }
}
