import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../logic/cubits/store/store_cubit.dart';
import '../../../logic/cubits/store/product_category_cubit.dart';
import '../../../models/product_model.dart';
import '../../../models/category_model.dart';
import '../../../services/store_service.dart';
import 'ProductDetailScreen.dart';
import 'CartScreen.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _fetchProducts() {
    context.read<StoreCubit>().fetchProducts(
      category: _selectedCategory,
      search: _searchController.text,
    );
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductCategoryCubit(StoreService())..fetchCategories(),
      child: Scaffold(
        backgroundColor: const Color(0xFF111111),
        appBar: AppBar(
          backgroundColor: const Color(0xFF111111),
          elevation: 0,
          title: const Text(
            "Fit Glow Store",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            _buildCategories(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _fetchProducts();
                },
                color: const Color(0xFFD0FD3E),
                backgroundColor: const Color(0xFF1E1E1E),
                child: BlocBuilder<StoreCubit, StoreState>(
                  builder: (context, state) {
                    if (state is StoreLoading) {
                      return _buildShimmerGrid();
                    } else if (state is StoreError) {
                      return _buildErrorState(state.message);
                    } else if (state is StoreSuccess) {
                      if (state.products.isEmpty) {
                        return _buildEmptyState();
                      }
                      return _buildProductGrid(state.products);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Search products...",
            hintStyle: TextStyle(color: Colors.white38),
            prefixIcon: Icon(Icons.search, color: Colors.white38),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return BlocBuilder<ProductCategoryCubit, ProductCategoryState>(
      builder: (context, state) {
        if (state is ProductCategoryLoading) {
          return _buildShimmerCategories();
        } else if (state is ProductCategorySuccess) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: state.categories.map((cat) => _buildCategoryChip(cat)).toList(),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCategoryChip(CategoryModel category) {
    final isSelected = _selectedCategory == category.name;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(category.name),
        selected: isSelected,
        onSelected: (val) {
          if (val) {
            setState(() => _selectedCategory = category.name);
            _fetchProducts();
          }
        },
        backgroundColor: const Color(0xFF1E1E1E),
        selectedColor: const Color(0xFFD0FD3E),
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildShimmerCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(
          5,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Shimmer.fromColors(
              baseColor: Colors.white.withValues(alpha: 0.05),
              highlightColor: Colors.white.withValues(alpha: 0.1),
              child: Container(
                width: 80,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(List<ProductModel> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildProductCard(products[index]),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey[900],
                    child: product.images.isNotEmpty
                        ? Image.network(product.images[0], fit: BoxFit.cover)
                        : const Icon(Icons.inventory_2_outlined, color: Colors.white12, size: 48),
                  ),
                ),
                if (product.discountPrice != null)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD0FD3E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "SALE",
                        style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.category,
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
                const SizedBox(height: 4),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "${product.discountPrice ?? product.price} EGP",
                      style: const TextStyle(color: Color(0xFFD0FD3E), fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    if (product.discountPrice != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        "${product.price} EGP",
                        style: const TextStyle(
                          color: Colors.white24,
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.white.withValues(alpha: 0.05),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
          Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          const Text("No products found", style: TextStyle(color: Colors.white38, fontSize: 16)),
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
            onPressed: _fetchProducts,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD0FD3E)),
            child: const Text("Retry", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
