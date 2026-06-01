import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fit_app/utils/nutrition_styles.dart';
import 'package:fit_app/screens/nutrition/nutrition_filter_screen.dart';

class NutritionSearchScreen extends StatefulWidget {
  const NutritionSearchScreen({super.key});

  @override
  State<NutritionSearchScreen> createState() => _NutritionSearchScreenState();
}

class _NutritionSearchScreenState extends State<NutritionSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _topSearches = ['Sugar Free', 'Vegetarian', 'Low Calories'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutritionColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Header: Back + Title
              _buildTitleRow(),
              const SizedBox(height: 24),
              // Search bar + Filter
              _buildSearchRow(),
              const SizedBox(height: 32),
              // Top Search Section
              _buildTopSearchSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: NutritionColors.cardBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF5C5C5C)),
            ),
            child: const Center(
              child: Icon(Icons.arrow_back_ios_new, color: NutritionColors.textWhite, size: 16),
            ),
          ),
        ),
        const Expanded(
          child: Text(
            'Search',
            style: NutritionTextStyles.title,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 32), // Balance the back button
      ],
    );
  }

  Widget _buildSearchRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: NutritionColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF5C5C5C)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.search, color: NutritionColors.textWhite, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: false,
                    style: NutritionTextStyles.body.copyWith(color: NutritionColors.textWhite),
                    decoration: InputDecoration(
                      hintText: 'Search  meals...',
                      hintStyle: NutritionTextStyles.caption.copyWith(color: NutritionColors.textWhite),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NutritionFilterScreen()),
            );
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: NutritionColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF5C5C5C)),
            ),
            child: Center(
              child: SvgPicture.asset(
                'lib/assets/icons/nutrition/icon_filter.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(NutritionColors.textWhite, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Search',
          style: NutritionTextStyles.subTitle.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        ..._topSearches.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              SvgPicture.asset(
                'lib/assets/icons/nutrition/icon_trend_up.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(NutritionColors.primary, BlendMode.srcIn),
              ),
              const SizedBox(width: 12),
              Text(item, style: NutritionTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        )),
      ],
    );
  }
}
