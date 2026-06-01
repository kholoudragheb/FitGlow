import 'package:flutter/material.dart';
import 'package:fit_app/utils/store_styles.dart';

class StoreProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const StoreProductDetailScreen({super.key, required this.product});

  @override
  State<StoreProductDetailScreen> createState() => _StoreProductDetailScreenState();
}

class _StoreProductDetailScreenState extends State<StoreProductDetailScreen> {
  int _currentImageIndex = 0;
  int _quantity = 1;
  int _selectedTabIndex = 0; // 0: Description, 1: Details

  // Supplement variant selections
  int _selectedFlavor = 1; // Rich Chocolate default
  int _selectedSize = 0; // 1 lbs default

  // Gear variant selections
  int _selectedWeight = 1; // 10 Kg default
  int _selectedColor = 0;

  bool get _isSupplement => widget.product['type'] == 'supplement';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoreColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Image carousel
                    _buildImageCarousel(),
                    // Page dots
                    _buildPageDots(),
                    const SizedBox(height: 16),
                    // Title + Price
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildTitlePrice(),
                    ),
                    const SizedBox(height: 4),
                    // Rating
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildRating(),
                    ),
                    const SizedBox(height: 16),
                    // Variant pickers
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _isSupplement ? _buildSupplementVariants() : _buildGearVariants(),
                    ),
                    const SizedBox(height: 16),
                    // Description / Details tabs
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildDescriptionTabs(),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildDescriptionContent(),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            // Bottom bar: quantity + Add to cart
            _buildBottomBar(),
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
            child: Text(
              'Product Details',
              style: StoreTextStyles.title,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return SizedBox(
      height: 250,
      child: PageView.builder(
        itemCount: 3,
        onPageChanged: (index) => setState(() => _currentImageIndex = index),
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                widget.product['image'],
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Container(
                  color: Colors.grey[800],
                  child: const Center(child: Icon(Icons.image, color: Colors.white54, size: 60)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageDots() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          final isActive = index == _currentImageIndex;
          return Container(
            width: isActive ? 24 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: isActive ? StoreColors.primary : StoreColors.textGrey,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTitlePrice() {
    final name = _isSupplement ? 'Optimum Nutrition Gold Standard Whey' : 'Neoprene Coated Dumbbell';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(name, style: StoreTextStyles.subTitle),
        ),
        Text(
          '${widget.product['price']} EGP',
          style: StoreTextStyles.bodyBold.copyWith(fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildRating() {
    return Row(
      children: [
        ...List.generate(5, (index) {
          return Icon(
            index < (widget.product['rating'] as double).floor()
                ? Icons.star
                : (index < widget.product['rating'] ? Icons.star_half : Icons.star_border),
            color: const Color(0xFFFFD700),
            size: 14,
          );
        }),
        const SizedBox(width: 4),
        Text(
          '(${widget.product['reviews']})',
          style: StoreTextStyles.captionSmall,
        ),
      ],
    );
  }

  Widget _buildSupplementVariants() {
    final flavors = ['Vanilla', 'Rich Chocolate', 'Mocha'];
    final sizes = ['1 lbs', '2 lbs', '3 lbs'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Flavor', style: StoreTextStyles.body),
        const SizedBox(height: 8),
        _buildChipRow(flavors, _selectedFlavor, (i) => setState(() => _selectedFlavor = i)),
        const SizedBox(height: 16),
        const Text('Size', style: StoreTextStyles.body),
        const SizedBox(height: 8),
        _buildChipRow(sizes, _selectedSize, (i) => setState(() => _selectedSize = i)),
      ],
    );
  }

  Widget _buildGearVariants() {
    final weights = ['5 Kg', '10 Kg', '15 Kg'];
    final colors = [
      const Color(0xFF333333),
      const Color(0xFFE91E8C),
      const Color(0xFF8BC34A),
      const Color(0xFFFFC107),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Weight', style: StoreTextStyles.body),
        const SizedBox(height: 8),
        _buildChipRow(weights, _selectedWeight, (i) => setState(() => _selectedWeight = i)),
        const SizedBox(height: 16),
        const Text('Color', style: StoreTextStyles.body),
        const SizedBox(height: 8),
        Row(
          children: List.generate(colors.length, (index) {
            final isSelected = _selectedColor == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = index),
              child: Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: colors[index],
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: StoreColors.primary, width: 2)
                      : null,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildChipRow(List<String> options, int selected, ValueChanged<int> onTap) {
    return Row(
      children: List.generate(options.length, (index) {
        final isSelected = selected == index;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? StoreColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? StoreColors.primary : StoreColors.border,
                ),
              ),
              child: Text(
                options[index],
                style: StoreTextStyles.caption.copyWith(
                  color: isSelected ? StoreColors.textBlack : StoreColors.textWhite,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDescriptionTabs() {
    return Row(
      children: [
        _buildTab('Description', 0),
        const SizedBox(width: 16),
        _buildTab('Details', 1),
      ],
    );
  }

  Widget _buildTab(String label, int index) {
    final isActive = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Column(
        children: [
          Text(
            label,
            style: StoreTextStyles.body.copyWith(
              color: isActive ? StoreColors.primary : StoreColors.textGrey,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 80,
            color: isActive ? StoreColors.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionContent() {
    final desc = _isSupplement
        ? 'Whey Protein Isolate (WPI) is the purest form of whey protein that currently exists. WPIs are costly to use, but they rate among the best proteins that money can buy. That\'s why they\'re the first ingredient you read on the Gold Standard 100% Whey label.'
        : 'Enhance your strength training with our Neoprene costed Dumbbells. Designed for comfort and durability, the non-slip neoprene orating provides a secure grip, even during intense workouts. Perfect for home gyms and commercial use, these dumbbell are coir-coded by weight for easy identification.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: StoreColors.border, height: 1),
        const SizedBox(height: 12),
        Text(
          desc,
          style: StoreTextStyles.caption.copyWith(color: StoreColors.textGrey),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          // Quantity selector
          Container(
            decoration: BoxDecoration(
              color: StoreColors.cardBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: StoreColors.border),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_quantity > 1) setState(() => _quantity--);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: StoreColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.remove, color: StoreColors.textBlack, size: 18),
                    ),
                  ),
                ),
                SizedBox(
                  width: 32,
                  child: Center(
                    child: Text(
                      '$_quantity',
                      style: StoreTextStyles.body,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _quantity++),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: StoreColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.add, color: StoreColors.textBlack, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Add to cart button
          Expanded(
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$_quantity × ${widget.product['name']} added to cart'),
                    backgroundColor: StoreColors.cardBackground,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: StoreColors.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Text('Add to cart', style: StoreTextStyles.button),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
