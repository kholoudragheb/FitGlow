import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/meal_model.dart';
import '../../../services/nutrition_service.dart';

abstract class NutritionState extends Equatable {
  const NutritionState();
  @override
  List<Object?> get props => [];
}

class NutritionInitial extends NutritionState {}

class NutritionLoading extends NutritionState {}

class NutritionSuccess extends NutritionState {
  final List<MealModel> meals;
  const NutritionSuccess(this.meals);
  @override
  List<Object?> get props => [meals];
}

class NutritionError extends NutritionState {
  final String message;
  const NutritionError(this.message);
  @override
  List<Object?> get props => [message];
}

class NutritionCubit extends Cubit<NutritionState> {
  final NutritionService _service;

  NutritionCubit(this._service) : super(NutritionInitial());

  Future<void> fetchMeals({
    String? tags,
    String? search,
    String? mealType,
  }) async {
    emit(NutritionLoading());
    try {
      final meals = await _service.getAllMeals(
        tags: tags,
        search: search,
        mealType: mealType,
      );
      emit(NutritionSuccess(meals));
    } catch (e) {
      emit(NutritionError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
