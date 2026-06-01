import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/metric_log_model.dart';
import '../../../services/progress_log_service.dart';

// States
abstract class MetricLogState extends Equatable {
  const MetricLogState();

  @override
  List<Object?> get props => [];
}

class MetricLogInitial extends MetricLogState {}

class MetricLogLoading extends MetricLogState {}

class MetricLogSuccess extends MetricLogState {
  final MetricLogModel metric;
  const MetricLogSuccess(this.metric);

  @override
  List<Object?> get props => [metric];
}

class MetricLogError extends MetricLogState {
  final String message;
  const MetricLogError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class MetricLogCubit extends Cubit<MetricLogState> {
  final ProgressLogService _service;

  MetricLogCubit(this._service) : super(MetricLogInitial());

  Future<void> logMetrics(Map<String, dynamic> body) async {
    emit(MetricLogLoading());
    try {
      final metric = await _service.logMetrics(body);
      emit(MetricLogSuccess(metric));
    } catch (e) {
      emit(MetricLogError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
