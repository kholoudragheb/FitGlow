import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../logic/cubits/store/cart_cubit.dart';
import '../../../models/cart_model.dart';
import 'CheckoutScreen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartCubit>().fetchCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        title: const Text(
          "My Cart",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state is CartSuccess && state.cart.items.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
                  onPressed: () => _showClearConfirmationDialog(context),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 8),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<CartCubit, CartState>(
        listener: (context, state) {
          if (state is CartError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
            );
          } else if (state is CartSuccess) {
            // Optional: Show snackbar for removal or update
            // ScaffoldMessenger.of(context).showSnackBar(
            //   const SnackBar(content: Text("Cart updated")),
            // );
          }
        },
        child: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            if (state is CartLoading) {
              return _buildShimmerLoading();
            } else if (state is CartError && state.message.isNotEmpty && state.message != 'Cart not found') {
              return _buildErrorState(state.message);
            }
            
            // Check for success or updating state
            if (state is CartSuccess || state is CartUpdating) {
              CartModel? cart;
              if (state is CartSuccess) cart = state.cart;
              if (state is CartUpdating) {
                final currentState = context.read<CartCubit>().state;
                if (currentState is CartSuccess) cart = currentState.cart;
              }

              if (cart == null || cart.items.isEmpty) {
                return _buildEmptyState();
              }
              return _buildCartContent(cart);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartSuccess && state.cart.items.isNotEmpty) {
            return _buildBottomSummary(state.cart);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCartContent(CartModel cart) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: cart.items.length,
      itemBuilder: (context, index) => _buildCartItem(cart.items[index]),
    );
  }

  Widget _buildCartItem(CartItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              height: 80,
              color: Colors.grey[900],
              child: item.productImage.isNotEmpty
                  ? Image.network(item.productImage, fit: BoxFit.cover)
                  : const Icon(Icons.inventory_2_outlined, color: Colors.white12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "${item.price} EGP",
                  style: const TextStyle(color: Color(0xFFD0FD3E), fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildQuantitySelector(item),
                    BlocBuilder<CartCubit, CartState>(
                      builder: (context, state) {
                        final bool isRemoving = state is CartUpdating && state.productId == item.productId;
                        return isRemoving
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent)),
                            )
                          : IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                              onPressed: (state is CartUpdating) ? null : () {
                                context.read<CartCubit>().removeFromCart(productId: item.productId);
                              },
                            );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(CartItemModel item) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final bool isUpdating = state is CartUpdating && state.productId == item.productId;
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _buildQtyBtn(
                Icons.remove, 
                isUpdating || item.quantity <= 1 ? null : () {
                  context.read<CartCubit>().updateCartItemQuantity(
                    productId: item.productId, 
                    quantity: item.quantity - 1
                  );
                }
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: isUpdating 
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD0FD3E)))
                  : Text(
                      "${item.quantity}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
              ),
              _buildQtyBtn(
                Icons.add, 
                isUpdating ? null : () {
                  context.read<CartCubit>().updateCartItemQuantity(
                    productId: item.productId, 
                    quantity: item.quantity + 1
                  );
                }
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, color: onTap == null ? Colors.white24 : Colors.white, size: 16),
      ),
    );
  }

  Widget _buildBottomSummary(CartModel cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummaryRow("Subtotal", "${cart.subtotal} EGP"),
          const SizedBox(height: 12),
          _buildSummaryRow("Discount", "-${cart.discount} EGP", color: const Color(0xFFD0FD3E)),
          const SizedBox(height: 12),
          _buildSummaryRow("Tax", "${cart.tax} EGP"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white10),
          ),
          _buildSummaryRow("Total", "${cart.totalPrice} EGP", isTotal: true),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CheckoutScreen(cart: cart)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD0FD3E),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("PROCEED TO CHECKOUT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: isTotal ? Colors.white : Colors.white38, fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal),
        ),
        Text(
          value,
          style: TextStyle(color: color ?? Colors.white, fontSize: isTotal ? 22 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 4,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Shimmer.fromColors(
          baseColor: Colors.white.withValues(alpha: 0.05),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 24),
          const Text("Your cart is empty", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text("Start shopping to add items!", style: TextStyle(color: Colors.white38, fontSize: 14)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD0FD3E),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("EXPLORE STORE", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<CartCubit>().fetchCart(),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD0FD3E)),
            child: const Text("Retry", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Clear Cart", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to remove all items from your cart?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("CANCEL", style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CartCubit>().clearCart();
            },
            child: const Text("CLEAR ALL", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
