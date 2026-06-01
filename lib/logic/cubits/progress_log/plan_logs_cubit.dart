import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/progress_log_model.dart';
import '../../../services/progress_log_service.dart';

abstract class PlanLogsState extends Equatable {
  const PlanLogsState();
  @override
  List<Object?> get props => [];
}

class PlanLogsInitial extends PlanLogsState {}
class PlanLogsLoading extends PlanLogsState {}
class PlanLogsSuccess extends PlanLogsState {
  final List<ProgressLogModel> allLogs;
  final String currentFilter;

  const PlanLogsSuccess(this.allLogs, {this.currentFilter = 'All'});

  List<ProgressLogModel> get filteredLogs {
    if (currentFilter == 'All') return allLogs;
    if (currentFilter == 'Completed') return allLogs.where((l) => l.status == 'completed').toList();
    return allLogs.where((l) => l.type.toLowerCase() == currentFilter.toLowerCase()).toList();
  }

  @override
  List<Object?> get props => [allLogs, currentFilter];
}

class PlanLogsError extends PlanLogsState {
  final String message;
  const PlanLogsError(this.message);
  @override
  List<Object?> get props => [message];
}

class PlanLogsCubit extends Cubit<PlanLogsState> {
  final ProgressLogService _service;
  PlanLogsCubit(this._service) : super(PlanLogsInitial());

  Future<void> fetchLogs(String planId) async {
    final currentState = state;
    String filter = 'All';
    if (currentState is PlanLogsSuccess) {
      filter = currentState.currentFilter;
    }

    emit(PlanLogsLoading());
    try {
      final logs = await _service.getLogsByPlan(planId: planId);
      // Sort newest first
      logs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(PlanLogsSuccess(logs, currentFilter: filter));
    } catch (e) {
      emit(PlanLogsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void changeFilter(String newFilter) {
    final currentState = state;
    if (currentState is PlanLogsSuccess) {
      emit(PlanLogsSuccess(currentState.allLogs, currentFilter: newFilter));
    }
  }
}
