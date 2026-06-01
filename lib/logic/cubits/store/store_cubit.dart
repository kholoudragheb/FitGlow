import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/product_model.dart';
import '../../../services/store_service.dart';

abstract class StoreState extends Equatable {
  const StoreState();
  @override
  List<Object?> get props => [];
}

class StoreInitial extends StoreState {}

class StoreLoading extends StoreState {}

class StoreSuccess extends StoreState {
  final List<ProductModel> products;
  const StoreSuccess(this.products);
  @override
  List<Object?> get props => [products];
}

class StoreError extends StoreState {
  final String message;
  const StoreError(this.message);
  @override
  List<Object?> get props => [message];
}

class StoreCubit extends Cubit<StoreState> {
  final StoreService _service;

  StoreCubit(this._service) : super(StoreInitial());

  Future<void> fetchProducts({String? category, String? search}) async {
    emit(StoreLoading());
    try {
      final products = await _service.getAllProducts(category: category, search: search);
      emit(StoreSuccess(products));
    } catch (e) {
      emit(StoreError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
