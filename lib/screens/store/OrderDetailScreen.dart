import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../../logic/cubits/store/order_detail_cubit.dart';
import '../../../models/order_model.dart';
import '../../../services/store_service.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderDetailCubit(StoreService())..fetchOrderDetail(orderId),
      child: Scaffold(
        backgroundColor: const Color(0xFF111111),
        appBar: AppBar(
          backgroundColor: const Color(0xFF111111),
          elevation: 0,
          title: const Text("Order Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<OrderDetailCubit, OrderDetailState>(
          builder: (context, state) {
            if (state is OrderDetailLoading) {
              return _buildShimmerLoading();
            } else if (state is OrderDetailError) {
              return _buildErrorState(context, state.message);
            } else if (state is OrderDetailSuccess) {
              return _buildContent(state.order);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(OrderModel order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderHeader(order),
          const SizedBox(height: 32),
          _buildStatusTimeline(order.status),
          const SizedBox(height: 32),
          _buildSectionTitle("Shipping Address"),
          const SizedBox(height: 16),
          _buildAddressCard(order.shippingAddress),
          const SizedBox(height: 32),
          _buildSectionTitle("Items"),
          const SizedBox(height: 16),
          ...order.items.map((item) => _buildItemCard(item)),
          const SizedBox(height: 32),
          _buildPriceSummary(order),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildOrderHeader(OrderModel order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order #${order.id.substring(order.id.length - 8).toUpperCase()}",
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMMM dd, yyyy • hh:mm a').format(order.createdAt),
              style: const TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFD0FD3E).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            order.status.toUpperCase(),
            style: const TextStyle(color: Color(0xFFD0FD3E), fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTimeline(String currentStatus) {
    final statuses = ['pending', 'confirmed', 'shipped', 'delivered'];
    final currentIndex = statuses.indexOf(currentStatus.toLowerCase());

    return Row(
      children: List.generate(statuses.length, (index) {
        final bool isCompleted = index <= currentIndex;
        final bool isLast = index == statuses.length - 1;

        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted ? const Color(0xFFD0FD3E) : Colors.white10,
                      shape: BoxShape.circle,
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.black)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    statuses[index].toUpperCase(),
                    style: TextStyle(
                      color: isCompleted ? Colors.white : Colors.white24,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 24),
                    color: isCompleted ? const Color(0xFFD0FD3E) : Colors.white10,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildAddressCard(dynamic address) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(address.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text("${address.street}, ${address.city}", style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text("${address.state}, ${address.zipCode}, ${address.country}", style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.phone_outlined, color: Colors.white38, size: 16),
              const SizedBox(width: 8),
              Text(address.phone, style: const TextStyle(color: Colors.white38, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 60,
              height: 60,
              color: Colors.black26,
              child: item.image.isNotEmpty
                  ? Image.network(item.image, fit: BoxFit.cover)
                  : const Icon(Icons.inventory_2_outlined, color: Colors.white10),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("Qty: ${item.quantity}", style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          Text("${item.price} EGP", style: const TextStyle(color: Color(0xFFD0FD3E), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Total Paid", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          Text("${order.totalPrice} EGP", style: const TextStyle(color: Color(0xFFD0FD3E), fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Shimmer.fromColors(
        baseColor: Colors.white.withValues(alpha: 0.05),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 60, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 32),
            Container(height: 40, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
            const SizedBox(height: 32),
            Container(height: 120, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 32),
            Container(height: 80, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<OrderDetailCubit>().fetchOrderDetail(orderId),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD0FD3E)),
              child: const Text("RETRY", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
