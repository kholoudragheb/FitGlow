import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/meal_model.dart';
import '../../../services/nutrition_service.dart';

abstract class MealDetailState extends Equatable {
  const MealDetailState();
  @override
  List<Object?> get props => [];
}

class MealDetailInitial extends MealDetailState {}

class MealDetailLoading extends MealDetailState {}

class MealDetailSuccess extends MealDetailState {
  final MealModel meal;
  const MealDetailSuccess(this.meal);
  @override
  List<Object?> get props => [meal];
}

class MealDetailError extends MealDetailState {
  final String message;
  const MealDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

class MealDetailCubit extends Cubit<MealDetailState> {
  final NutritionService _service;
  final String mealId;

  MealDetailCubit(this._service, this.mealId) : super(MealDetailInitial());

  Future<void> fetchMealDetails() async {
    emit(MealDetailLoading());
    try {
      final meal = await _service.getMealById(mealId);
      emit(MealDetailSuccess(meal));
    } catch (e) {
      emit(MealDetailError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
