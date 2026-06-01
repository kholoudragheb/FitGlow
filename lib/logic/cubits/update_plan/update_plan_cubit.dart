import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/plan_model.dart';
import '../../../services/plan_service.dart';

// States
abstract class UpdatePlanState extends Equatable {
  const UpdatePlanState();

  @override
  List<Object?> get props => [];
}

class UpdatePlanInitial extends UpdatePlanState {}

class UpdatePlanLoading extends UpdatePlanState {}

class UpdatePlanSuccess extends UpdatePlanState {
  final PlanModel plan;
  const UpdatePlanSuccess(this.plan);

  @override
  List<Object?> get props => [plan];
}

class UpdatePlanError extends UpdatePlanState {
  final String message;
  const UpdatePlanError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class UpdatePlanCubit extends Cubit<UpdatePlanState> {
  final PlanService _planService;

  UpdatePlanCubit(this._planService) : super(UpdatePlanInitial());

  Future<void> updatePlan(String planId, Map<String, dynamic> body) async {
    emit(UpdatePlanLoading());
    try {
      final plan = await _planService.updatePlan(planId: planId, body: body);
      emit(UpdatePlanSuccess(plan));
    } catch (e) {
      emit(UpdatePlanError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
