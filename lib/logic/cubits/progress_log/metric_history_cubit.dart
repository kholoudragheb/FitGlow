import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/metric_log_model.dart';
import '../../../services/progress_log_service.dart';

// States
abstract class MetricHistoryState extends Equatable {
  const MetricHistoryState();

  @override
  List<Object?> get props => [];
}

class MetricHistoryInitial extends MetricHistoryState {}

class MetricHistoryLoading extends MetricHistoryState {}

class MetricHistorySuccess extends MetricHistoryState {
  final List<MetricLogModel> metrics;
  
  const MetricHistorySuccess(this.metrics);

  @override
  List<Object?> get props => [metrics];
}

class MetricHistoryError extends MetricHistoryState {
  final String message;
  const MetricHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class MetricHistoryCubit extends Cubit<MetricHistoryState> {
  final ProgressLogService _service;

  MetricHistoryCubit(this._service) : super(MetricHistoryInitial());

  Future<void> fetchHistory() async {
    emit(MetricHistoryLoading());
    try {
      final metrics = await _service.getMetricHistory();
      // Sort by date newest first for the list
      metrics.sort((a, b) => b.date.compareTo(a.date));
      emit(MetricHistorySuccess(metrics));
    } catch (e) {
      emit(MetricHistoryError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
