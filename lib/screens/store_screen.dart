import 'package:flutter/material.dart';
import 'package:fit_app/utils/store_styles.dart';
import 'package:fit_app/screens/store/store_product_detail_screen.dart';
import 'package:fit_app/screens/store/store_cart_screen.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['All', 'Supplements', 'Gear'];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Mock product data
  final List<Map<String, dynamic>> _allProducts = [
    {
      'name': 'Combat',
      'image': 'lib/assets/images/store/product_combat.png',
      'price': 50,
      'oldPrice': 80,
      'rating': 4.5,
      'reviews': 130,
      'category': 'Supplements',
      'type': 'supplement',
    },
    {
      'name': 'Dumbbells',
      'image': 'lib/assets/images/store/product_dumbbells.png',
      'price': 100,
      'oldPrice': null,
      'rating': 4.5,
      'reviews': 130,
      'category': 'Gear',
      'type': 'gear',
    },
    {
      'name': 'BlueLab Whey',
      'image': 'lib/assets/images/store/product_whey.png',
      'price': 70,
      'oldPrice': null,
      'rating': 4.5,
      'reviews': 130,
      'category': 'Supplements',
      'type': 'supplement',
    },
    {
      'name': 'Jump rope',
      'image': 'lib/assets/images/store/product_jump_rope.png',
      'price': 70,
      'oldPrice': null,
      'rating': 4.5,
      'reviews': 130,
      'category': 'Gear',
      'type': 'gear',
    },
  ];

  int _cartCount = 0;

  List<Map<String, dynamic>> get _filteredProducts {
    if (_selectedCategoryIndex == 0) return _allProducts;
    final cat = _categories[_selectedCategoryIndex];
    return _allProducts.where((p) => p['category'] == cat).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoreColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Header: Store + Cart
              _buildHeader(),
              const SizedBox(height: 16),
              // Search bar
              _buildSearchBar(),
              const SizedBox(height: 16),
              // Category tabs
              _buildCategoryTabs(),
              const SizedBox(height: 16),
              // Content
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Store', style: StoreTextStyles.headline),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StoreCartScreen()),
            );
          },
          child: Stack(
            children: [
              const Icon(Icons.shopping_cart_outlined, color: StoreColors.textWhite, size: 28),
              if (_cartCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: StoreColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$_cartCount',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: StoreColors.textBlack,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: StoreColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: StoreColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: StoreColors.textWhite, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: StoreTextStyles.caption.copyWith(color: StoreColors.textWhite),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: StoreTextStyles.caption.copyWith(color: StoreColors.textWhite.withValues(alpha: 0.5)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Row(
      children: List.generate(_categories.length, (index) {
        final isSelected = _selectedCategoryIndex == index;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _selectedCategoryIndex = index),
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: StoreColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? StoreColors.primary : StoreColors.border,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: StoreColors.primary.withValues(alpha: 0.25),
                          blurRadius: 12,
                        )
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  _categories[index],
                  style: StoreTextStyles.caption.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildContent() {
    final products = _filteredProducts;
    return SingleChildScrollView(
      child: Column(
        children: [
          // Show promo banner only on "All" tab
          if (_selectedCategoryIndex == 0) ...[
            _buildPromoBanner(),
            const SizedBox(height: 16),
          ],
          // Product grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.55,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) => _buildProductCard(products[index]),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      height: 152,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF191919), Color(0xFF919191)],
        ),
      ),
      child: Stack(
        children: [
          // Product image on right
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Image.asset(
                'lib/assets/images/store/product_protein_banner.png',
                width: 152,
                height: 152,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Text content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Boost your performance, up to 30% OFF!',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: StoreColors.textWhite,
                  ),
                ),
                const Text(
                  'Shop protein & Gear Now',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: StoreColors.textWhite,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 32,
                  width: 124,
                  decoration: BoxDecoration(
                    color: StoreColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('Shop Now', style: StoreTextStyles.button),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoreProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: StoreColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: StoreColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  product['image'],
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: Colors.grey[800],
                    child: const Center(child: Icon(Icons.image, color: Colors.white54)),
                  ),
                ),
              ),
            ),
            // Product info
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${product['name']} ',
                    style: StoreTextStyles.body,
                  ),
                  const SizedBox(height: 4),
                  // Star rating
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < (product['rating'] as double).floor()
                              ? Icons.star
                              : (index < product['rating'] ? Icons.star_half : Icons.star_border),
                          color: const Color(0xFFFFD700),
                          size: 10,
                        );
                      }),
                      const SizedBox(width: 4),
                      Text(
                        '(${product['reviews']})',
                        style: StoreTextStyles.captionSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Price
                  Row(
                    children: [
                      Text(
                        '${product['price']} EGP',
                        style: StoreTextStyles.bodyBold,
                      ),
                      if (product['oldPrice'] != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${product['oldPrice']} EGP',
                          style: StoreTextStyles.body.copyWith(
                            color: StoreColors.textGrey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Add to cart button
                  GestureDetector(
                    onTap: () {
                      setState(() => _cartCount++);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product['name']} added to cart'),
                          backgroundColor: StoreColors.cardBackground,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      height: 32,
                      width: 124,
                      decoration: BoxDecoration(
                        color: StoreColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('Add to cart', style: StoreTextStyles.button),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
