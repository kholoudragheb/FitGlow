import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/plan_model.dart';
import '../../../services/plan_service.dart';

// States
abstract class CreatePlanState extends Equatable {
  const CreatePlanState();

  @override
  List<Object?> get props => [];
}

class CreatePlanInitial extends CreatePlanState {}

class CreatePlanLoading extends CreatePlanState {}

class CreatePlanSuccess extends CreatePlanState {
  final PlanModel plan;
  const CreatePlanSuccess(this.plan);

  @override
  List<Object?> get props => [plan];
}

class CreatePlanError extends CreatePlanState {
  final String message;
  const CreatePlanError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class CreatePlanCubit extends Cubit<CreatePlanState> {
  final PlanService _planService;

  CreatePlanCubit(this._planService) : super(CreatePlanInitial());

  Future<void> createPlan(PlanCreateRequest request) async {
    emit(CreatePlanLoading());
    try {
      final plan = await _planService.createPlan(request);
      emit(CreatePlanSuccess(plan));
    } catch (e) {
      emit(CreatePlanError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
