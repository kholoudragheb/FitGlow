import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/order_model.dart';
import '../../../services/store_service.dart';

abstract class CheckoutState extends Equatable {
  const CheckoutState();
  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutSuccess extends CheckoutState {
  final OrderModel order;
  const CheckoutSuccess(this.order);
  @override
  List<Object?> get props => [order];
}

class CheckoutError extends CheckoutState {
  final String message;
  const CheckoutError(this.message);
  @override
  List<Object?> get props => [message];
}

class CheckoutCubit extends Cubit<CheckoutState> {
  final StoreService _service;

  CheckoutCubit(this._service) : super(CheckoutInitial());

  Future<void> processCheckout(ShippingAddressModel address) async {
    emit(CheckoutLoading());
    try {
      final order = await _service.checkoutCart(shippingAddress: address);
      emit(CheckoutSuccess(order));
    } catch (e) {
      emit(CheckoutError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
