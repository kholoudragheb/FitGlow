import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../models/time_slot_model.dart';
import '../../../services/schedule_service.dart';

abstract class CoachAvailabilityState extends Equatable {
  const CoachAvailabilityState();
  @override
  List<Object?> get props => [];
}

class CoachAvailabilityIdle extends CoachAvailabilityState {}
class CoachAvailabilityLoading extends CoachAvailabilityState {}
class CoachAvailabilitySuccess extends CoachAvailabilityState {
  final List<TimeSlotModel> allSlots;
  final List<TimeSlotModel> slotsForSelectedDate;
  final DateTime selectedDate;

  const CoachAvailabilitySuccess({
    required this.allSlots,
    required this.slotsForSelectedDate,
    required this.selectedDate,
  });

  @override
  List<Object?> get props => [allSlots, slotsForSelectedDate, selectedDate];
}
class CoachAvailabilityError extends CoachAvailabilityState {
  final String message;
  const CoachAvailabilityError(this.message);
  @override
  List<Object?> get props => [message];
}

class CoachAvailabilityCubit extends Cubit<CoachAvailabilityState> {
  final ScheduleService _service;
  CoachAvailabilityCubit(this._service) : super(CoachAvailabilityIdle());

  Future<void> fetchAvailability(String coachId, {DateTime? initialDate}) async {
    emit(CoachAvailabilityLoading());
    
    // Fetch next 14 days by default
    final startDate = DateTime.now();
    final endDate = startDate.add(const Duration(days: 14));
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    try {
      final slots = await _service.getCoachAvailability(
        coachId: coachId,
        startDate: formatter.format(startDate),
        endDate: formatter.format(endDate),
      );

      final dateToSelect = initialDate ?? startDate;
      
      _emitSuccessState(slots, dateToSelect);
    } catch (e) {
      emit(CoachAvailabilityError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void selectDate(DateTime date) {
    if (state is CoachAvailabilitySuccess) {
      final currentState = state as CoachAvailabilitySuccess;
      _emitSuccessState(currentState.allSlots, date);
    }
  }

  void _emitSuccessState(List<TimeSlotModel> allSlots, DateTime selectedDate) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String selectedDateStr = formatter.format(selectedDate);
    final int selectedDayOfWeek = selectedDate.weekday == 7 ? 0 : selectedDate.weekday;

    final filteredSlots = allSlots.where((slot) {
      // If the backend returns a specific date, match it
      if (slot.date != null && slot.date!.isNotEmpty) {
        return slot.date == selectedDateStr;
      }
      // Otherwise, match by day of week
      return slot.dayOfWeek == selectedDayOfWeek;
    }).toList();

    // Sort by start time
    filteredSlots.sort((a, b) => a.startTime.compareTo(b.startTime));

    emit(CoachAvailabilitySuccess(
      allSlots: allSlots,
      slotsForSelectedDate: filteredSlots,
      selectedDate: selectedDate,
    ));
  }
}
