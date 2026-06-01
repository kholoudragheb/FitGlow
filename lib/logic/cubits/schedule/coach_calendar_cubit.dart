import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/coach_calendar_model.dart';
import '../../../services/schedule_service.dart';

abstract class CoachCalendarState extends Equatable {
  const CoachCalendarState();
  @override
  List<Object?> get props => [];
}

class CoachCalendarInitial extends CoachCalendarState {}

class CoachCalendarLoading extends CoachCalendarState {}

class CoachCalendarSuccess extends CoachCalendarState {
  final CoachCalendarModel calendarData;
  const CoachCalendarSuccess(this.calendarData);
  @override
  List<Object?> get props => [calendarData];
}

class CoachCalendarError extends CoachCalendarState {
  final String message;
  const CoachCalendarError(this.message);
  @override
  List<Object?> get props => [message];
}

class CoachCalendarCubit extends Cubit<CoachCalendarState> {
  final ScheduleService _service;
  CoachCalendarCubit(this._service) : super(CoachCalendarInitial());

  Future<void> fetchCalendar(int month, int year) async {
    emit(CoachCalendarLoading());
    try {
      final data = await _service.getCoachCalendar(month: month, year: year);
      emit(CoachCalendarSuccess(data));
    } catch (e) {
      emit(CoachCalendarError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
