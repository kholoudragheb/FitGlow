import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/progress_log_model.dart';
import '../../../services/progress_log_service.dart';

// States
abstract class ProgressLogState extends Equatable {
  const ProgressLogState();

  @override
  List<Object?> get props => [];
}

class ProgressLogInitial extends ProgressLogState {}

class ProgressLogLoading extends ProgressLogState {}

class ProgressLogSuccess extends ProgressLogState {
  final ProgressLogModel log;
  const ProgressLogSuccess(this.log);

  @override
  List<Object?> get props => [log];
}

class ProgressLogError extends ProgressLogState {
  final String message;
  const ProgressLogError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class ProgressLogCubit extends Cubit<ProgressLogState> {
  final ProgressLogService _service;

  ProgressLogCubit(this._service) : super(ProgressLogInitial());

  Future<void> createLog(Map<String, dynamic> body) async {
    emit(ProgressLogLoading());
    try {
      final log = await _service.createProgressLog(body);
      emit(ProgressLogSuccess(log));
    } catch (e) {
      emit(ProgressLogError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
