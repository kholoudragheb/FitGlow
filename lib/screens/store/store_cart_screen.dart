import 'package:flutter/material.dart';
import 'package:fit_app/utils/store_styles.dart';
import 'package:fit_app/screens/store/store_checkout_screen.dart';

class StoreCartScreen extends StatefulWidget {
  const StoreCartScreen({super.key});

  @override
  State<StoreCartScreen> createState() => _StoreCartScreenState();
}

class _StoreCartScreenState extends State<StoreCartScreen> {
  // Mock cart items
  final List<Map<String, dynamic>> _cartItems = [
    {
      'name': 'Optimum Nutrition Gold Standard Whey',
      'image': 'lib/assets/images/store/product_combat.png',
      'price': 50,
      'quantity': 1,
      'variant': 'Rich Chocolate, 2 lbs',
      'rating': 4.5,
      'reviews': 130,
    },
    {
      'name': 'Neoprene Coated Dumbbell',
      'image': 'lib/assets/images/store/product_dumbbells.png',
      'price': 100,
      'quantity': 1,
      'variant': '10 Kg, Pink',
      'rating': 4.5,
      'reviews': 130,
    },
  ];

  String _discountCode = '';
  double _discount = 0;

  double get _subtotal => _cartItems.fold(
      0, (sum, item) => sum + (item['price'] as int) * (item['quantity'] as int));

  double get _total => _subtotal - _discount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoreColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _cartItems.isEmpty ? _buildEmptyCart() : _buildCartContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: StoreColors.cardBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: StoreColors.border),
              ),
              child: const Center(
                child: Icon(Icons.arrow_back_ios_new, color: StoreColors.textWhite, size: 16),
              ),
            ),
          ),
          const Expanded(
            child: Text('Cart', style: StoreTextStyles.title, textAlign: TextAlign.center),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Cart icon matching Figma: 80px cart in circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: StoreColors.cardBackground,
              shape: BoxShape.circle,
              border: Border.all(color: StoreColors.border),
            ),
            child: const Center(
              child: Icon(
                Icons.shopping_cart_outlined,
                color: StoreColors.primary,
                size: 80,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No items in your cart',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Color(0xFF757575),
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 48,
              width: 200,
              decoration: BoxDecoration(
                color: StoreColors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Text('Browse Store', style: StoreTextStyles.button),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cart items
          ...List.generate(_cartItems.length, (index) => _buildCartItem(index)),
          const SizedBox(height: 24),
          // Discount code
          _buildDiscountRow(),
          const SizedBox(height: 24),
          // Summary
          _buildSummary(),
          const SizedBox(height: 24),
          // Checkout button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StoreCheckoutScreen()),
              );
            },
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: StoreColors.primary,
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Center(
                child: Text('Checkout', style: StoreTextStyles.button),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCartItem(int index) {
    final item = _cartItems[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: StoreColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StoreColors.border),
      ),
      child: Row(
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              item['image'],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 80, height: 80,
                color: Colors.grey[800],
                child: const Icon(Icons.image, color: Colors.white54),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: StoreTextStyles.body.copyWith(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Stars
                Row(
                  children: [
                    ...List.generate(5, (i) {
                      return Icon(
                        i < (item['rating'] as double).floor()
                            ? Icons.star
                            : (i < item['rating'] ? Icons.star_half : Icons.star_border),
                        color: const Color(0xFFFFD700),
                        size: 10,
                      );
                    }),
                    const SizedBox(width: 4),
                    Text('(${item['reviews']})', style: StoreTextStyles.captionSmall),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${item['price']} EGP',
                  style: StoreTextStyles.bodyBold,
                ),
                const SizedBox(height: 8),
                // Quantity row
                Row(
                  children: [
                    _buildQtyButton(Icons.remove, () {
                      if ((item['quantity'] as int) > 1) {
                        setState(() => item['quantity'] = item['quantity'] - 1);
                      }
                    }),
                    SizedBox(
                      width: 28,
                      child: Center(
                        child: Text('${item['quantity']}', style: StoreTextStyles.caption),
                      ),
                    ),
                    _buildQtyButton(Icons.add, () {
                      setState(() => item['quantity'] = item['quantity'] + 1);
                    }),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() => _cartItems.removeAt(index));
                      },
                      child: const Icon(Icons.delete_outline, color: Color(0xFFFF2646), size: 20),
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

  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: StoreColors.primary,
          shape: BoxShape.circle,
        ),
        child: Center(child: Icon(icon, color: StoreColors.textBlack, size: 14)),
      ),
    );
  }

  Widget _buildDiscountRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: StoreColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: StoreColors.border),
            ),
            child: TextField(
              style: StoreTextStyles.caption,
              decoration: InputDecoration(
                hintText: 'Enter discount code',
                hintStyle: StoreTextStyles.caption.copyWith(color: StoreColors.textGrey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) => _discountCode = val,
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            if (_discountCode.isNotEmpty) {
              setState(() => _discount = 10);
            }
          },
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: StoreColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: StoreColors.primary),
            ),
            child: Center(
              child: Text(
                'Apply',
                style: StoreTextStyles.caption.copyWith(color: StoreColors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StoreColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StoreColors.border),
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', '${_subtotal.toStringAsFixed(0)} EGP'),
          const SizedBox(height: 12),
          _summaryRow('Discount', '${_discount.toStringAsFixed(0)} EGP'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: StoreColors.border, height: 1),
          ),
          _summaryRow('Total', '${_total.toStringAsFixed(0)} EGP', isTotal: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: isTotal
                ? StoreTextStyles.body.copyWith(fontWeight: FontWeight.w700)
                : StoreTextStyles.body.copyWith(color: StoreColors.textGrey)),
        Text(value,
            style: isTotal
                ? StoreTextStyles.bodyBold.copyWith(fontSize: 16)
                : StoreTextStyles.body),
      ],
    );
  }
}
