import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/goal_model.dart';
import '../../../services/progress_log_service.dart';

// --- CREATE GOAL CUBIT ---

abstract class CreateGoalState extends Equatable {
  const CreateGoalState();
  @override
  List<Object?> get props => [];
}

class CreateGoalInitial extends CreateGoalState {}
class CreateGoalLoading extends CreateGoalState {}
class CreateGoalSuccess extends CreateGoalState {
  final GoalModel goal;
  const CreateGoalSuccess(this.goal);
  @override
  List<Object?> get props => [goal];
}
class CreateGoalError extends CreateGoalState {
  final String message;
  const CreateGoalError(this.message);
  @override
  List<Object?> get props => [message];
}

class CreateGoalCubit extends Cubit<CreateGoalState> {
  final ProgressLogService _service;
  CreateGoalCubit(this._service) : super(CreateGoalInitial());

  Future<void> createGoal(Map<String, dynamic> body) async {
    emit(CreateGoalLoading());
    try {
      final goal = await _service.createGoal(body);
      emit(CreateGoalSuccess(goal));
    } catch (e) {
      emit(CreateGoalError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

// --- GOALS LIST CUBIT ---

abstract class GoalsState extends Equatable {
  const GoalsState();
  @override
  List<Object?> get props => [];
}

class GoalsInitial extends GoalsState {}
class GoalsLoading extends GoalsState {}
class GoalsSuccess extends GoalsState {
  final List<GoalModel> allGoals;
  final String filter; // 'All', 'Active', 'Completed', 'Expired'
  final String sortBy; // 'Deadline', 'Progress', 'Newest'

  const GoalsSuccess(this.allGoals, {this.filter = 'All', this.sortBy = 'Deadline'});

  List<GoalModel> get filteredGoals {
    List<GoalModel> filtered = List.from(allGoals);

    // Apply Filter
    if (filter == 'Active') {
      filtered = filtered.where((g) => g.isActive).toList();
    } else if (filter == 'Completed') {
      filtered = filtered.where((g) => g.isCompleted).toList();
    } else if (filter == 'Expired') {
      filtered = filtered.where((g) => g.isExpired).toList();
    }

    // Apply Sort
    if (sortBy == 'Deadline') {
      filtered.sort((a, b) => a.deadline.compareTo(b.deadline));
    } else if (sortBy == 'Progress') {
      filtered.sort((a, b) => b.progressPercentage.compareTo(a.progressPercentage));
    } else if (sortBy == 'Newest') {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return filtered;
  }

  @override
  List<Object?> get props => [allGoals, filter, sortBy];
}

class GoalsError extends GoalsState {
  final String message;
  const GoalsError(this.message);

  @override
  List<Object?> get props => [message];
}

class GoalsCubit extends Cubit<GoalsState> {
  final ProgressLogService _service;
  GoalsCubit(this._service) : super(GoalsInitial());

  Future<void> fetchGoals() async {
    final currentState = state;
    String currentFilter = 'All';
    String currentSort = 'Deadline';
    
    if (currentState is GoalsSuccess) {
      currentFilter = currentState.filter;
      currentSort = currentState.sortBy;
    }

    emit(GoalsLoading());
    try {
      final goals = await _service.getGoals();
      emit(GoalsSuccess(goals, filter: currentFilter, sortBy: currentSort));
    } catch (e) {
      emit(GoalsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void changeFilter(String newFilter) {
    final currentState = state;
    if (currentState is GoalsSuccess) {
      emit(GoalsSuccess(currentState.allGoals, filter: newFilter, sortBy: currentState.sortBy));
    }
  }

  void changeSort(String newSort) {
    final currentState = state;
    if (currentState is GoalsSuccess) {
      emit(GoalsSuccess(currentState.allGoals, filter: currentState.filter, sortBy: newSort));
    }
  }

  Future<void> deleteGoal(String id) async {
    try {
      await _service.deleteGoal(id);
      fetchGoals(); // Refresh list after deletion
    } catch (e) {
      emit(GoalsError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

// --- UPDATE GOAL PROGRESS CUBIT ---

abstract class UpdateGoalState extends Equatable {
  const UpdateGoalState();
  @override
  List<Object?> get props => [];
}

class UpdateGoalInitial extends UpdateGoalState {}
class UpdateGoalLoading extends UpdateGoalState {}
class UpdateGoalSuccess extends UpdateGoalState {
  final GoalModel goal;
  const UpdateGoalSuccess(this.goal);
  @override
  List<Object?> get props => [goal];
}
class UpdateGoalError extends UpdateGoalState {
  final String message;
  const UpdateGoalError(this.message);
  @override
  List<Object?> get props => [message];
}

class UpdateGoalCubit extends Cubit<UpdateGoalState> {
  final ProgressLogService _service;
  UpdateGoalCubit(this._service) : super(UpdateGoalInitial());

  Future<void> updateProgress(String goalId, double newValue) async {
    emit(UpdateGoalLoading());
    try {
      final goal = await _service.updateGoalProgress(
        goalId: goalId,
        currentValue: newValue,
      );
      emit(UpdateGoalSuccess(goal));
    } catch (e) {
      emit(UpdateGoalError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
