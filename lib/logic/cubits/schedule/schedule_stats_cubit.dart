import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/schedule_stats_model.dart';
import '../../../services/schedule_service.dart';

abstract class ScheduleStatsState extends Equatable {
  const ScheduleStatsState();
  @override
  List<Object?> get props => [];
}

class ScheduleStatsInitial extends ScheduleStatsState {}

class ScheduleStatsLoading extends ScheduleStatsState {}

class ScheduleStatsSuccess extends ScheduleStatsState {
  final ScheduleStatsModel stats;
  const ScheduleStatsSuccess(this.stats);
  @override
  List<Object?> get props => [stats];
}

class ScheduleStatsError extends ScheduleStatsState {
  final String message;
  const ScheduleStatsError(this.message);
  @override
  List<Object?> get props => [message];
}

class ScheduleStatsCubit extends Cubit<ScheduleStatsState> {
  final ScheduleService _service;
  ScheduleStatsCubit(this._service) : super(ScheduleStatsInitial());

  Future<void> fetchStats() async {
    emit(ScheduleStatsLoading());
    try {
      final stats = await _service.getScheduleStats();
      emit(ScheduleStatsSuccess(stats));
    } catch (e) {
      emit(ScheduleStatsError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
