import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/progress_log_model.dart';
import '../../../services/progress_log_service.dart';

abstract class LogDetailsState extends Equatable {
  const LogDetailsState();
  @override
  List<Object?> get props => [];
}

class LogDetailsInitial extends LogDetailsState {}
class LogDetailsLoading extends LogDetailsState {}
class LogDetailsSuccess extends LogDetailsState {
  final ProgressLogModel log;
  const LogDetailsSuccess(this.log);
  @override
  List<Object?> get props => [log];
}
class LogDetailsError extends LogDetailsState {
  final String message;
  const LogDetailsError(this.message);
  @override
  List<Object?> get props => [message];
}

class LogDetailsCubit extends Cubit<LogDetailsState> {
  final ProgressLogService _service;
  LogDetailsCubit(this._service) : super(LogDetailsInitial());

  Future<void> fetchLogDetails(String logId) async {
    emit(LogDetailsLoading());
    try {
      final log = await _service.getLogById(logId: logId);
      emit(LogDetailsSuccess(log));
    } catch (e) {
      emit(LogDetailsError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
