import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/order_model.dart';
import '../../../services/store_service.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();
  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersSuccess extends OrdersState {
  final List<OrderModel> orders;
  const OrdersSuccess(this.orders);
  @override
  List<Object?> get props => [orders];
}

class OrdersError extends OrdersState {
  final String message;
  const OrdersError(this.message);
  @override
  List<Object?> get props => [message];
}

class OrdersCubit extends Cubit<OrdersState> {
  final StoreService _service;

  OrdersCubit(this._service) : super(OrdersInitial());

  Future<void> fetchMyOrders() async {
    emit(OrdersLoading());
    try {
      final orders = await _service.getMyOrders();
      // Sort by newest first
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(OrdersSuccess(orders));
    } catch (e) {
      emit(OrdersError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
