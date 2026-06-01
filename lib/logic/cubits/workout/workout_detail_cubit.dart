import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/workout_model.dart';
import '../../../services/workout_service.dart';

abstract class WorkoutDetailState extends Equatable {
  const WorkoutDetailState();
  @override
  List<Object?> get props => [];
}

class WorkoutDetailInitial extends WorkoutDetailState {}

class WorkoutDetailLoading extends WorkoutDetailState {}

class WorkoutDetailSuccess extends WorkoutDetailState {
  final WorkoutModel workout;
  const WorkoutDetailSuccess(this.workout);
  @override
  List<Object?> get props => [workout];
}

class WorkoutDetailError extends WorkoutDetailState {
  final String message;
  const WorkoutDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

class WorkoutDetailCubit extends Cubit<WorkoutDetailState> {
  final WorkoutService _service;
  final String workoutId;

  WorkoutDetailCubit(this._service, this.workoutId) : super(WorkoutDetailInitial());

  Future<void> fetchWorkoutDetails() async {
    emit(WorkoutDetailLoading());
    try {
      final workout = await _service.getWorkoutById(workoutId: workoutId);
      emit(WorkoutDetailSuccess(workout));
    } catch (e) {
      emit(WorkoutDetailError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
