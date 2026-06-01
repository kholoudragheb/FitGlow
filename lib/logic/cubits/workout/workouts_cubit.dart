import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/workout_model.dart';
import '../../../services/workout_service.dart';

abstract class WorkoutsState extends Equatable {
  const WorkoutsState();
  @override
  List<Object?> get props => [];
}

class WorkoutsInitial extends WorkoutsState {}

class WorkoutsLoading extends WorkoutsState {}

class WorkoutsSuccess extends WorkoutsState {
  final List<WorkoutModel> workouts;
  const WorkoutsSuccess(this.workouts);
  @override
  List<Object?> get props => [workouts];
}

class WorkoutsError extends WorkoutsState {
  final String message;
  const WorkoutsError(this.message);
  @override
  List<Object?> get props => [message];
}

class WorkoutsCubit extends Cubit<WorkoutsState> {
  final WorkoutService _service;

  WorkoutsCubit(this._service) : super(WorkoutsInitial());

  Future<void> fetchWorkouts({
    String? difficulty,
    String? tags,
    String? search,
  }) async {
    emit(WorkoutsLoading());
    try {
      final workouts = await _service.getAllWorkouts(
        difficulty: difficulty,
        tags: tags,
        search: search,
      );
      emit(WorkoutsSuccess(workouts));
    } catch (e) {
      emit(WorkoutsError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
