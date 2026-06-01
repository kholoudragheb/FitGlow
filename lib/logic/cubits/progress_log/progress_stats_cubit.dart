import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/progress_stats_model.dart';
import '../../../services/progress_log_service.dart';

// States
abstract class ProgressStatsState extends Equatable {
  const ProgressStatsState();

  @override
  List<Object?> get props => [];
}

class ProgressStatsInitial extends ProgressStatsState {}

class ProgressStatsLoading extends ProgressStatsState {}

class ProgressStatsSuccess extends ProgressStatsState {
  final ProgressStatsModel stats;
  const ProgressStatsSuccess(this.stats);

  @override
  List<Object?> get props => [stats];
}

class ProgressStatsError extends ProgressStatsState {
  final String message;
  const ProgressStatsError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class ProgressStatsCubit extends Cubit<ProgressStatsState> {
  final ProgressLogService _service;

  ProgressStatsCubit(this._service) : super(ProgressStatsInitial());

  Future<void> fetchStats() async {
    emit(ProgressStatsLoading());
    try {
      final stats = await _service.getProgressStats();
      emit(ProgressStatsSuccess(stats));
    } catch (e) {
      emit(ProgressStatsError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
