import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/cart_model.dart';
import '../../../services/store_service.dart';

abstract class CartState extends Equatable {
  const CartState();
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartAdding extends CartState {}
class CartClearing extends CartState {}

class CartUpdating extends CartState {
  final String productId;
  const CartUpdating(this.productId);
  @override
  List<Object?> get props => [productId];
}

class CartSuccess extends CartState {
  final CartModel cart;
  const CartSuccess(this.cart);
  @override
  List<Object?> get props => [cart];
}

class CartError extends CartState {
  final String message;
  const CartError(this.message);
  @override
  List<Object?> get props => [message];
}

class CartCubit extends Cubit<CartState> {
  final StoreService _service;

  CartCubit(this._service) : super(CartInitial());

  Future<void> fetchCart() async {
    emit(CartLoading());
    try {
      final cart = await _service.getCart();
      emit(CartSuccess(cart));
    } catch (e) {
      emit(CartError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> addToCart({required String productId, int quantity = 1}) async {
    final currentState = state;
    CartModel? previousCart;
    if (currentState is CartSuccess) {
      previousCart = currentState.cart;
    }

    emit(CartAdding());
    try {
      final updatedCart = await _service.addToCart(productId: productId, quantity: quantity);
      emit(CartSuccess(updatedCart));
    } catch (e) {
      emit(CartError(e.toString().replaceAll('Exception: ', '')));
      // Rollback to previous cart if it existed
      if (previousCart != null) {
        emit(CartSuccess(previousCart));
      }
    }
  }

  Future<void> updateCartItemQuantity({required String productId, required int quantity}) async {
    if (quantity < 1) return;

    final currentState = state;
    CartModel? previousCart;
    if (currentState is CartSuccess) {
      previousCart = currentState.cart;
    }

    emit(CartUpdating(productId));
    try {
      final updatedCart = await _service.updateCartItem(productId: productId, quantity: quantity);
      emit(CartSuccess(updatedCart));
    } catch (e) {
      emit(CartError(e.toString().replaceAll('Exception: ', '')));
      if (previousCart != null) {
        emit(CartSuccess(previousCart));
      }
    }
  }

  Future<void> removeFromCart({required String productId}) async {
    final currentState = state;
    CartModel? previousCart;
    if (currentState is CartSuccess) {
      previousCart = currentState.cart;
    }

    emit(CartUpdating(productId));
    try {
      final updatedCart = await _service.removeFromCart(productId: productId);
      emit(CartSuccess(updatedCart));
    } catch (e) {
      emit(CartError(e.toString().replaceAll('Exception: ', '')));
      if (previousCart != null) {
        emit(CartSuccess(previousCart));
      }
    }
  }

  Future<void> clearCart() async {
    emit(CartClearing());
    try {
      final updatedCart = await _service.clearCart();
      emit(CartSuccess(updatedCart));
    } catch (e) {
      emit(CartError(e.toString().replaceAll('Exception: ', '')));
      // If error occurs, we should probably fetch the cart again to be safe
      fetchCart();
    }
  }
}
