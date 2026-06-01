import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/time_slot_model.dart';
import '../../../services/schedule_service.dart';

abstract class CreateTimeSlotState extends Equatable {
  const CreateTimeSlotState();
  @override
  List<Object?> get props => [];
}

class CreateTimeSlotIdle extends CreateTimeSlotState {}
class CreateTimeSlotLoading extends CreateTimeSlotState {}
class CreateTimeSlotSuccess extends CreateTimeSlotState {
  final TimeSlotModel slot;
  const CreateTimeSlotSuccess(this.slot);
  @override
  List<Object?> get props => [slot];
}
class CreateTimeSlotError extends CreateTimeSlotState {
  final String message;
  const CreateTimeSlotError(this.message);
  @override
  List<Object?> get props => [message];
}

class CreateTimeSlotCubit extends Cubit<CreateTimeSlotState> {
  final ScheduleService _service;
  CreateTimeSlotCubit(this._service) : super(CreateTimeSlotIdle());

  Future<void> submitSlot(Map<String, dynamic> slotData) async {
    // Validation
    final int duration = slotData['duration'] ?? 0;
    if (duration <= 0) {
      emit(const CreateTimeSlotError("Duration must be greater than 0"));
      emit(CreateTimeSlotIdle());
      return;
    }

    final String startTimeStr = slotData['startTime'] ?? '';
    final String endTimeStr = slotData['endTime'] ?? '';
    
    if (startTimeStr.isNotEmpty && endTimeStr.isNotEmpty) {
      try {
        final startParts = startTimeStr.split(':');
        final endParts = endTimeStr.split(':');
        
        final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
        final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
        
        if (startMinutes >= endMinutes) {
          emit(const CreateTimeSlotError("Start time must be before end time"));
          emit(CreateTimeSlotIdle());
          return;
        }
      } catch (e) {
        emit(const CreateTimeSlotError("Invalid time format"));
        emit(CreateTimeSlotIdle());
        return;
      }
    }

    emit(CreateTimeSlotLoading());
    try {
      final slot = await _service.createTimeSlot(body: slotData);
      emit(CreateTimeSlotSuccess(slot));
    } catch (e) {
      emit(CreateTimeSlotError(e.toString().replaceAll('Exception: ', '')));
      emit(CreateTimeSlotIdle());
    }
  }

  void reset() {
    emit(CreateTimeSlotIdle());
  }
}
