import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../logic/cubits/store/product_detail_cubit.dart';
import '../../../logic/cubits/store/add_review_cubit.dart';
import '../../../logic/cubits/store/cart_cubit.dart';
import '../../../models/product_model.dart';
import '../../../services/store_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProductDetailCubit(StoreService(), widget.productId)..fetchProductDetails(),
        ),
        BlocProvider(
          create: (context) => AddReviewCubit(StoreService()),
        ),
      ],
      child: BlocListener<CartCubit, CartState>(
        listener: (context, state) {
          if (state is CartSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Added to cart successfully!"),
                backgroundColor: Color(0xFFD0FD3E),
                duration: Duration(seconds: 2),
              ),
            );
          } else if (state is CartError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF111111),
          body: BlocBuilder<ProductDetailCubit, ProductDetailState>(
          builder: (context, state) {
            if (state is ProductDetailLoading) {
              return _buildShimmerLoading();
            } else if (state is ProductDetailError) {
              return _buildErrorState(state.message, context);
            } else if (state is ProductDetailSuccess) {
              return _buildContent(context, state.product);
            }
            return const SizedBox.shrink();
          },
        ),
        bottomNavigationBar: BlocBuilder<ProductDetailCubit, ProductDetailState>(
          builder: (context, state) {
            if (state is ProductDetailSuccess) {
              return _buildBottomActions(state.product);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );
}

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildContent(BuildContext context, ProductModel product) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context, product),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderInfo(product),
                const SizedBox(height: 24),
                _buildPriceSection(product),
                const SizedBox(height: 24),
                _buildStockStatus(product),
                const SizedBox(height: 32),
                _buildSectionTitle("Description"),
                const SizedBox(height: 12),
                Text(
                  product.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
                ),
                if (product.specifications != null && product.specifications!.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  _buildSectionTitle("Specifications"),
                  const SizedBox(height: 16),
                  _buildSpecificationsGrid(product.specifications!),
                ],
                const SizedBox(height: 32),
                _buildSectionTitle("Tags"),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: product.tags.map((tag) => _buildTagChip(tag)).toList(),
                ),
                const SizedBox(height: 32),
                _buildReviewSection(product),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, ProductModel product) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: const Color(0xFF1E1E1E),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
            child: const Icon(Icons.share_outlined, size: 18, color: Colors.white),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            PageView.builder(
              itemCount: product.images.length,
              onPageChanged: (index) => setState(() => _currentImageIndex = index),
              itemBuilder: (context, index) {
                return Hero(
                  tag: 'product-${product.id}',
                  child: Image.network(product.images[index], fit: BoxFit.cover),
                );
              },
            ),
            if (product.images.length > 1)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: product.images.asMap().entries.map((entry) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == entry.key
                            ? const Color(0xFFD0FD3E)
                            : Colors.white24,
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.category.toUpperCase(),
          style: const TextStyle(color: Color(0xFFD0FD3E), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        Text(
          product.name,
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.star, color: Color(0xFFFFD700), size: 16),
            const SizedBox(width: 4),
            Text(
              "${product.rating}",
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text(
              "(${product.reviewsCount} reviews)",
              style: const TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceSection(ProductModel product) {
    return Row(
      children: [
        Text(
          "${product.discountPrice ?? product.price} EGP",
          style: const TextStyle(color: Color(0xFFD0FD3E), fontSize: 24, fontWeight: FontWeight.bold),
        ),
        if (product.discountPrice != null) ...[
          const SizedBox(width: 12),
          Text(
            "${product.price} EGP",
            style: const TextStyle(
              color: Colors.white24,
              fontSize: 16,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStockStatus(ProductModel product) {
    final bool isOutOfStock = product.stock <= 0;
    final bool isLowStock = product.stock > 0 && product.stock <= 5;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOutOfStock ? Colors.red : (isLowStock ? Colors.orange : Colors.green),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          isOutOfStock ? "Out of Stock" : (isLowStock ? "Only ${product.stock} left in stock" : "In Stock"),
          style: TextStyle(
            color: isOutOfStock ? Colors.red : (isLowStock ? Colors.orange : Colors.green),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection(ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Rate this product"),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: BlocListener<AddReviewCubit, AddReviewState>(
            listener: (context, state) {
              if (state is AddReviewSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Review submitted successfully!")),
                );
                setState(() {
                  _selectedRating = 0;
                  _commentController.clear();
                });
                // Optionally refresh product details to update rating
                context.read<ProductDetailCubit>().fetchProductDetails();
              } else if (state is AddReviewError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
                );
              }
            },
            child: Column(
              children: [
                _buildStarRatingSelector(),
                const SizedBox(height: 20),
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Write your experience...",
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                BlocBuilder<AddReviewCubit, AddReviewState>(
                  builder: (context, state) {
                    final bool isSubmitting = state is AddReviewSubmitting;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : () => _submitReview(product.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD0FD3E),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isSubmitting
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                            : const Text("Submit Review", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStarRatingSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final int starValue = index + 1;
        return GestureDetector(
          onTap: () => setState(() => _selectedRating = starValue),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              Icons.star,
              size: 32,
              color: starValue <= _selectedRating ? const Color(0xFFFFD700) : Colors.white10,
            ),
          ),
        );
      }),
    );
  }

  void _submitReview(String productId) {
    context.read<AddReviewCubit>().submitReview(
          productId: productId,
          rating: _selectedRating,
          comment: _commentController.text,
        );
  }

  Widget _buildSpecificationsGrid(Map<String, String> specs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: specs.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key, style: const TextStyle(color: Colors.white38, fontSize: 14)),
                Text(entry.value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "#$tag",
        style: const TextStyle(color: Colors.white38, fontSize: 12),
      ),
    );
  }

  Widget _buildBottomActions(ProductModel product) {
    final bool isOutOfStock = product.stock <= 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.favorite_border, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                final bool isAdding = state is CartAdding;
                return ElevatedButton(
                  onPressed: (isOutOfStock || isAdding)
                      ? null
                      : () {
                          context.read<CartCubit>().addToCart(productId: product.id);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD0FD3E),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    disabledBackgroundColor: Colors.white12,
                  ),
                  child: isAdding
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : Text(
                          isOutOfStock ? "OUT OF STOCK" : "ADD TO CART",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.05),
      highlightColor: Colors.white.withValues(alpha: 0.1),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 400, color: Colors.white),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 30, width: 250, color: Colors.white),
                  const SizedBox(height: 16),
                  Container(height: 20, width: 150, color: Colors.white),
                  const SizedBox(height: 32),
                  Container(height: 100, width: double.infinity, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<ProductDetailCubit>().fetchProductDetails(),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD0FD3E)),
            child: const Text("Retry", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
