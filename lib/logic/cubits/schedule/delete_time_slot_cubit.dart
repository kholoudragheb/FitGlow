import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/schedule_service.dart';

abstract class DeleteTimeSlotState extends Equatable {
  const DeleteTimeSlotState();
  @override
  List<Object?> get props => [];
}

class DeleteTimeSlotIdle extends DeleteTimeSlotState {}
class DeleteTimeSlotLoading extends DeleteTimeSlotState {}
class DeleteTimeSlotSuccess extends DeleteTimeSlotState {}
class DeleteTimeSlotError extends DeleteTimeSlotState {
  final String message;
  const DeleteTimeSlotError(this.message);
  @override
  List<Object?> get props => [message];
}

class DeleteTimeSlotCubit extends Cubit<DeleteTimeSlotState> {
  final ScheduleService _service;
  DeleteTimeSlotCubit(this._service) : super(DeleteTimeSlotIdle());

  Future<void> deleteSlot(String slotId) async {
    emit(DeleteTimeSlotLoading());
    try {
      final success = await _service.deleteTimeSlot(slotId: slotId);
      if (success) {
        emit(DeleteTimeSlotSuccess());
      } else {
        emit(const DeleteTimeSlotError("Failed to delete time slot"));
      }
    } catch (e) {
      emit(DeleteTimeSlotError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void reset() {
    emit(DeleteTimeSlotIdle());
  }
}
