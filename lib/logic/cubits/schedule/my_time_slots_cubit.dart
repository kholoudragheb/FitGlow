import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/time_slot_model.dart';
import '../../../services/schedule_service.dart';

abstract class MyTimeSlotsState extends Equatable {
  const MyTimeSlotsState();
  @override
  List<Object?> get props => [];
}

class MyTimeSlotsIdle extends MyTimeSlotsState {}
class MyTimeSlotsLoading extends MyTimeSlotsState {}
class MyTimeSlotsSuccess extends MyTimeSlotsState {
  final List<TimeSlotModel> slots;
  const MyTimeSlotsSuccess(this.slots);
  @override
  List<Object?> get props => [slots];
}
class MyTimeSlotsError extends MyTimeSlotsState {
  final String message;
  const MyTimeSlotsError(this.message);
  @override
  List<Object?> get props => [message];
}

class MyTimeSlotsCubit extends Cubit<MyTimeSlotsState> {
  final ScheduleService _service;
  MyTimeSlotsCubit(this._service) : super(MyTimeSlotsIdle());

  Future<void> fetchMySlots() async {
    emit(MyTimeSlotsLoading());
    try {
      final slots = await _service.getMyTimeSlots();
      
      // Sort by day of week ascending, then start time ascending
      slots.sort((a, b) {
        if (a.dayOfWeek != b.dayOfWeek) {
          return a.dayOfWeek.compareTo(b.dayOfWeek);
        }
        return a.startTime.compareTo(b.startTime);
      });
      
      emit(MyTimeSlotsSuccess(slots));
    } catch (e) {
      emit(MyTimeSlotsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void reset() {
    emit(MyTimeSlotsIdle());
  }
}
