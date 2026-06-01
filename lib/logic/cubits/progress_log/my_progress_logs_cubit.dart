import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/progress_log_model.dart';
import '../../../services/progress_log_service.dart';

// States
abstract class MyProgressLogsState extends Equatable {
  const MyProgressLogsState();

  @override
  List<Object?> get props => [];
}

class MyProgressLogsInitial extends MyProgressLogsState {}

class MyProgressLogsLoading extends MyProgressLogsState {}

class MyProgressLogsSuccess extends MyProgressLogsState {
  final List<ProgressLogModel> logs;
  final String currentFilter;
  
  const MyProgressLogsSuccess(this.logs, {this.currentFilter = 'All'});

  List<ProgressLogModel> get filteredLogs {
    if (currentFilter == 'All') return logs;
    return logs.where((log) => log.type.toLowerCase() == currentFilter.toLowerCase()).toList();
  }

  @override
  List<Object?> get props => [logs, currentFilter];
}

class MyProgressLogsError extends MyProgressLogsState {
  final String message;
  const MyProgressLogsError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class MyProgressLogsCubit extends Cubit<MyProgressLogsState> {
  final ProgressLogService _service;

  MyProgressLogsCubit(this._service) : super(MyProgressLogsInitial());

  Future<void> fetchLogs() async {
    emit(MyProgressLogsLoading());
    try {
      final logs = await _service.getMyProgressLogs();
      // Sort by date newest first
      logs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(MyProgressLogsSuccess(logs));
    } catch (e) {
      emit(MyProgressLogsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void filterLogs(String category) {
    if (state is MyProgressLogsSuccess) {
      final currentState = state as MyProgressLogsSuccess;
      emit(MyProgressLogsSuccess(currentState.logs, currentFilter: category));
    }
  }
}
