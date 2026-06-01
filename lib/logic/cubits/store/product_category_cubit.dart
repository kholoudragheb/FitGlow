import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/category_model.dart';
import '../../../services/store_service.dart';

abstract class ProductCategoryState extends Equatable {
  const ProductCategoryState();
  @override
  List<Object?> get props => [];
}

class ProductCategoryInitial extends ProductCategoryState {}

class ProductCategoryLoading extends ProductCategoryState {}

class ProductCategorySuccess extends ProductCategoryState {
  final List<CategoryModel> categories;
  const ProductCategorySuccess(this.categories);
  @override
  List<Object?> get props => [categories];
}

class ProductCategoryError extends ProductCategoryState {
  final String message;
  const ProductCategoryError(this.message);
  @override
  List<Object?> get props => [message];
}

class ProductCategoryCubit extends Cubit<ProductCategoryState> {
  final StoreService _service;

  ProductCategoryCubit(this._service) : super(ProductCategoryInitial());

  Future<void> fetchCategories() async {
    emit(ProductCategoryLoading());
    try {
      final categories = await _service.getProductCategories();
      // Insert 'All' at the beginning
      final allCategories = [
        CategoryModel(id: 'all', name: 'All'),
        ...categories,
      ];
      emit(ProductCategorySuccess(allCategories));
    } catch (e) {
      emit(ProductCategoryError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
