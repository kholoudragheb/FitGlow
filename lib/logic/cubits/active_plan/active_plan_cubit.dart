import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/plan_model.dart';
import '../../../services/plan_service.dart';

// States
abstract class ActivePlanState extends Equatable {
  const ActivePlanState();

  @override
  List<Object?> get props => [];
}

class ActivePlanInitial extends ActivePlanState {}

class ActivePlanLoading extends ActivePlanState {}

class ActivePlanSuccess extends ActivePlanState {
  final PlanModel? plan;
  const ActivePlanSuccess(this.plan);

  @override
  List<Object?> get props => [plan];
}

class ActivePlanError extends ActivePlanState {
  final String message;
  const ActivePlanError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class ActivePlanCubit extends Cubit<ActivePlanState> {
  final PlanService _planService;

  ActivePlanCubit(this._planService) : super(ActivePlanInitial());

  Future<void> fetchActivePlan() async {
    emit(ActivePlanLoading());
    try {
      final plan = await _planService.getActivePlan();
      emit(ActivePlanSuccess(plan));
    } catch (e) {
      emit(ActivePlanError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
