import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/product_model.dart';
import '../../../services/store_service.dart';

abstract class ProductDetailState extends Equatable {
  const ProductDetailState();
  @override
  List<Object?> get props => [];
}

class ProductDetailInitial extends ProductDetailState {}

class ProductDetailLoading extends ProductDetailState {}

class ProductDetailSuccess extends ProductDetailState {
  final ProductModel product;
  const ProductDetailSuccess(this.product);
  @override
  List<Object?> get props => [product];
}

class ProductDetailError extends ProductDetailState {
  final String message;
  const ProductDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

class ProductDetailCubit extends Cubit<ProductDetailState> {
  final StoreService _service;
  final String productId;

  ProductDetailCubit(this._service, this.productId) : super(ProductDetailInitial());

  Future<void> fetchProductDetails() async {
    emit(ProductDetailLoading());
    try {
      final product = await _service.getProductById(productId);
      emit(ProductDetailSuccess(product));
    } catch (e) {
      emit(ProductDetailError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
