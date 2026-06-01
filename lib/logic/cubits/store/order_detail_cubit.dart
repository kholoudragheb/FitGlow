import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/order_model.dart';
import '../../../services/store_service.dart';

abstract class OrderDetailState extends Equatable {
  const OrderDetailState();
  @override
  List<Object?> get props => [];
}

class OrderDetailInitial extends OrderDetailState {}

class OrderDetailLoading extends OrderDetailState {}

class OrderDetailSuccess extends OrderDetailState {
  final OrderModel order;
  const OrderDetailSuccess(this.order);
  @override
  List<Object?> get props => [order];
}

class OrderDetailError extends OrderDetailState {
  final String message;
  const OrderDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

class OrderDetailCubit extends Cubit<OrderDetailState> {
  final StoreService _service;

  OrderDetailCubit(this._service) : super(OrderDetailInitial());

  Future<void> fetchOrderDetail(String orderId) async {
    emit(OrderDetailLoading());
    try {
      final order = await _service.getOrderById(orderId: orderId);
      emit(OrderDetailSuccess(order));
    } catch (e) {
      emit(OrderDetailError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
